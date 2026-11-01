# Input variables for pattern_7_CloudSQLRAG (Public)

# Core
variable "project_id" {
  type        = string
  description = "GCP Project ID hosting the Cloud SQL instance."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for all resources."
}

variable "display_name" {
  type        = string
  default     = "pattern7-cloudsql-rag"
  description = "Display name prefix for resources."
}

variable "labels" {
  type = map(string)
  default = {
    environment = "public"
    pattern     = "pattern-7-cloudsqlrag"
    managed-by  = "aip-terraform"
  }
  description = "Resource labels attached to all resources."
}

# Cloud SQL PostgreSQL Configuration
variable "instance_name" {
  type        = string
  default     = "pattern7-sql-instance"
  description = "Unique name for the Cloud SQL instance."
}

variable "database_version" {
  type        = string
  default     = "POSTGRES_16"
  description = "PostgreSQL version (e.g. POSTGRES_15, POSTGRES_16)."
}

variable "tier" {
  type        = string
  default     = "db-custom-2-7680"
  description = "Machine tier for the database."
}

variable "database_name" {
  type        = string
  default     = "rag_knowledge_db"
  description = "Name of the PostgreSQL database to create."
}

variable "user_name" {
  type        = string
  default     = "rag_app_user"
  description = "Username for application database user."
}

variable "user_password" {
  type        = string
  sensitive   = true
  description = "Password for application database user."
}

variable "deletion_protection" {
  type        = bool
  default     = false
  description = "Whether Terraform prevents accidental instance deletion."
}

# Cloud Storage Document Staging Bucket (Optional)
variable "create_staging_bucket" {
  type        = bool
  default     = false
  description = "Whether to create a Cloud Storage staging bucket for document uploads or dump imports."
}

variable "staging_bucket_name" {
  type        = string
  default     = ""
  description = "Name of the GCS bucket. If empty and create_staging_bucket is true, a name will be generated."
}

# Cloud Run Serving Layer (Optional)
variable "enable_cloud_run" {
  type        = bool
  default     = false
  description = "When true, deploys a Cloud Run FastAPI serving layer querying Cloud SQL."
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
