# Input variables for pattern_8_CloudSQLRAG (Private)

# Core
variable "project_id" {
  type        = string
  description = "GCP Project ID hosting the private Cloud SQL instance."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for all resources."
}

variable "display_name" {
  type        = string
  default     = "pattern8-cloudsql-rag"
  description = "Display name prefix for private resources."
}

variable "labels" {
  type = map(string)
  default = {
    environment = "private"
    pattern     = "pattern-8-cloudsqlrag"
    managed-by  = "aip-terraform"
  }
  description = "Resource labels attached to all resources."
}

# IAM & Access Control
variable "allowed_invoker_members" {
  type        = list(string)
  default     = []
  description = "List of IAM identities granted Cloud SQL client and instance user permissions."
}

# Networking Configuration
variable "use_existing_network" {
  type        = bool
  default     = false
  description = "If true, connects to existing VPC and connector. If false, provisions new VPC via networking module."
}

# Parameters for creating a new network (when use_existing_network = false)
variable "network_name" {
  type        = string
  default     = "rag-sql-private-vpc"
  description = "Name of the new VPC network to create."
}

variable "app_subnet_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "CIDR range for application subnet."
}

variable "connector_cidr" {
  type        = string
  default     = "10.8.0.0/28"
  description = "CIDR range for Serverless VPC Access connector (/28 required)."
}

variable "enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Whether to create Cloud NAT for outbound internet egress from the private VPC."
}

# Parameters for referencing an existing network (when use_existing_network = true)
variable "existing_network_name" {
  type        = string
  default     = ""
  description = "Name of existing VPC network (required when use_existing_network = true)."
}

variable "existing_connector_id" {
  type        = string
  default     = ""
  description = "Resource ID of existing Serverless VPC Access Connector."
}

# Cloud SQL PostgreSQL Configuration
variable "instance_name" {
  type        = string
  default     = "pattern8-sql-instance"
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
  description = "When true, deploys a private Cloud Run FastAPI serving layer querying Cloud SQL."
}

variable "container_image" {
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
  description = "Container image URI for Cloud Run."
}

variable "min_instances" {
  type        = number
  default     = 1
  description = "Minimum instances for Cloud Run (kept warm for private SLA)."
}

variable "max_instances" {
  type        = number
  default     = 5
  description = "Maximum instances for Cloud Run autoscaling."
}

variable "embedding_model" {
  type        = string
  default     = "text-embedding-004"
  description = "Vertex AI embedding model passed as env var to Cloud Run."
}

variable "generation_model" {
  type        = string
  default     = "gemini-1.5-pro"
  description = "Gemini model passed as env var to Cloud Run."
}
