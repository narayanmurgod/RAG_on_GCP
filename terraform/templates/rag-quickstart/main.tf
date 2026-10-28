# Serverless RAG Quickstart root orchestration template

locals {
  # Naming conventions for Cloud Run service and RAG corpus
  service_name = "${var.display_name}-service"
  corpus_name  = "${var.display_name}-corpus"
}

# Enable required Google Cloud APIs for serverless RAG
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "aiplatform.googleapis.com",
    "storage.googleapis.com"
  ])

  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

# Serverless Vertex AI RAG Engine module (managed vector DB and staging bucket)
module "rag_engine" {
  source = "../../modules/rag-engine"

  project_id   = var.project_id
  region       = var.region
  display_name = local.corpus_name
  description  = "Serverless Quickstart RAG Corpus (${var.display_name})"
  db_type      = "rag_managed_knn"

  create_staging_bucket = true
  labels                = var.labels

  depends_on = [google_project_service.apis]
}

# Serverless Cloud Run FastAPI serving layer module
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

  # Pass environment variables for RAG corpus and model endpoints
  env_vars = {
    PROJECT_ID       = var.project_id
    REGION           = var.region
    RAG_CORPUS_NAME  = module.rag_engine.corpus_name
    EMBEDDING_MODEL  = var.embedding_model
    GENERATION_MODEL = var.generation_model
    STAGING_BUCKET   = module.rag_engine.staging_bucket_name
  }

  depends_on = [google_project_service.apis]
}
