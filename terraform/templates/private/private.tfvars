# ─────────────────────────────────────────────────────────────────────────────
# private.tfvars — Agent Runtime: Private Deployment
#
# Usage:
#   terraform init
#   terraform plan  -var-file="private.tfvars"
#   terraform apply -var-file="private.tfvars"
#
# In private mode, only identities explicitly listed in allowed_invoker_members
# are granted roles/aiplatform.user. All other caller identities are denied.
# Only ONE deployment_type block should be active at a time.
# ─────────────────────────────────────────────────────────────────────────────

# ── Core ──────────────────────────────────────────────────────────────────────
project_id   = "my-gcp-project"
region       = "us-central1"
display_name = "enterprise-rag-agent-private"
description  = "Enterprise RAG Agent — Private Deployment with Restricted IAM Invokers"

labels = {
  environment = "private"
  team        = "platform-engineering"
  managed-by  = "terraform"
}

# ── Agent Runtime ─────────────────────────────────────────────────────────────
agent_framework = "google-adk"

# ── Deployment Type: source_code ──────────────────────────────────────────────
# Active by default: deploy from a .tar.gz source archive hosted on GCS.

deployment_type     = "source_code"
staging_bucket_name = "my-gcp-project-agent-staging-private"

local_source_archive_path = "./artifacts/agent_source.tar.gz"
local_requirements_path   = "./artifacts/requirements.txt"

source_code_config = {
  source_archive_gcs_uri = "" # computed by main.tf locals
  requirements_gcs_uri   = "" # computed by main.tf locals
  python_version         = "3.11"
}

# ── Deployment Type: gcs_package ──────────────────────────────────────────────
# Uncomment to deploy from a pre-pickled agent.pkl on GCS.

# deployment_type     = "gcs_package"
# staging_bucket_name = "my-gcp-project-agent-staging-private"

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
# Uncomment to deploy a custom container image from Artifact Registry.
# The container image must be pushed BEFORE running terraform apply.

# deployment_type           = "byoc"
# staging_bucket_name       = "my-gcp-project-agent-staging-private"
# artifact_registry_repo_id = "agents-private"

# byoc_config = {
#   image_uri = "us-central1-docker.pkg.dev/my-gcp-project/agents-private/my-agent:v1.0.0"
# }

# resource_limits = {
#   cpu    = "4"
#   memory = "8Gi"
# }

# ── Scaling (Private keeps >= 1 warm instance for low latency) ───────────────
min_instances         = 1
max_instances         = 5
container_concurrency = 10

# ── Environment Variables ─────────────────────────────────────────────────────
env_vars = {
  MODEL_NAME  = "gemini-2.5-flash"
  ENVIRONMENT = "private"
  LOG_LEVEL   = "INFO"
}

# ── IAM & Access Control ──────────────────────────────────────────────────────
service_account_id = "agent-runtime-private-sa"

# In private mode, only these identities can invoke the Reasoning Engine:
allowed_invoker_members = [
  "serviceAccount:backend-api-sa@my-gcp-project.iam.gserviceaccount.com"
]

# ── Agent Interface ───────────────────────────────────────────────────────────
class_methods = [
  {
    name        = "query"
    description = "Send a query to the agent."
  }
]
