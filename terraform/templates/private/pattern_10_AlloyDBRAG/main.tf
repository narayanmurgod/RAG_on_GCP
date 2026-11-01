# pattern_10_AlloyDBRAG — Private AlloyDB PostgreSQL ScaNN RAG Deployment
# Provisions an AlloyDB for PostgreSQL cluster and primary instance inside a private VPC with Private Service Access, restricted IAM invokers, and an optional private Cloud Run serving layer.

locals {
  service_name = "${var.display_name}-service"

  # Map vector_db_type to rag-engine supported db_type
  rag_engine_db_type = "alloydb_pgvector"

  # Resolve VPC connector ID: either existing or created from networking module
  resolved_vpc_connector_id = var.use_existing_network ? var.existing_connector_id : (var.enable_cloud_run ? module.networking[0].connector_id : null)

  # Resolve VPC network ID for private AlloyDB
  resolved_network = var.use_existing_network ? var.existing_network_name : module.networking[0].network_id
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

resource "google_project_service" "vpcaccess" {
  count              = var.enable_cloud_run ? 1 : 0
  project            = var.project_id
  service            = "vpcaccess.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "run" {
  count              = var.enable_cloud_run ? 1 : 0
  project            = var.project_id
  service            = "run.googleapis.com"
  disable_on_destroy = false
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

  depends_on = [
    google_project_service.compute,
    google_project_service.servicenetworking
  ]
}

# IAM: Service Account & Core Roles
resource "google_service_account" "alloydb_rag" {
  project      = var.project_id
  account_id   = "alloydb-rag-p10-sa"
  display_name = "AlloyDB RAG SA — ${var.display_name} (Private Pattern 10)"
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

# IAM: Restricted Invoker Access (Private Only)
resource "google_project_iam_member" "restricted_alloydb_clients" {
  for_each = toset(var.allowed_invoker_members)
  project  = var.project_id
  role     = "roles/alloydb.client"
  member   = each.value
}

# Module: alloydb (Private IP inside VPC)
module "alloydb" {
  source = "../../../modules/alloydb"

  project_id            = var.project_id
  region                = var.region
  cluster_id            = var.cluster_id
  display_name          = var.display_name
  network_id            = local.resolved_network
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
    google_project_iam_member.restricted_alloydb_clients,
    module.networking
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
    ALLOYDB_CLUSTER_ID = module.alloydb.cluster_id
    ALLOYDB_INSTANCE   = module.alloydb.instance_id
    ALLOYDB_PRIMARY_IP = module.alloydb.primary_ip_address
    EMBEDDING_MODEL    = var.embedding_model
    GENERATION_MODEL   = var.generation_model
  }

  depends_on = [
    google_project_service.run,
    module.alloydb
  ]
}
