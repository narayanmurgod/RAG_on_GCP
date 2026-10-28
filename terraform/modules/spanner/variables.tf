# Input variables for the Cloud Spanner RAG and Graph module

# GCP project ID hosting the Spanner instance
variable "project_id" {
  type        = string
  description = "GCP Project ID hosting the Cloud Spanner instance."
}

# Unique ID for the Cloud Spanner instance
variable "instance_id" {
  type        = string
  description = "Unique ID for the Cloud Spanner instance (lowercase letters, numbers, hyphens)."
}

# Human-readable display name for the instance
variable "display_name" {
  type        = string
  default     = ""
  description = "Display name for the Cloud Spanner instance. Defaults to instance_id if empty."
}

# Spanner instance regional or multi-regional location configuration
variable "config" {
  type        = string
  default     = "regional-us-central1"
  description = "Spanner instance configuration (e.g., regional-us-central1, regional-europe-west1, nam3 for multi-region)."
}

# Capacity allocated in processing units (1000 PUs = 1 node)
variable "processing_units" {
  type        = number
  default     = 100
  description = "Compute capacity allocated in processing units (100 to 1000 PUs, where 1000 PUs = 1 node). Mutually exclusive with num_nodes."

  validation {
    condition     = var.processing_units >= 100 && var.processing_units % 100 == 0
    error_message = "processing_units must be at least 100 and a multiple of 100."
  }
}

# Labels to assign to the Spanner instance
variable "labels" {
  type        = map(string)
  default     = {}
  description = "Resource labels attached to the Spanner instance."
}

# Whether to permit destruction of the instance and databases
variable "force_destroy" {
  type        = bool
  default     = false
  description = "When set to true, allows Terraform to delete the Spanner instance and its databases."
}

# Name of the Spanner database to create
variable "database_name" {
  type        = string
  default     = "rag_knowledge_db"
  description = "Name of the Spanner database to create for RAG knowledge storage."
}

# Point-in-time recovery retention period
variable "version_retention_period" {
  type        = string
  default     = "3d"
  description = "Retention period for point-in-time recovery (e.g. 1h, 3d, 7d)."
}

# Dimensionality of dense vector embeddings
variable "embedding_dimension" {
  type        = number
  default     = 768
  description = "Dimensionality of vector embeddings stored in Spanner (e.g., 768 for text-embedding-004)."
}

# Vector search distance metric
variable "distance_type" {
  type        = string
  default     = "COSINE"
  description = "Vector distance metric for Spanner Vector Index: COSINE | EUCLIDEAN | DOT_PRODUCT."

  validation {
    condition     = contains(["COSINE", "EUCLIDEAN", "DOT_PRODUCT"], var.distance_type)
    error_message = "distance_type must be one of: COSINE | EUCLIDEAN | DOT_PRODUCT."
  }
}

# Whether to create the vector search index
variable "enable_vector_index" {
  type        = bool
  default     = true
  description = "Whether to create a Spanner vector index on the documents table for ANN vector search."
}

# Whether to create Spanner Graph tables and schema
variable "enable_graph_rag" {
  type        = bool
  default     = true
  description = "Whether to create property graph tables and schema (Spanner Graph) for Graph RAG."
}

# Additional custom DDL statements to execute on database creation
variable "extra_ddl_statements" {
  type        = list(string)
  default     = []
  description = "Additional custom DDL statements to execute on database creation."
}

# Optional Cloud KMS key for customer-managed encryption (CMEK)
variable "kms_key_name" {
  type        = string
  default     = null
  description = "Optional Cloud KMS Key name for Customer-Managed Encryption Keys (CMEK)."
}

# Service accounts authorized to read and query the database
variable "authorized_service_accounts" {
  type        = list(string)
  default     = []
  description = "List of service account emails to grant roles/spanner.databaseUser access."
}
