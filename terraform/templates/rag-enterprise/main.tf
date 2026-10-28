# Enterprise Cloud Spanner RAG root orchestration template

locals {
  # Resource naming conventions for service and database instance
  service_name = "${var.display_name}-service"
  spanner_id   = "${var.display_name}-spanner"
}

# Enable required Google Cloud APIs for enterprise Spanner RAG
resource "google_project_service" "apis" {
  for_each = toset([
    "spanner.googleapis.com",
    "run.googleapis.com",
    "aiplatform.googleapis.com",
    "vpcaccess.googleapis.com",
    "compute.googleapis.com"
  ])

  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

# Enterprise private VPC and Serverless VPC Access connector module
module "networking" {
  source = "../../modules/networking"

  project_id      = var.project_id
  region          = var.region
  network_name    = var.network_name
  app_subnet_cidr = var.app_subnet_cidr
  connector_cidr  = var.connector_cidr

  depends_on = [google_project_service.apis]
}

# Enterprise Cloud Run serving layer connected to private VPC
module "cloud_run" {
  source = "../../modules/cloud-run-rag"

  project_id            = var.project_id
  region                = var.region
  service_name          = local.service_name
  container_image       = var.container_image
  min_instances         = var.min_instances
  max_instances         = var.max_instances
  allow_unauthenticated = var.allow_unauthenticated
  labels                = var.labels

  # Route all egress traffic through the private Serverless VPC Access connector
  vpc_connector_id = module.networking.connector_id
  vpc_egress       = "ALL_TRAFFIC"

  # Pass environment variables for Spanner connection and model endpoints
  env_vars = {
    PROJECT_ID           = var.project_id
    REGION               = var.region
    SPANNER_INSTANCE     = local.spanner_id
    SPANNER_DATABASE     = var.spanner_database_name
    SPANNER_CONNECTION   = "projects/${var.project_id}/instances/${local.spanner_id}/databases/${var.spanner_database_name}"
    EMBEDDING_MODEL      = var.embedding_model
    GENERATION_MODEL     = var.generation_model
    ENABLE_SPANNER_GRAPH = tostring(var.enable_spanner_graph_rag)
  }

  depends_on = [google_project_service.apis]
}

# Cloud Spanner module with Vector Search and Spanner Graph RAG DDL
module "spanner" {
  source = "../../modules/spanner"

  project_id       = var.project_id
  instance_id      = local.spanner_id
  config           = var.spanner_config
  processing_units = var.spanner_processing_units
  labels           = var.labels

  database_name       = var.spanner_database_name
  embedding_dimension = var.embedding_dimension
  distance_type       = var.spanner_distance_type
  enable_vector_index = true
  enable_graph_rag    = var.enable_spanner_graph_rag

  # Authorize the Cloud Run service account to access the Spanner database
  authorized_service_accounts = [
    module.cloud_run.service_account_email
  ]

  depends_on = [google_project_service.apis]
}
