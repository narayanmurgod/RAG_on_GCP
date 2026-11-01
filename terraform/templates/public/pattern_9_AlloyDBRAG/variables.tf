# Input variables for pattern_9_AlloyDBRAG (Public)

# Core
variable "project_id" {
  type        = string
  description = "GCP Project ID hosting AlloyDB resources."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for all resources."
}

variable "display_name" {
  type        = string
  default     = "pattern9-alloydb-rag"
  description = "Display name prefix for resources."
}

variable "labels" {
  type = map(string)
  default = {
    environment = "public"
    pattern     = "pattern-9-alloydbrag"
    managed-by  = "aip-terraform"
  }
  description = "Resource labels attached to all resources."
}

# AlloyDB Configuration
variable "cluster_id" {
  type        = string
  default     = "pattern9-alloydb-cluster"
  description = "Unique ID for the AlloyDB cluster."
}

variable "network_id" {
  type        = string
  description = "VPC Network ID (e.g., projects/{project}/global/networks/{network}) for AlloyDB private connectivity."
}

variable "initial_user_password" {
  type        = string
  sensitive   = true
  description = "Password for the initial postgres administrative user."
}

variable "instance_id" {
  type        = string
  default     = "primary-instance"
  description = "Instance ID for primary AlloyDB instance."
}

variable "cpu_count" {
  type        = number
  default     = 2
  description = "Number of vCPUs for primary instance (2, 4, 8, 16, 32, 64, 128)."
}

variable "database_flags" {
  type        = map(string)
  default     = {}
  description = "PostgreSQL configuration flags for vector indexing and ScaNN."
}

# Cloud Run Serving Layer (Optional)
variable "enable_cloud_run" {
  type        = bool
  default     = false
  description = "When true, deploys a Cloud Run FastAPI serving layer querying AlloyDB."
}

variable "container_image" {
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
  description = "Container image URI for Cloud Run."
}

variable "min_instances" {
  type        = number
  default     = 0
  description = "Minimum instances for Cloud Run (0 enables scale-to-zero)."
}

variable "max_instances" {
  type        = number
  default     = 5
  description = "Maximum instances for Cloud Run autoscaling."
}

variable "allow_unauthenticated" {
  type        = bool
  default     = true
  description = "Allow public unauthenticated access to the Cloud Run endpoint."
}

variable "embedding_model" {
  type        = string
  default     = "text-embedding-004"
  description = "Vertex AI embedding model passed as env var to Cloud Run."
}

variable "generation_model" {
  type        = string
  default     = "gemini-1.5-flash"
  description = "Gemini model passed as env var to Cloud Run."
}
