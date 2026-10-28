# Input variables for the Enterprise Cloud Spanner RAG template

# GCP project ID hosting the enterprise RAG infrastructure
variable "project_id" {
  type        = string
  description = "GCP Project ID hosting the enterprise RAG infrastructure."
}

# Primary GCP region for enterprise resources
variable "region" {
  type        = string
  default     = "us-central1"
  description = "Primary GCP region for resources (e.g. us-central1, europe-west1)."
}

# Base display name prefix for enterprise RAG resources
variable "display_name" {
  type        = string
  default     = "rag-enterprise"
  description = "Display name prefix for enterprise RAG resources."
}

# Spanner instance regional or multi-regional location configuration
variable "spanner_config" {
  type        = string
  default     = "regional-us-central1"
  description = "Spanner instance configuration (e.g. regional-us-central1, nam3)."
}

# Spanner capacity allocated in processing units (1000 PUs = 1 node)
variable "spanner_processing_units" {
  type        = number
  default     = 100
  description = "Spanner capacity in processing units (100 to 1000 PUs)."
}

# Database name within the Spanner instance
variable "spanner_database_name" {
  type        = string
  default     = "rag_knowledge_db"
  description = "Name of the Spanner database."
}

# Dimensionality of dense vector embeddings
variable "embedding_dimension" {
  type        = number
  default     = 768
  description = "Embedding vector dimensions for Spanner Vector Search (e.g. 768 for text-embedding-004)."
}

# Vector search distance metric for Spanner Vector Search
variable "spanner_distance_type" {
  type        = string
  default     = "COSINE"
  description = "Distance metric for Spanner Vector Search: COSINE | EUCLIDEAN | DOT_PRODUCT."
}

# Whether to create property graph tables and schema for Spanner Graph RAG
variable "enable_spanner_graph_rag" {
  type        = bool
  default     = true
  description = "Whether to create property graph tables and schema for Spanner Graph RAG."
}

# Name of the dedicated enterprise VPC network
variable "network_name" {
  type        = string
  default     = "rag-enterprise-vpc"
  description = "Name of the enterprise private VPC."
}

# CIDR block for the application compute and database subnet
variable "app_subnet_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "CIDR block for the application subnet."
}

# Dedicated /28 CIDR block for the Serverless VPC Access connector
variable "connector_cidr" {
  type        = string
  default     = "10.8.0.0/28"
  description = "Dedicated /28 CIDR block for the Serverless VPC Access connector."
}

# Container image URI for the FastAPI RAG microservice
variable "container_image" {
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
  description = "Container image URI for the FastAPI RAG microservice."
}

# Minimum warm instances for enterprise low latency
variable "min_instances" {
  type        = number
  default     = 1
  description = "Minimum warm instances for enterprise low latency (default 1)."
}

# Maximum instances for Cloud Run autoscaling under load
variable "max_instances" {
  type        = number
  default     = 10
  description = "Maximum instances for autoscaling under load."
}

# Whether to permit unauthenticated invocations (recommended false for enterprise)
variable "allow_unauthenticated" {
  type        = bool
  default     = false
  description = "Whether to permit unauthenticated invocations (recommended false for enterprise)."
}

# Vertex AI embedding model identifier
variable "embedding_model" {
  type        = string
  default     = "text-embedding-004"
  description = "Vertex AI embedding model identifier."
}

# Gemini model identifier for enterprise reasoning and generation
variable "generation_model" {
  type        = string
  default     = "gemini-1.5-pro"
  description = "Gemini model identifier for enterprise reasoning & generation."
}

# Resource labels attached to all enterprise resources
variable "labels" {
  type = map(string)
  default = {
    environment = "enterprise"
    managed-by  = "aip-terraform"
  }
  description = "Resource labels attached to all enterprise resources."
}
