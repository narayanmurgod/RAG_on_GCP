# pattern_13_AgenticRAG — Public Agentic Reasoning RAG Deployment
# Provisions Vertex AI Reasoning Engine agent runtime coupled with Vertex AI RAG Engine knowledge base, and optional Cloud Run serving service.

locals {
  service_name = "${var.display_name}-service"

  # Map vector_db_type to rag-engine supported db_type
  rag_engine_db_type = "rag_managed_knn"
}

# Enable Required Google Cloud APIs
resource "google_project_service" "aiplatform" {
  project            = var.project_id
  service            = "aiplatform.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "run" {
  count              = var.enable_cloud_run ? 1 : 0
  project            = var.project_id
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# IAM: Service Account & Core Roles
resource "google_service_account" "agent_rag" {
  project      = var.project_id
  account_id   = "agent-rag-p13-sa"
  display_name = "Agentic RAG SA — ${var.display_name} (Public Pattern 13)"
}

resource "google_project_iam_member" "aiplatform_user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.agent_rag.email}"
}

# Module: rag-engine (Underlying RAG Knowledge Base)
module "rag_engine" {
  source = "../../../modules/rag-engine"

  project_id   = var.project_id
  region       = var.region
  display_name = var.corpus_name
  description  = "RAG Knowledge Corpus for Vertex AI Reasoning Engine"
  db_type      = local.rag_engine_db_type

  depends_on = [
    google_project_service.aiplatform,
    google_service_account.agent_rag,
  ]
}

# Module: agent-runtime (Vertex AI Reasoning Engine)
module "agent_runtime" {
  source = "../../../modules/agent-runtime"

  project_id      = var.project_id
  region          = var.region
  display_name    = "${var.display_name}-reasoning-engine"
  description     = "Vertex AI Reasoning Engine agent with RAG knowledge grounding"
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
