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
  default     = "GCP Agent Runtime — Private Deployment"
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
  description = "Set when deployment_type = 'source_code'."
}

variable "gcs_package_config" {
  type = object({
    pickle_gcs_uri       = string
    requirements_gcs_uri = string
    dependencies_gcs_uri = optional(string)
    python_version       = optional(string, "3.11")
  })
  default     = null
  description = "Set when deployment_type = 'gcs_package'."
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
  default = 1 # private deployments keep at least 1 instance warm
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
  default     = "agent-runtime-private-sa"
  description = "Service account ID created for the Agent Engine runtime."
}

variable "allowed_invoker_members" {
  type        = list(string)
  default     = []
  description = <<-EOT
    List of IAM members permitted to invoke the Vertex AI Agent Engine.
    Only these identities will be granted roles/aiplatform.user.

    Format: "serviceAccount:sa@project.iam.gserviceaccount.com"
             "user:user@example.com"
             "group:group@example.com"

    Leave empty to skip restricted invoker bindings (not recommended for private).
  EOT
}

# ── GCS Staging ───────────────────────────────────────────────────────────────

variable "staging_bucket_name" {
  type        = string
  description = "Name of the GCS bucket used to stage agent artifacts."
}

# ── Artifact Registry (BYOC only) ─────────────────────────────────────────────

variable "artifact_registry_repo_id" {
  type        = string
  default     = ""
  description = "Artifact Registry repository ID for BYOC deployments."
}

# ── Local artifact file paths ──────────────────────────────────────────────────

variable "local_source_archive_path" {
  type    = string
  default = ""
}

variable "local_requirements_path" {
  type    = string
  default = ""
}

variable "local_pickle_path" {
  type    = string
  default = ""
}

variable "local_dependencies_path" {
  type    = string
  default = ""
}
