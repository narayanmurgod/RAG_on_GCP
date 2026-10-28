# Input variables for the Vertex AI RAG Engine module

# GCP project ID hosting the RAG Corpus
variable "project_id" {
  type        = string
  description = "GCP Project ID hosting the Vertex AI RAG Corpus."
}

# GCP region for the RAG Corpus
variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for Vertex AI RAG Corpus (e.g. us-central1, europe-west1)."
}

# Display name for the Vertex AI RAG Corpus
variable "display_name" {
  type        = string
  description = "Display name for the Vertex AI RAG Corpus."
}

# Detailed description of the RAG Corpus
variable "description" {
  type        = string
  default     = "Vertex AI Managed RAG Corpus deployed via AIP Terraform Module"
  description = "Description of the RAG Corpus."
}

# Vector database backend type for the RAG Corpus
variable "db_type" {
  type        = string
  default     = "rag_managed_knn"
  description = "Type of vector database backend for the RAG Corpus: rag_managed_knn, rag_managed_ann, or vertex_vector_search."

  validation {
    condition     = contains(["rag_managed_knn", "rag_managed_ann", "vertex_vector_search"], var.db_type)
    error_message = "db_type must be one of: rag_managed_knn | rag_managed_ann | vertex_vector_search."
  }
}

# Number of leaf nodes for tree-based approximate nearest neighbor search
variable "ann_leaf_count" {
  type        = number
  default     = 500
  description = "Number of leaf nodes in the tree-based structure for rag_managed_ann (default 500)."
}

# Tree depth for tree-based approximate nearest neighbor search
variable "ann_tree_depth" {
  type        = number
  default     = 2
  description = "Tree depth for rag_managed_ann (2 or 3 supported, default 2)."

  validation {
    condition     = contains([2, 3], var.ann_tree_depth)
    error_message = "ann_tree_depth must be either 2 or 3."
  }
}

# Resource name of an external Vertex AI Index if using vertex_vector_search
variable "vertex_vector_search_index" {
  type        = string
  default     = null
  description = "Resource name of the Vertex AI Index when db_type is vertex_vector_search (format: projects/{p}/locations/{l}/indexes/{i})."
}

# Resource name of an external Vertex AI Index Endpoint if using vertex_vector_search
variable "vertex_vector_search_endpoint" {
  type        = string
  default     = null
  description = "Resource name of the Vertex AI Index Endpoint when db_type is vertex_vector_search (format: projects/{p}/locations/{l}/indexEndpoints/{e})."
}

# Whether to create a Cloud Storage staging bucket for document ingestion
variable "create_staging_bucket" {
  type        = bool
  default     = true
  description = "Whether to create a Cloud Storage bucket for document ingestion into this RAG Corpus."
}

# Custom name for the Cloud Storage staging bucket
variable "staging_bucket_name" {
  type        = string
  default     = ""
  description = "Name of the GCS bucket. If empty and create_staging_bucket is true, a name will be generated."
}

# Resource labels attached to the staging bucket and corpus
variable "labels" {
  type        = map(string)
  default     = {}
  description = "Resource labels attached to the staging bucket and corpus."
}
