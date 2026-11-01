# pattern_6_BigQueryRAG — Private BigQuery Vector Search RAG Deployment
# Provisions a private BigQuery dataset and vector table with restricted IAM invokers, optional VPC networking, optional GCS staging bucket, and optional private Cloud Run serving layer.

locals {
  service_name        = "${var.display_name}-service"
  staging_bucket_name = var.staging_bucket_name != "" ? var.staging_bucket_name : "${var.project_id}-${var.display_name}-staging-pvt"

  # Map vector_db_type to rag-engine supported db_type
  rag_engine_db_type = "bigquery_vector"

  # Resolve VPC connector ID: either existing or created from networking module
  resolved_vpc_connector_id = var.use_existing_network ? var.existing_connector_id : (var.enable_cloud_run ? module.networking[0].connector_id : null)
}

# Enable Required Google Cloud APIs
resource "google_project_service" "apis" {
  for_each = toset(concat(
    ["bigquery.googleapis.com"],
    var.create_staging_bucket ? ["storage.googleapis.com"] : [],
    var.enable_cloud_run ? ["run.googleapis.com", "vpcaccess.googleapis.com", "compute.googleapis.com"] : []
  ))

  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

# Cloud Storage staging bucket for batch document ingestion (Private)
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

  depends_on = [google_project_service.apis]
}

# Networking Module (New VPC when enable_cloud_run = true && !use_existing_network)
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

# IAM: Service Account & Core Roles
resource "google_service_account" "bigquery_rag" {
  project      = var.project_id
  account_id   = "bq-rag-p6-sa"
  display_name = "BigQuery RAG SA — ${var.display_name} (Private Pattern 6)"
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

# IAM: Restricted Invoker Access (Private Only)
resource "google_project_iam_member" "restricted_data_viewers" {
  for_each = toset(var.allowed_invoker_members)
  project  = var.project_id
  role     = "roles/bigquery.dataViewer"
  member   = each.value
}

resource "google_project_iam_member" "restricted_job_users" {
  for_each = toset(var.allowed_invoker_members)
  project  = var.project_id
  role     = "roles/bigquery.jobUser"
  member   = each.value
}

# Module: bigquery-vector
module "bigquery_vector" {
  source = "../../../modules/bigquery-vector"

  project_id                 = var.project_id
  location                   = var.location
  dataset_id                 = var.dataset_id
  table_id                   = var.table_id
  description                = "Private BigQuery Vector Search dataset for ${var.display_name}"
  labels                     = var.labels
  delete_contents_on_destroy = var.delete_contents_on_destroy

  depends_on = [
    google_project_service.apis,
    google_service_account.bigquery_rag,
    google_project_iam_member.restricted_data_viewers,
  ]
}

# Module: Private Cloud Run Serving Layer (Optional)
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

  # Route all outbound egress through private Serverless VPC Access connector
  vpc_connector_id = local.resolved_vpc_connector_id
  vpc_egress       = "ALL_TRAFFIC"

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
    google_project_service.apis,
    module.bigquery_vector,
  ]
}
