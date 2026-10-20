# ── Core ──────────────────────────────────────────────────────────────────────

variable "project_id" {
  type        = string
  description = "GCP Project ID."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for all resources."
}

variable "display_name" {
  type        = string
  description = "Display name for the Vertex AI Vector Search Index."
}

variable "description" {
  type        = string
  default     = "Vertex AI Vector Search — Public Endpoint Deployment"
  description = "Description for the Vector Search resources."
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Labels applied to all GCP resources provisioned by this template."
}

# ── Storage & Ingestion ───────────────────────────────────────────────────────

variable "create_staging_bucket" {
  type        = bool
  default     = true
  description = "Whether to create a Cloud Storage bucket for embeddings ingestion and batch data drops."
}

variable "staging_bucket_name" {
  type        = string
  default     = ""
  description = "Globally unique name for the staging GCS bucket. If empty and create_staging_bucket is true, one is derived."
}

# ── Service Account ───────────────────────────────────────────────────────────

variable "service_account_id" {
  type        = string
  default     = "vertex-vector-search-sa"
  description = "Account ID for the dedicated service account managing vector operations."
}

# ── Index Configuration ───────────────────────────────────────────────────────

variable "dimensions" {
  type        = number
  default     = 768
  description = "Dimensionality of vector embeddings (e.g. 768 for text-embedding-004)."
}

variable "approximate_neighbors_count" {
  type        = number
  default     = 150
  description = "Default number of approximate nearest neighbors returned."
}

variable "distance_measure_type" {
  type        = string
  default     = "DOT_PRODUCT_DISTANCE"
  description = "Distance measure: DOT_PRODUCT_DISTANCE | COSINE_DISTANCE | SQUARED_L2_DISTANCE."
}

variable "shard_size" {
  type        = string
  default     = "SHARD_SIZE_SMALL"
  description = "Index shard size: SHARD_SIZE_SMALL | SHARD_SIZE_MEDIUM | SHARD_SIZE_LARGE."
}

variable "algorithm" {
  type        = string
  default     = "tree_ah"
  description = "Algorithm: tree_ah (Tree-AH approximate search) | brute_force (exact search)."
}

variable "index_update_method" {
  type        = string
  default     = "STREAM_UPDATE"
  description = "Index update method: STREAM_UPDATE | BATCH_UPDATE."
}

variable "contents_delta_uri" {
  type        = string
  default     = null
  description = "Optional GCS URI containing initial embeddings data (e.g., gs://my-bucket/embeddings)."
}

# ── Deployment & Hardware Sizing ──────────────────────────────────────────────

variable "deploy_index" {
  type        = bool
  default     = true
  description = "Whether to deploy the index to the index endpoint immediately."
}

variable "deployed_index_id" {
  type        = string
  default     = ""
  description = "Custom ID for the deployed index."
}

variable "machine_type" {
  type        = string
  default     = "e2-standard-16"
  description = "Machine type for the deployed index nodes (e2-standard-16, e2-standard-2, etc.)."
}

variable "min_replicas" {
  type        = number
  default     = 1
  description = "Minimum node replicas for autoscaling."
}

variable "max_replicas" {
  type        = number
  default     = 2
  description = "Maximum node replicas for autoscaling."
}
