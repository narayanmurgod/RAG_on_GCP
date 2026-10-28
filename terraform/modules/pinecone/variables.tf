# Input variables for the Pinecone integration module

# GCP project ID hosting Secret Manager
variable "project_id" {
  type        = string
  description = "GCP Project ID hosting Secret Manager."
}

# Prefix for Pinecone secrets stored in Secret Manager
variable "secret_id_prefix" {
  type        = string
  default     = "pinecone"
  description = "Prefix for Pinecone secrets stored in Secret Manager."
}

# Pinecone API key
variable "api_key" {
  type        = string
  sensitive   = true
  description = "Pinecone API Key."
}

# Pinecone environment or cloud region
variable "environment" {
  type        = string
  default     = "us-east-1"
  description = "Pinecone environment or cloud region (e.g. us-east-1, us-central1)."
}

# Name of the Pinecone index
variable "index_name" {
  type        = string
  default     = "rag-knowledge-index"
  description = "Name of the Pinecone index."
}

# Service account emails authorized to read the secret
variable "authorized_service_accounts" {
  type        = list(string)
  default     = []
  description = "List of service account emails granted access to read the Pinecone API key."
}

# Labels attached to the secret
variable "labels" {
  type        = map(string)
  default     = {}
  description = "Labels attached to the secret."
}
