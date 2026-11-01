# pattern_5_BigQueryRAG — Public BigQuery Vector Search RAG Deployment
# Provisions a BigQuery dataset and table optimized for VECTOR_SEARCH() with an optional Cloud Run serving layer and optional GCS staging bucket.

locals {
  service_name        = "${var.display_name}-service"
  staging_bucket_name = var.staging_bucket_name != "" ? var.staging_bucket_name : "${var.project_id}-${var.display_name}-staging"

  # Map vector_db_type to rag-engine supported db_type
  rag_engine_db_type = "bigquery_vector"
}

# Enable Required Google Cloud APIs
resource "google_project_service" "bigquery" {
  project            = var.project_id
  service            = "bigquery.googleapis.com"
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

# Cloud Storage staging bucket for batch document ingestion
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
resource "google_service_account" "bigquery_rag" {
  project      = var.project_id
  account_id   = "bq-rag-p5-sa"
  display_name = "BigQuery RAG SA — ${var.display_name} (Public Pattern 5)"
}

resource "google_project_iam_member" "bigquery_data_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.bigquery_rag.email}"
}

resource "google_project_iam_member" "bigquery_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.bigquery_rag.email}"
}

resource "google_project_iam_member" "storage_admin" {
  count   = var.create_staging_bucket ? 1 : 0
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.bigquery_rag.email}"
}

# Module: bigquery-vector
module "bigquery_vector" {
  source = "../../../modules/bigquery-vector"

  project_id                 = var.project_id
  location                   = var.location
  dataset_id                 = var.dataset_id
  table_id                   = var.table_id
  description                = "BigQuery Vector Search analytical RAG dataset for ${var.display_name}"
  labels                     = var.labels
  delete_contents_on_destroy = var.delete_contents_on_destroy

  depends_on = [
    google_project_service.bigquery,
    google_service_account.bigquery_rag,
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
    BIGQUERY_DATASET   = module.bigquery_vector.dataset_id
    BIGQUERY_TABLE     = module.bigquery_vector.table_id
    BIGQUERY_TABLE_FQN = module.bigquery_vector.table_full_id
    EMBEDDING_MODEL    = var.embedding_model
    GENERATION_MODEL   = var.generation_model
    STAGING_BUCKET     = var.create_staging_bucket ? google_storage_bucket.staging[0].name : ""
  }

  depends_on = [
    google_project_service.run,
    module.bigquery_vector,
  ]
}
