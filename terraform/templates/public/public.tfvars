# ─────────────────────────────────────────────────────────────────────────────
# public.tfvars — Agent Runtime: Public Deployment
#
# Usage:
#   terraform init
#   terraform plan  -var-file="public.tfvars"
#   terraform apply -var-file="public.tfvars"
#
# Only ONE deployment_type block should be uncommented at a time.
# ─────────────────────────────────────────────────────────────────────────────

# ── Core ──────────────────────────────────────────────────────────────────────
project_id   = "my-gcp-project"
region       = "us-central1"
display_name = "enterprise-rag-agent-public"
description  = "Enterprise RAG Agent — Public Deployment"

labels = {
  environment = "public"
  team        = "platform-engineering"
  managed-by  = "terraform"
}

# ── Agent Runtime ─────────────────────────────────────────────────────────────
agent_framework = "google-adk"

# ── Deployment Type: source_code ──────────────────────────────────────────────
# Uncomment this block and set deployment_type = "source_code"
# to deploy from a .tar.gz source archive hosted on GCS.

deployment_type     = "source_code"
staging_bucket_name = "my-gcp-project-agent-staging-public"

local_source_archive_path = "./artifacts/agent_source.tar.gz"
local_requirements_path   = "./artifacts/requirements.txt"

source_code_config = {
  # GCS URIs are auto-derived from staging_bucket_name — no need to change these.
  source_archive_gcs_uri = "" # computed by main.tf locals
  requirements_gcs_uri   = "" # computed by main.tf locals
  python_version         = "3.11"
}

# ── Deployment Type: gcs_package ──────────────────────────────────────────────
# Uncomment this block and set deployment_type = "gcs_package"
# to deploy from a pre-pickled agent.pkl on GCS.

# deployment_type     = "gcs_package"
# staging_bucket_name = "my-gcp-project-agent-staging-public"

# local_pickle_path         = "./artifacts/agent.pkl"
# local_requirements_path   = "./artifacts/requirements.txt"
# local_dependencies_path   = "./artifacts/dependencies.tar.gz"  # optional

# gcs_package_config = {
#   pickle_gcs_uri       = ""  # computed by main.tf locals
#   requirements_gcs_uri = ""  # computed by main.tf locals
#   dependencies_gcs_uri = null
#   python_version       = "3.11"
# }

# ── Deployment Type: byoc ─────────────────────────────────────────────────────
# Uncomment this block and set deployment_type = "byoc"
# to deploy from a custom Docker image in Artifact Registry.
# The image must be pushed BEFORE terraform apply.

# deployment_type           = "byoc"
# staging_bucket_name       = "my-gcp-project-agent-staging-public"   # still needed for other resources
# artifact_registry_repo_id = "agents"

# byoc_config = {
#   image_uri = "us-central1-docker.pkg.dev/my-gcp-project/agents/my-agent:v1.0.0"
# }

# resource_limits = {
#   cpu    = "4"
#   memory = "8Gi"
# }

# ── Scaling ───────────────────────────────────────────────────────────────────
min_instances         = 0
max_instances         = 5
container_concurrency = 10

# ── Environment Variables ─────────────────────────────────────────────────────
env_vars = {
  MODEL_NAME  = "gemini-2.5-flash"
  ENVIRONMENT = "public"
  LOG_LEVEL   = "INFO"
}

# ── IAM ───────────────────────────────────────────────────────────────────────
service_account_id = "agent-runtime-public-sa"

# ── Agent Interface ───────────────────────────────────────────────────────────
class_methods = [
  {
    name        = "query"
    description = "Send a query to the agent."
  }
]
