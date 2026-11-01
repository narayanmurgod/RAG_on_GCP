# ── Core ──────────────────────────────────────────────────────────────────────

variable "project_id" {
  type        = string
  description = "GCP Project ID."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for all resources."
}

variable "display_name" {
  type        = string
  description = "Display name for the Vertex AI Reasoning Engine."
}

variable "description" {
  type        = string
  default     = "GCP Agent Runtime — Public Deployment"
  description = "Description for the Reasoning Engine resource."
}

variable "agent_framework" {
  type        = string
  default     = "google-adk"
  description = "Agent framework: google-adk | langchain | langgraph | llamaindex | custom"
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Labels applied to all GCP resources provisioned by this template."
}

# ── Deployment Type ───────────────────────────────────────────────────────────

variable "deployment_type" {
  type        = string
  description = "Agent runtime deployment type: source_code | gcs_package | byoc"
}

variable "source_code_config" {
  type = object({
    source_archive_gcs_uri = string
    requirements_gcs_uri   = string
    python_version         = optional(string, "3.11")
  })
  default     = null
  description = "Set when deployment_type = 'source_code'. GCS URIs for source archive and requirements."
}

variable "gcs_package_config" {
  type = object({
    pickle_gcs_uri       = string
    requirements_gcs_uri = string
    dependencies_gcs_uri = optional(string)
    python_version       = optional(string, "3.11")
  })
  default     = null
  description = "Set when deployment_type = 'gcs_package'. GCS URIs for pickled agent and requirements."
}

variable "byoc_config" {
  type = object({
    image_uri = string
  })
  default     = null
  description = "Set when deployment_type = 'byoc'. Image URI in Artifact Registry."
}

# ── Scaling & Runtime ─────────────────────────────────────────────────────────

variable "min_instances" {
  type    = number
  default = 0
}

variable "max_instances" {
  type    = number
  default = 5
}

variable "container_concurrency" {
  type    = number
  default = 10
}

variable "env_vars" {
  type    = map(string)
  default = {}
}

variable "resource_limits" {
  type = object({
    cpu    = optional(string, "2")
    memory = optional(string, "4Gi")
  })
  default = {}
}

variable "class_methods" {
  type = list(object({
    name        = string
    description = optional(string, "")
  }))
  default = [{ name = "query", description = "Send a query to the agent." }]
}

# ── IAM ───────────────────────────────────────────────────────────────────────

variable "service_account_id" {
  type        = string
  default     = "agent-runtime-sa"
  description = "Service account ID created for the Agent Engine runtime."
}

# ── GCS Staging ───────────────────────────────────────────────────────────────

variable "staging_bucket_name" {
  type        = string
  description = "Name of the GCS bucket used to stage agent artifacts (source archives, requirements, pickle files)."
}

# ── Artifact Registry (BYOC only) ─────────────────────────────────────────────

variable "artifact_registry_repo_id" {
  type        = string
  default     = ""
  description = "Artifact Registry repository ID for BYOC deployments. Leave empty if not using byoc."
}

# ── Local artifact file paths (uploaded to GCS by this template) ──────────────

variable "local_source_archive_path" {
  type        = string
  default     = ""
  description = "Local path to .tar.gz source archive. Used when deployment_type = 'source_code'."
}

variable "local_requirements_path" {
  type        = string
  default     = ""
  description = "Local path to requirements.txt. Used for source_code and gcs_package deployment types."
}

variable "local_pickle_path" {
  type        = string
  default     = ""
  description = "Local path to agent.pkl. Used when deployment_type = 'gcs_package'."
}

variable "local_dependencies_path" {
  type        = string
  default     = ""
  description = "Local path to dependencies.tar.gz (optional). Used when deployment_type = 'gcs_package'."
}
