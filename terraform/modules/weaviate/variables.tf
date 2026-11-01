# Input variables for the Weaviate integration module

# GCP project ID hosting Secret Manager
variable "project_id" {
  type        = string
  description = "GCP Project ID hosting Secret Manager."
}

# Prefix for Weaviate secrets stored in Secret Manager
variable "secret_id_prefix" {
  type        = string
  default     = "weaviate"
  description = "Prefix for Weaviate secrets stored in Secret Manager."
}

# Weaviate API key
variable "api_key" {
  type        = string
  sensitive   = true
  description = "Weaviate API Key."
}

# Weaviate cluster URL or endpoint
variable "cluster_url" {
  type        = string
  sensitive   = true
  description = "Weaviate cluster endpoint URL (e.g. https://my-cluster.weaviate.cloud)."
}

# Target Weaviate collection or class name
variable "collection_name" {
  type        = string
  default     = "RAGCollection"
  description = "Name of the Weaviate collection or class."
}

# Service account emails authorized to read the secret
variable "authorized_service_accounts" {
  type        = list(string)
  default     = []
  description = "List of service account emails granted access to read the Weaviate secrets."
}

# Labels attached to the secret
variable "labels" {
  type        = map(string)
  default     = {}
  description = "Labels attached to the secret."
}
