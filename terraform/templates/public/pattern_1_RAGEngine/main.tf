# pattern_1_RAGEngine — Public RAG Engine Deployment
# Provisions a Vertex AI RAG Corpus with optional Vector Database backends and optional Cloud Run serving layer.

locals {
  corpus_name  = "${var.display_name}-corpus"
  service_name = "${var.display_name}-service"

  # Map vector_db_type to rag-engine supported db_type
  rag_engine_db_type = (
    var.vector_db_type == "rag_managed_ann" ? "rag_managed_ann" :
    var.vector_db_type == "vertex_vector_search" ? "vertex_vector_search" :
    "rag_managed_knn"
  )
}

# ── Enable Required Google Cloud APIs ─────────────────────────────────────────

resource "google_project_service" "aiplatform" {
  project            = var.project_id
  service            = "aiplatform.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "storage" {
  project            = var.project_id
  service            = "storage.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "secretmanager" {
  count              = (var.vector_db_type == "pinecone" || var.vector_db_type == "weaviate") ? 1 : 0
  project            = var.project_id
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "run" {
  count              = var.enable_cloud_run ? 1 : 0
  project            = var.project_id
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# ── IAM: Service Account & Core Roles ─────────────────────────────────────────

resource "google_service_account" "rag_engine" {
  project      = var.project_id
  account_id   = "rag-engine-p1-sa"
  display_name = "RAG Engine SA — ${var.display_name} (Public Pattern 1)"
}

resource "google_project_iam_member" "aiplatform_user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.rag_engine.email}"
}

resource "google_project_iam_member" "storage_object_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.rag_engine.email}"
}

# ── Module: Vertex Vector Search (when vector_db_type = "vertex_vector_search") ─

module "vector_search" {
  count  = var.vector_db_type == "vertex_vector_search" ? 1 : 0
  source = "../../../modules/vector-search"

  project_id   = var.project_id
  region       = var.region
  display_name = "${var.display_name}-vs"
  description  = "Dedicated Vertex Vector Search for ${var.display_name}"
  labels       = var.labels

  dimensions                  = var.vs_dimensions
  algorithm                   = var.vs_algorithm
  distance_measure_type       = var.vs_distance_measure
  public_endpoint_enabled     = true
  network                     = null
  enable_private_service_connect = false

  deploy_index      = true
  machine_type      = var.vs_machine_type
  min_replicas      = var.vs_min_replicas
  max_replicas      = var.vs_max_replicas

  depends_on = [google_project_service.aiplatform]
}

# ── Module: Pinecone (when vector_db_type = "pinecone") ───────────────────────

module "pinecone" {
  count  = var.vector_db_type == "pinecone" ? 1 : 0
  source = "../../../modules/pinecone"

  project_id        = var.project_id
  secret_id_prefix  = "${var.display_name}-pinecone"
  api_key           = var.pinecone_api_key
  environment       = var.pinecone_environment
  index_name        = var.pinecone_index_name
  labels            = var.labels
  authorized_service_accounts = [
    google_service_account.rag_engine.email
  ]

  depends_on = [google_project_service.secretmanager]
}

# ── Module: Weaviate (when vector_db_type = "weaviate") ───────────────────────

module "weaviate" {
  count  = var.vector_db_type == "weaviate" ? 1 : 0
  source = "../../../modules/weaviate"

  project_id        = var.project_id
  secret_id_prefix  = "${var.display_name}-weaviate"
  api_key           = var.weaviate_api_key
  cluster_url       = var.weaviate_cluster_url
  collection_name   = var.weaviate_collection
  labels            = var.labels
  authorized_service_accounts = [
    google_service_account.rag_engine.email
  ]

  depends_on = [google_project_service.secretmanager]
}

# ── Module: Vertex AI RAG Engine ──────────────────────────────────────────────

module "rag_engine" {
  source = "../../../modules/rag-engine"

  project_id   = var.project_id
  region       = var.region
  display_name = local.corpus_name
  description  = var.description
  db_type      = local.rag_engine_db_type
  labels       = var.labels

  ann_leaf_count = var.ann_leaf_count
  ann_tree_depth = var.ann_tree_depth

  vertex_vector_search_index    = var.vector_db_type == "vertex_vector_search" ? module.vector_search[0].index_id : null
  vertex_vector_search_endpoint = var.vector_db_type == "vertex_vector_search" ? module.vector_search[0].index_endpoint_id : null

  create_staging_bucket = var.create_staging_bucket
  staging_bucket_name   = var.staging_bucket_name

  depends_on = [
    google_project_service.aiplatform,
    google_project_service.storage,
    google_service_account.rag_engine,
  ]
}

# ── Module: Cloud Run Serving Layer (Optional) ────────────────────────────────

module "cloud_run" {
  count  = var.enable_cloud_run ? 1 : 0
  source = "../../../modules/cloud-run-rag"

  project_id            = var.project_id
  region                = var.region
  service_name          = local.service_name
  container_image       = var.container_image
  min_instances         = var.min_instances
  max_instances         = var.max_instances
  allow_unauthenticated = var.allow_unauthenticated
  labels                = var.labels

  env_vars = {
    PROJECT_ID         = var.project_id
    REGION             = var.region
    RAG_CORPUS_NAME    = module.rag_engine.corpus_name
    VECTOR_DB_TYPE     = var.vector_db_type
    EMBEDDING_MODEL    = var.embedding_model
    GENERATION_MODEL   = var.generation_model
    STAGING_BUCKET     = module.rag_engine.staging_bucket_name != null ? module.rag_engine.staging_bucket_name : ""
    PINECONE_INDEX     = var.vector_db_type == "pinecone" ? module.pinecone[0].index_name : ""
    WEAVIATE_COLLECTION = var.vector_db_type == "weaviate" ? module.weaviate[0].collection_name : ""
  }

  depends_on = [
    google_project_service.run,
    module.rag_engine,
  ]
}
