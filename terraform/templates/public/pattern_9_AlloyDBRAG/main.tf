# pattern_9_AlloyDBRAG — Public AlloyDB PostgreSQL ScaNN RAG Deployment
# Provisions an AlloyDB for PostgreSQL cluster and primary instance with ScaNN vector acceleration and an optional Cloud Run serving layer.

locals {
  service_name = "${var.display_name}-service"

  # Map vector_db_type to rag-engine supported db_type
  rag_engine_db_type = "alloydb_pgvector"
}

# Enable Required Google Cloud APIs
resource "google_project_service" "alloydb" {
  project            = var.project_id
  service            = "alloydb.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "servicenetworking" {
  project            = var.project_id
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "run" {
  count              = var.enable_cloud_run ? 1 : 0
  project            = var.project_id
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# IAM: Service Account & Core Roles
resource "google_service_account" "alloydb_rag" {
  project      = var.project_id
  account_id   = "alloydb-rag-p9-sa"
  display_name = "AlloyDB RAG SA — ${var.display_name} (Public Pattern 9)"
}

resource "google_project_iam_member" "alloydb_client" {
  project = var.project_id
  role    = "roles/alloydb.client"
  member  = "serviceAccount:${google_service_account.alloydb_rag.email}"
}

resource "google_project_iam_member" "alloydb_database_user" {
  project = var.project_id
  role    = "roles/alloydb.databaseUser"
  member  = "serviceAccount:${google_service_account.alloydb_rag.email}"
}

# Module: alloydb
module "alloydb" {
  source = "../../../modules/alloydb"

  project_id            = var.project_id
  region                = var.region
  cluster_id            = var.cluster_id
  display_name          = var.display_name
  network_id            = var.network_id
  initial_user_password = var.initial_user_password
  instance_id           = var.instance_id
  cpu_count             = var.cpu_count
  database_flags        = var.database_flags
  labels                = var.labels

  depends_on = [
    google_project_service.alloydb,
    google_project_service.compute,
    google_project_service.servicenetworking,
    google_service_account.alloydb_rag,
  ]
}

# Module: Cloud Run Serving Layer (Optional)
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
    ALLOYDB_CLUSTER_ID = module.alloydb.cluster_id
    ALLOYDB_INSTANCE   = module.alloydb.instance_id
    ALLOYDB_PRIMARY_IP = module.alloydb.primary_ip_address
    EMBEDDING_MODEL    = var.embedding_model
    GENERATION_MODEL   = var.generation_model
  }

  depends_on = [
    google_project_service.run,
    module.alloydb,
  ]
}
