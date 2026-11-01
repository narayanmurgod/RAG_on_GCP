# Input variables for pattern_6_BigQueryRAG (Private)

# Core
variable "project_id" {
  type        = string
  description = "GCP Project ID hosting private BigQuery dataset and resources."
}

variable "location" {
  type        = string
  default     = "US"
  description = "Geographic location for BigQuery dataset (e.g. US, EU, us-central1)."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for regional resources like private Cloud Run, VPC connector, and staging bucket."
}

variable "display_name" {
  type        = string
  default     = "pattern6-bigquery-rag"
  description = "Display name prefix for private BigQuery RAG resources."
}

variable "labels" {
  type = map(string)
  default = {
    environment = "private"
    pattern     = "pattern-6-bigqueryrag"
    managed-by  = "aip-terraform"
  }
  description = "Resource labels attached to all resources."
}

# IAM & Access Control
variable "allowed_invoker_members" {
  type        = list(string)
  default     = []
  description = "List of IAM identities granted BigQuery data viewer and job user permissions."
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
  default     = "rag-bq-private-vpc"
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

# BigQuery Vector Search Configuration
variable "dataset_id" {
  type        = string
  default     = "pattern6_rag_dataset"
  description = "Unique ID for BigQuery dataset."
}

variable "table_id" {
  type        = string
  default     = "rag_documents"
  description = "Name of the BigQuery table storing document text and vector embeddings."
}

variable "delete_contents_on_destroy" {
  type        = bool
  default     = false
  description = "Whether to delete all tables in the dataset when destroying the dataset."
}

# Cloud Storage Document Staging Bucket (Optional)
variable "create_staging_bucket" {
  type        = bool
  default     = false
  description = "Whether to create a Cloud Storage staging bucket for batch uploading documents or embeddings."
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
  description = "When true, deploys a private Cloud Run FastAPI serving layer querying the BigQuery dataset."
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
