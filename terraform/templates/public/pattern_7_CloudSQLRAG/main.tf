# pattern_7_CloudSQLRAG — Public Cloud SQL pgvector RAG Deployment
# Provisions a Cloud SQL PostgreSQL instance with pgvector extension enabled, public IP access, an optional Cloud Run serving layer, and an optional GCS staging bucket.

locals {
  service_name        = "${var.display_name}-service"
  staging_bucket_name = var.staging_bucket_name != "" ? var.staging_bucket_name : "${var.project_id}-${var.display_name}-staging"

  # Map vector_db_type to rag-engine supported db_type
  rag_engine_db_type = "cloud_sql_pgvector"
}

# Enable Required Google Cloud APIs
resource "google_project_service" "sqladmin" {
  project            = var.project_id
  service            = "sqladmin.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "storage" {
  count              = var.create_staging_bucket ? 1 : 0
  project            = var.project_id
  service            = "storage.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "run" {
  count              = var.enable_cloud_run ? 1 : 0
  project            = var.project_id
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# Cloud Storage staging bucket for document or database dump ingestion
resource "google_storage_bucket" "staging" {
  count                       = var.create_staging_bucket ? 1 : 0
  name                        = local.staging_bucket_name
  project                     = var.project_id
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = false
  labels                      = var.labels

  versioning {
    enabled = true
  }

  depends_on = [google_project_service.storage]
}

# IAM: Service Account & Core Roles
resource "google_service_account" "cloudsql_rag" {
  project      = var.project_id
  account_id   = "sql-rag-p7-sa"
  display_name = "Cloud SQL RAG SA — ${var.display_name} (Public Pattern 7)"
}

resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloudsql_rag.email}"
}

resource "google_project_iam_member" "cloudsql_instance_user" {
  project = var.project_id
  role    = "roles/cloudsql.instanceUser"
  member  = "serviceAccount:${google_service_account.cloudsql_rag.email}"
}

resource "google_project_iam_member" "storage_admin" {
  count   = var.create_staging_bucket ? 1 : 0
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.cloudsql_rag.email}"
}

# Module: cloud-sql-pg
module "cloud_sql" {
  source = "../../../modules/cloud-sql-pg"

  project_id          = var.project_id
  region              = var.region
  instance_name       = var.instance_name
  database_version    = var.database_version
  tier                = var.tier
  database_name       = var.database_name
  user_name           = var.user_name
  user_password       = var.user_password
  enable_public_ip    = true
  private_network     = null
  deletion_protection = var.deletion_protection
  labels              = var.labels

  depends_on = [
    google_project_service.sqladmin,
    google_service_account.cloudsql_rag,
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
    DB_CONNECTION_NAME = module.cloud_sql.connection_name
    DB_NAME            = module.cloud_sql.database_name
    DB_USER            = module.cloud_sql.user_name
    EMBEDDING_MODEL    = var.embedding_model
    GENERATION_MODEL   = var.generation_model
    STAGING_BUCKET     = var.create_staging_bucket ? google_storage_bucket.staging[0].name : ""
  }

  depends_on = [
    google_project_service.run,
    module.cloud_sql,
  ]
}
