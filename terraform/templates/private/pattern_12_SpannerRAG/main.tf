# pattern_12_SpannerRAG — Private Cloud Spanner Graph & Vector RAG Deployment
# Provisions Cloud Spanner instance, database with vector indexing and Graph DDL inside private VPC with restricted IAM invokers, and optional Cloud Run serving service.

locals {
  service_name = "${var.display_name}-service"

  # Map vector_db_type to rag-engine supported db_type
  rag_engine_db_type = "spanner_vector"

  # Resolve VPC connector ID: either existing or created from networking module
  resolved_vpc_connector_id = var.use_existing_network ? var.existing_connector_id : (var.enable_cloud_run ? module.networking[0].connector_id : null)

  # Resolve VPC network ID
  resolved_network = var.use_existing_network ? var.existing_network_name : module.networking[0].network_id
}

# Enable Required Google Cloud APIs
resource "google_project_service" "spanner" {
  project            = var.project_id
  service            = "spanner.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute" {
  project            = var.project_id
  service            = "compute.googleapis.com"
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
    google_project_service.compute
  ]
}

# IAM: Service Account & Core Roles
resource "google_service_account" "spanner_rag" {
  project      = var.project_id
  account_id   = "spanner-rag-p12-sa"
  display_name = "Spanner RAG SA — ${var.display_name} (Private Pattern 12)"
}

resource "google_project_iam_member" "spanner_database_user" {
  project = var.project_id
  role    = "roles/spanner.databaseUser"
  member  = "serviceAccount:${google_service_account.spanner_rag.email}"
}

# IAM: Restricted Invoker Access (Private Only)
resource "google_project_iam_member" "restricted_spanner_clients" {
  for_each = toset(var.allowed_invoker_members)
  project  = var.project_id
  role     = "roles/spanner.databaseUser"
  member   = each.value
}

# Module: spanner
module "spanner" {
  source = "../../../modules/spanner"

  project_id          = var.project_id
  instance_id         = var.instance_id
  display_name        = var.display_name
  config              = var.spanner_config
  processing_units    = var.processing_units
  database_name       = var.database_name
  embedding_dimension = var.embedding_dimension
  distance_type       = var.distance_type
  enable_vector_index = var.enable_vector_index
  enable_graph_rag    = var.enable_graph_rag
  labels              = var.labels

  depends_on = [
    google_project_service.spanner,
    google_service_account.spanner_rag,
    google_project_iam_member.restricted_spanner_clients,
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
    PROJECT_ID        = var.project_id
    REGION            = var.region
    SPANNER_INSTANCE  = module.spanner.instance_id
    SPANNER_DATABASE  = module.spanner.database_name
    SPANNER_GRAPH     = var.graph_name
    EMBEDDING_MODEL   = var.embedding_model
    GENERATION_MODEL  = var.generation_model
  }

  depends_on = [
    google_project_service.run,
    module.spanner,
  ]
}
