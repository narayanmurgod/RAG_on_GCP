# Input variables for the Serverless RAG Quickstart template

# GCP project ID where the quickstart RAG infrastructure will be deployed
variable "project_id" {
  type        = string
  description = "GCP Project ID where the quickstart RAG infrastructure will be deployed."
}

# GCP region for all quickstart resources
variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for all resources (e.g. us-central1, us-east4, europe-west1)."
}

# Display name prefix for all quickstart resources
variable "display_name" {
  type        = string
  default     = "rag-quickstart"
  description = "Base display name prefix for RAG quickstart resources."
}

# Container image URI for the FastAPI RAG microservice
variable "container_image" {
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
  description = "Container image URI for the FastAPI RAG microservice."
}

# Minimum instances for Cloud Run (0 enables serverless scale-to-zero)
variable "min_instances" {
  type        = number
  default     = 0
  description = "Minimum instances for Cloud Run (0 enables serverless scale-to-zero)."
}

# Maximum instances for Cloud Run autoscaling
variable "max_instances" {
  type        = number
  default     = 5
  description = "Maximum instances for Cloud Run autoscaling."
}

# Whether to allow public unauthenticated access to the endpoint
variable "allow_unauthenticated" {
  type        = bool
  default     = true
  description = "Allow public unauthenticated access to the Cloud Run endpoint."
}

# Vertex AI embedding model used for document vectorization
variable "embedding_model" {
  type        = string
  default     = "text-embedding-004"
  description = "Vertex AI embedding model used for document vectorization."
}

# Default Gemini model for response generation
variable "generation_model" {
  type        = string
  default     = "gemini-1.5-flash"
  description = "Default Gemini model for response generation."
}

# Resource labels attached to all quickstart resources
variable "labels" {
  type = map(string)
  default = {
    environment = "quickstart"
    managed-by  = "aip-terraform"
  }
  description = "Resource labels to attach to all resources."
}
