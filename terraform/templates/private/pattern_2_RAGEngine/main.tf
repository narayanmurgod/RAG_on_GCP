# pattern_2_RAGEngine — Private RAG Engine Deployment
# Provisions a Vertex AI RAG Corpus with private access control, optional VPC networking, and optional private Cloud Run serving layer.

locals {
  corpus_name  = "${var.display_name}-corpus"
  service_name = "${var.display_name}-service"

  # Map vector_db_type to rag-engine supported db_type
  rag_engine_db_type = (
    var.vector_db_type == "rag_managed_ann" ? "rag_managed_ann" :
    var.vector_db_type == "vertex_vector_search" ? "vertex_vector_search" :
    "rag_managed_knn"
  )

  # Resolve VPC connector ID: either existing or freshly created from networking module
  resolved_vpc_connector_id = var.use_existing_network ? var.existing_connector_id : (var.enable_cloud_run ? module.networking[0].connector_id : null)

  # Resolve VPC network name/id for private Vertex Vector Search (if applicable)
  resolved_network = var.use_existing_network ? var.existing_network_name : (var.enable_cloud_run ? module.networking[0].network_id : null)
}

# ── Enable Required Google Cloud APIs ─────────────────────────────────────────

resource "google_project_service" "apis" {
  for_each = toset(concat(
    [
      "aiplatform.googleapis.com",
      "storage.googleapis.com"
    ],
    (var.vector_db_type == "pinecone" || var.vector_db_type == "weaviate") ? ["secretmanager.googleapis.com"] : [],
    var.enable_cloud_run ? ["run.googleapis.com", "vpcaccess.googleapis.com", "compute.googleapis.com"] : []
  ))

  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

# ── Networking Module (New VPC when enable_cloud_run = true && !use_existing_network) ─

module "networking" {
  count  = (var.enable_cloud_run && !var.use_existing_network) ? 1 : 0
  source = "../../../modules/networking"

  project_id         = var.project_id
  region             = var.region
  network_name       = var.network_name
  app_subnet_cidr    = var.app_subnet_cidr
  connector_cidr     = var.connector_cidr
  enable_nat_gateway = var.enable_nat_gateway

  depends_on = [google_project_service.apis]
}

# ── IAM: Service Account & Roles ──────────────────────────────────────────────

resource "google_service_account" "rag_engine" {
  project      = var.project_id
  account_id   = "rag-engine-p2-sa"
  display_name = "RAG Engine SA — ${var.display_name} (Private Pattern 2)"
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

# ── IAM: Restricted Invoker Access (Private Only) ─────────────────────────────

resource "google_project_iam_member" "restricted_invokers" {
  for_each = toset(var.allowed_invoker_members)
  project  = var.project_id
  role     = "roles/aiplatform.user"
  member   = each.value
}

# ── Module: Vertex Vector Search (when vector_db_type = "vertex_vector_search") ─

module "vector_search" {
  count  = var.vector_db_type == "vertex_vector_search" ? 1 : 0
  source = "../../../modules/vector-search"

  project_id   = var.project_id
  region       = var.region
  display_name = "${var.display_name}-vs-pvt"
  description  = "Private Vertex Vector Search for ${var.display_name}"
  labels       = var.labels

  dimensions                  = var.vs_dimensions
  algorithm                   = var.vs_algorithm
  distance_measure_type       = var.vs_distance_measure
  public_endpoint_enabled     = false
  network                     = local.resolved_network
  enable_private_service_connect = false

  deploy_index      = true
  machine_type      = var.vs_machine_type
  min_replicas      = var.vs_min_replicas
  max_replicas      = var.vs_max_replicas

  depends_on = [google_project_service.apis]
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

  depends_on = [google_project_service.apis]
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

  depends_on = [google_project_service.apis]
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
    google_project_service.apis,
    google_service_account.rag_engine,
  ]
}

# ── Module: Private Cloud Run Serving Layer (Optional) ────────────────────────

module "cloud_run" {
  count  = var.enable_cloud_run ? 1 : 0
  source = "../../../modules/cloud-run-rag"

  project_id            = var.project_id
  region                = var.region
  service_name          = local.service_name
  container_image       = var.container_image
  min_instances         = var.min_instances
  max_instances         = var.max_instances
  allow_unauthenticated = false
  labels                = var.labels

  # Route all egress through private Serverless VPC Access connector
  vpc_connector_id = local.resolved_vpc_connector_id
  vpc_egress       = "ALL_TRAFFIC"

  env_vars = {
    PROJECT_ID          = var.project_id
    REGION              = var.region
    RAG_CORPUS_NAME     = module.rag_engine.corpus_name
    VECTOR_DB_TYPE      = var.vector_db_type
    EMBEDDING_MODEL     = var.embedding_model
    GENERATION_MODEL    = var.generation_model
    STAGING_BUCKET      = module.rag_engine.staging_bucket_name != null ? module.rag_engine.staging_bucket_name : ""
    PINECONE_INDEX      = var.vector_db_type == "pinecone" ? module.pinecone[0].index_name : ""
    WEAVIATE_COLLECTION = var.vector_db_type == "weaviate" ? module.weaviate[0].collection_name : ""
  }

  depends_on = [
    google_project_service.apis,
    module.rag_engine,
  ]
}
