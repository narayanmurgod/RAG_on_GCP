# pattern_8_CloudSQLRAG — Private Cloud SQL pgvector RAG Deployment
# Provisions a private Cloud SQL PostgreSQL instance with pgvector, VPC private IP, restricted IAM invokers, optional private Cloud Run serving layer, and optional GCS staging bucket.

locals {
  service_name        = "${var.display_name}-service"
  staging_bucket_name = var.staging_bucket_name != "" ? var.staging_bucket_name : "${var.project_id}-${var.display_name}-staging-pvt"

  # Map vector_db_type to rag-engine supported db_type
  rag_engine_db_type = "cloud_sql_pgvector"

  # Resolve VPC connector ID: either existing or created from networking module
  resolved_vpc_connector_id = var.use_existing_network ? var.existing_connector_id : (var.enable_cloud_run ? module.networking[0].connector_id : null)

  # Resolve VPC network ID for private Cloud SQL
  resolved_network = var.use_existing_network ? var.existing_network_name : module.networking[0].network_id
}

# Enable Required Google Cloud APIs
resource "google_project_service" "apis" {
  for_each = toset(concat(
    ["sqladmin.googleapis.com", "compute.googleapis.com", "servicenetworking.googleapis.com"],
    var.create_staging_bucket ? ["storage.googleapis.com"] : [],
    var.enable_cloud_run ? ["run.googleapis.com", "vpcaccess.googleapis.com"] : []
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

# Networking Module (New VPC when !use_existing_network)
module "networking" {
  count  = var.use_existing_network ? 0 : 1
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
resource "google_service_account" "cloudsql_rag" {
  project      = var.project_id
  account_id   = "sql-rag-p8-sa"
  display_name = "Cloud SQL RAG SA — ${var.display_name} (Private Pattern 8)"
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

# IAM: Restricted Invoker Access (Private Only)
resource "google_project_iam_member" "restricted_sql_clients" {
  for_each = toset(var.allowed_invoker_members)
  project  = var.project_id
  role     = "roles/cloudsql.client"
  member   = each.value
}

# Module: cloud-sql-pg (Private IP)
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
  enable_public_ip    = false
  private_network     = local.resolved_network
  deletion_protection = var.deletion_protection
  labels              = var.labels

  depends_on = [
    google_project_service.apis,
    google_service_account.cloudsql_rag,
    google_project_iam_member.restricted_sql_clients,
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
    DB_CONNECTION_NAME = module.cloud_sql.connection_name
    DB_NAME            = module.cloud_sql.database_name
    DB_USER            = module.cloud_sql.user_name
    DB_PRIVATE_IP      = module.cloud_sql.private_ip_address
    EMBEDDING_MODEL    = var.embedding_model
    GENERATION_MODEL   = var.generation_model
    STAGING_BUCKET     = var.create_staging_bucket ? google_storage_bucket.staging[0].name : ""
  }

  depends_on = [
    google_project_service.apis,
    module.cloud_sql,
  ]
}
