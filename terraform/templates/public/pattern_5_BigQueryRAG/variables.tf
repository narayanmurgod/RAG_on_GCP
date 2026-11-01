# Input variables for pattern_5_BigQueryRAG (Public)

# Core
variable "project_id" {
  type        = string
  description = "GCP Project ID hosting BigQuery dataset and resources."
}

variable "location" {
  type        = string
  default     = "US"
  description = "Geographic location for BigQuery dataset (e.g. US, EU, us-central1)."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for regional resources like Cloud Run and staging GCS bucket."
}

variable "display_name" {
  type        = string
  default     = "pattern5-bigquery-rag"
  description = "Display name prefix for BigQuery RAG resources."
}

variable "labels" {
  type = map(string)
  default = {
    environment = "public"
    pattern     = "pattern-5-bigqueryrag"
    managed-by  = "aip-terraform"
  }
  description = "Resource labels attached to all resources."
}

# BigQuery Vector Search Configuration
variable "dataset_id" {
  type        = string
  default     = "pattern5_rag_dataset"
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
  description = "When true, deploys a Cloud Run FastAPI serving layer querying the BigQuery dataset."
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
