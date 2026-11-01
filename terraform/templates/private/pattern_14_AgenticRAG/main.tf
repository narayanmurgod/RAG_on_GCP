# pattern_14_AgenticRAG — Private Agentic Reasoning RAG Deployment
# Provisions Vertex AI Reasoning Engine agent runtime coupled with Vertex AI RAG Engine knowledge base inside private VPC with restricted IAM invokers, and optional Cloud Run serving service.

locals {
  service_name = "${var.display_name}-service"

  # Map vector_db_type to rag-engine supported db_type
  rag_engine_db_type = "rag_managed_knn"

  # Resolve VPC connector ID: either existing or created from networking module
  resolved_vpc_connector_id = var.use_existing_network ? var.existing_connector_id : (var.enable_cloud_run ? module.networking[0].connector_id : null)

  # Resolve VPC network ID
  resolved_network = var.use_existing_network ? var.existing_network_name : module.networking[0].network_id
}

# Enable Required Google Cloud APIs
resource "google_project_service" "aiplatform" {
  project            = var.project_id
  service            = "aiplatform.googleapis.com"
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
resource "google_service_account" "agent_rag" {
  project      = var.project_id
  account_id   = "agent-rag-p14-sa"
  display_name = "Agentic RAG SA — ${var.display_name} (Private Pattern 14)"
}

resource "google_project_iam_member" "aiplatform_user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.agent_rag.email}"
}

# IAM: Restricted Invoker Access (Private Only)
resource "google_project_iam_member" "restricted_aiplatform_users" {
  for_each = toset(var.allowed_invoker_members)
  project  = var.project_id
  role     = "roles/aiplatform.user"
  member   = each.value
}

# Module: rag-engine (Underlying RAG Knowledge Base)
module "rag_engine" {
  source = "../../../modules/rag-engine"

  project_id   = var.project_id
  region       = var.region
  display_name = var.corpus_name
  description  = "RAG Knowledge Corpus for Vertex AI Reasoning Engine (Private)"
  db_type      = local.rag_engine_db_type

  depends_on = [
    google_project_service.aiplatform,
    google_service_account.agent_rag,
    google_project_iam_member.restricted_aiplatform_users,
    module.networking,
  ]
}

# Module: agent-runtime (Vertex AI Reasoning Engine)
module "agent_runtime" {
  source = "../../../modules/agent-runtime"

  project_id      = var.project_id
  region          = var.region
  display_name    = "${var.display_name}-reasoning-engine"
  description     = "Vertex AI Reasoning Engine agent with RAG knowledge grounding (Private)"
  agent_framework = var.agent_framework
  deployment_type = var.deployment_type
  labels          = var.labels

  class_methods   = var.class_methods

  source_code_config = {
    source_archive_gcs_uri = var.source_archive_gcs_uri
    requirements_gcs_uri   = var.requirements_gcs_uri
    python_version         = var.python_version
  }

  depends_on = [
    google_project_service.aiplatform,
    google_service_account.agent_rag,
    module.rag_engine,
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
    PROJECT_ID          = var.project_id
    REGION              = var.region
    REASONING_ENGINE_ID = module.agent_runtime.reasoning_engine_id
    RAG_CORPUS_ID       = module.rag_engine.corpus_id
    EMBEDDING_MODEL     = var.embedding_model
    GENERATION_MODEL    = var.generation_model
  }

  depends_on = [
    google_project_service.run,
    module.agent_runtime,
    module.rag_engine,
  ]
}
