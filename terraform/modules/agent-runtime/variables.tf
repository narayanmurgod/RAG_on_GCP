# ── Core ──────────────────────────────────────────────────────────────────────

variable "project_id" {
  type        = string
  description = "GCP Project ID where the Vertex AI Reasoning Engine will be deployed."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for Vertex AI Agent Engine. Must support Reasoning Engine (us-central1 is GA)."
}

variable "display_name" {
  type        = string
  description = "Human-readable display name for the Reasoning Engine resource."
}

variable "description" {
  type        = string
  default     = "GCP Agent Runtime deployed via AIP Terraform Module"
  description = "Description attached to the Reasoning Engine resource."
}

variable "agent_framework" {
  type        = string
  default     = "google-adk"
  description = "Agent framework tag. Controls the managed runtime environment selected by Vertex AI."

  validation {
    condition     = contains(["google-adk", "langchain", "langgraph", "llamaindex", "custom"], var.agent_framework)
    error_message = "agent_framework must be one of: google-adk | langchain | langgraph | llamaindex | custom."
  }
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "GCP resource labels to apply to the Reasoning Engine."
}

# ── Deployment Type ───────────────────────────────────────────────────────────

variable "deployment_type" {
  type        = string
  description = <<-EOT
    Controls which Vertex AI Agent Engine packaging model is used. Exactly one
    of the corresponding config objects (source_code_config / gcs_package_config
    / byoc_config) must be populated in the calling .tfvars file.

    Options:
      source_code  — GCS-hosted .tar.gz source archive + requirements.txt.
      gcs_package  — GCS-hosted pre-pickled agent.pkl + requirements.
      byoc         — Bring Your Own Container image from Artifact Registry.
  EOT

  validation {
    condition     = contains(["source_code", "gcs_package", "byoc"], var.deployment_type)
    error_message = "deployment_type must be one of: source_code | gcs_package | byoc."
  }
}

# ── source_code Config ────────────────────────────────────────────────────────

variable "source_code_config" {
  type = object({
    source_archive_gcs_uri = string # gs://bucket/path/agent_source.tar.gz
    requirements_gcs_uri   = string # gs://bucket/path/requirements.txt
    python_version         = optional(string, "3.11")
  })
  default     = null
  description = "Required when deployment_type = 'source_code'. GCS URIs created by the calling template."
}

# ── gcs_package Config ────────────────────────────────────────────────────────

variable "gcs_package_config" {
  type = object({
    pickle_gcs_uri       = string           # gs://bucket/path/agent.pkl
    requirements_gcs_uri = string           # gs://bucket/path/requirements.txt
    dependencies_gcs_uri = optional(string) # gs://bucket/path/dependencies.tar.gz
    python_version       = optional(string, "3.11")
  })
  default     = null
  description = "Required when deployment_type = 'gcs_package'. GCS URIs created by the calling template."
}

# ── byoc Config ───────────────────────────────────────────────────────────────

variable "byoc_config" {
  type = object({
    image_uri = string # e.g. us-central1-docker.pkg.dev/project/repo/image:tag
  })
  default     = null
  description = "Required when deployment_type = 'byoc'. Image URI in Artifact Registry. Image must be pushed before terraform apply."
}

# ── Scaling & Runtime ─────────────────────────────────────────────────────────

variable "min_instances" {
  type        = number
  default     = 0
  description = "Minimum number of running instances. Set to 0 for scale-to-zero (recommended for dev/test)."
}

variable "max_instances" {
  type        = number
  default     = 3
  description = "Maximum number of running instances for autoscaling."
}

variable "container_concurrency" {
  type        = number
  default     = 10
  description = "Maximum number of concurrent requests handled per instance."
}

variable "env_vars" {
  type        = map(string)
  default     = {}
  description = "Environment variables injected into the agent runtime container at startup."
}

variable "resource_limits" {
  type = object({
    cpu    = optional(string, "2")
    memory = optional(string, "4Gi")
  })
  default     = {}
  description = "CPU and memory resource limits per instance. Applies to byoc deployment type."
}

# ── Agent Interface ───────────────────────────────────────────────────────────

variable "class_methods" {
  type = list(object({
    name        = string
    description = optional(string, "")
  }))
  default = [
    {
      name        = "query"
      description = "Send a query to the agent."
    }
  ]
  description = "List of methods exposed by the agent class interface (used by the Reasoning Engine SDK)."
}
