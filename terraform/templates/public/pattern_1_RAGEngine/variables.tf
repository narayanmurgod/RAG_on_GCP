# Input variables for pattern_1_RAGEngine (Public)

# ── Core ──────────────────────────────────────────────────────────────────────

variable "project_id" {
  type        = string
  description = "GCP Project ID where the RAG Engine infrastructure will be deployed."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for all resources (e.g. us-central1, us-east4, europe-west1)."
}

variable "display_name" {
  type        = string
  default     = "pattern1-rag-engine"
  description = "Base display name prefix for RAG Engine resources."
}

variable "description" {
  type        = string
  default     = "Vertex AI RAG Engine — Public Pattern 1 (pattern_1_RAGEngine)"
  description = "Description for the RAG Corpus."
}

variable "labels" {
  type = map(string)
  default = {
    environment = "public"
    pattern     = "pattern-1-ragengine"
    managed-by  = "aip-terraform"
  }
  description = "Resource labels attached to all resources."
}

# ── Vector Database Selection ─────────────────────────────────────────────────

variable "vector_db_type" {
  type        = string
  default     = "rag_managed_knn"
  description = "Vector database backend: rag_managed_knn | rag_managed_ann | vertex_vector_search | pinecone | weaviate"

  validation {
    condition     = contains(["rag_managed_knn", "rag_managed_ann", "vertex_vector_search", "pinecone", "weaviate"], var.vector_db_type)
    error_message = "vector_db_type must be one of: rag_managed_knn | rag_managed_ann | vertex_vector_search | pinecone | weaviate."
  }
}

variable "ann_leaf_count" {
  type        = number
  default     = 500
  description = "Number of leaf nodes for rag_managed_ann."
}

variable "ann_tree_depth" {
  type        = number
  default     = 2
  description = "Tree depth for rag_managed_ann (2 or 3)."
}

# ── Staging Bucket ────────────────────────────────────────────────────────────

variable "create_staging_bucket" {
  type        = bool
  default     = true
  description = "Whether to create a GCS bucket for document ingestion into the RAG Corpus."
}

variable "staging_bucket_name" {
  type        = string
  default     = ""
  description = "Custom GCS bucket name. If empty and create_staging_bucket = true, a name is auto-generated."
}

# ── Vertex Vector Search (when vector_db_type = "vertex_vector_search") ───────

variable "vs_dimensions" {
  type        = number
  default     = 768
  description = "Dimensions for Vertex Vector Search index."
}

variable "vs_algorithm" {
  type        = string
  default     = "tree_ah"
  description = "Algorithm for index: tree_ah | brute_force."
}

variable "vs_distance_measure" {
  type        = string
  default     = "DOT_PRODUCT_DISTANCE"
  description = "Distance measure type for Vector Search."
}

variable "vs_machine_type" {
  type        = string
  default     = "e2-standard-2"
  description = "Machine type for deployed index endpoint."
}

variable "vs_min_replicas" {
  type        = number
  default     = 1
  description = "Minimum replicas for deployed index."
}

variable "vs_max_replicas" {
  type        = number
  default     = 3
  description = "Maximum replicas for deployed index."
}

# ── Pinecone (when vector_db_type = "pinecone") ───────────────────────────────

variable "pinecone_api_key" {
  type        = string
  sensitive   = true
  default     = ""
  description = "Pinecone API Key."
}

variable "pinecone_environment" {
  type        = string
  default     = "us-east-1"
  description = "Pinecone cloud environment / region."
}

variable "pinecone_index_name" {
  type        = string
  default     = "rag-knowledge-index"
  description = "Name of the Pinecone index."
}

# ── Weaviate (when vector_db_type = "weaviate") ───────────────────────────────

variable "weaviate_api_key" {
  type        = string
  sensitive   = true
  default     = ""
  description = "Weaviate API Key."
}

variable "weaviate_cluster_url" {
  type        = string
  sensitive   = true
  default     = ""
  description = "Weaviate cluster endpoint URL."
}

variable "weaviate_collection" {
  type        = string
  default     = "RAGCollection"
  description = "Weaviate class / collection name."
}

# ── Cloud Run Serving Layer (Optional) ────────────────────────────────────────

variable "enable_cloud_run" {
  type        = bool
  default     = false
  description = "When true, deploys a Cloud Run FastAPI serving layer on top of the RAG Corpus."
}

variable "container_image" {
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
  description = "Container image URI for the FastAPI RAG microservice. Required when enable_cloud_run = true."
}

variable "min_instances" {
  type        = number
  default     = 0
  description = "Minimum Cloud Run instances (0 = scale-to-zero). Used when enable_cloud_run = true."
}

variable "max_instances" {
  type        = number
  default     = 5
  description = "Maximum Cloud Run instances for autoscaling. Used when enable_cloud_run = true."
}

variable "allow_unauthenticated" {
  type        = bool
  default     = true
  description = "Allow public unauthenticated invocations to the Cloud Run endpoint."
}

variable "embedding_model" {
  type        = string
  default     = "text-embedding-004"
  description = "Vertex AI embedding model passed as an env var to Cloud Run."
}

variable "generation_model" {
  type        = string
  default     = "gemini-1.5-flash"
  description = "Gemini model for response generation passed as an env var to Cloud Run."
}
