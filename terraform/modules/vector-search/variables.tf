# ── Core Variables ─────────────────────────────────────────────────────────────

variable "project_id" {
  type        = string
  description = "GCP Project ID where the Vertex AI Vector Search resources will be deployed."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for Vertex AI Vector Search (e.g., us-central1, us-east4, europe-west1)."
}

variable "display_name" {
  type        = string
  description = "Display name for the Vertex AI Vector Search Index."
}

variable "description" {
  type        = string
  default     = "Vertex AI Vector Search Index deployed via AIP Terraform Module"
  description = "Description for the Vertex AI Vector Search Index."
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "GCP resource labels to attach to the Index and Index Endpoint."
}

# ── Index Configuration ───────────────────────────────────────────────────────

variable "dimensions" {
  type        = number
  default     = 768
  description = "Dimensionality of vector embeddings. Matches embedding model (e.g. 768 for text-embedding-004, 1536 for OpenAI, etc.)."

  validation {
    condition     = var.dimensions > 0 && var.dimensions <= 4096
    error_message = "dimensions must be a positive integer between 1 and 4096."
  }
}

variable "approximate_neighbors_count" {
  type        = number
  default     = 150
  description = "Default number of approximate nearest neighbors to return in search queries."
}

variable "distance_measure_type" {
  type        = string
  default     = "DOT_PRODUCT_DISTANCE"
  description = "Distance measure used for nearest neighbor calculations: DOT_PRODUCT_DISTANCE, COSINE_DISTANCE, or SQUARED_L2_DISTANCE."

  validation {
    condition     = contains(["DOT_PRODUCT_DISTANCE", "COSINE_DISTANCE", "SQUARED_L2_DISTANCE"], var.distance_measure_type)
    error_message = "distance_measure_type must be one of: DOT_PRODUCT_DISTANCE | COSINE_DISTANCE | SQUARED_L2_DISTANCE."
  }
}

variable "feature_norm_type" {
  type        = string
  default     = "NONE"
  description = "Type of normalization to apply: NONE or UNIT_L2_NORM."

  validation {
    condition     = contains(["NONE", "UNIT_L2_NORM"], var.feature_norm_type)
    error_message = "feature_norm_type must be one of: NONE | UNIT_L2_NORM."
  }
}

variable "shard_size" {
  type        = string
  default     = "SHARD_SIZE_SMALL"
  description = "Size of each shard in the index: SHARD_SIZE_SMALL, SHARD_SIZE_MEDIUM, or SHARD_SIZE_LARGE."

  validation {
    condition     = contains(["SHARD_SIZE_SMALL", "SHARD_SIZE_MEDIUM", "SHARD_SIZE_LARGE"], var.shard_size)
    error_message = "shard_size must be one of: SHARD_SIZE_SMALL | SHARD_SIZE_MEDIUM | SHARD_SIZE_LARGE."
  }
}

variable "algorithm" {
  type        = string
  default     = "tree_ah"
  description = "Indexing algorithm to use: tree_ah (Tree-AH approximate nearest neighbor with ScaNN) or brute_force (exact search)."

  validation {
    condition     = contains(["tree_ah", "brute_force"], var.algorithm)
    error_message = "algorithm must be either tree_ah or brute_force."
  }
}

variable "tree_ah_leaf_node_embedding_count" {
  type        = number
  default     = 1000
  description = "Number of embeddings in each leaf node for Tree-AH algorithm."
}

variable "tree_ah_leaf_nodes_to_search_percent" {
  type        = number
  default     = 10
  description = "Percentage of leaf nodes to search for Tree-AH algorithm (1-100). Higher values increase recall at higher latency."

  validation {
    condition     = var.tree_ah_leaf_nodes_to_search_percent >= 1 && var.tree_ah_leaf_nodes_to_search_percent <= 100
    error_message = "tree_ah_leaf_nodes_to_search_percent must be an integer between 1 and 100."
  }
}

variable "index_update_method" {
  type        = string
  default     = "STREAM_UPDATE"
  description = "Index update method: STREAM_UPDATE (real-time streaming updates) or BATCH_UPDATE (bulk batch imports from GCS)."

  validation {
    condition     = contains(["STREAM_UPDATE", "BATCH_UPDATE"], var.index_update_method)
    error_message = "index_update_method must be either STREAM_UPDATE or BATCH_UPDATE."
  }
}

variable "contents_delta_uri" {
  type        = string
  default     = null
  description = "Optional GCS URI containing initial embeddings data for index creation (e.g., gs://my-bucket/embeddings)."
}

variable "is_complete_overwrite" {
  type        = bool
  default     = false
  description = "If true, the index is completely overwritten on batch update."
}

# ── Index Endpoint Configuration ──────────────────────────────────────────────

variable "public_endpoint_enabled" {
  type        = bool
  default     = true
  description = "Whether to create a publicly accessible endpoint authenticated via IAM."
}

variable "network" {
  type        = string
  default     = null
  description = "VPC network resource ID for private peering (e.g., projects/123/global/networks/my-vpc). Set when public_endpoint_enabled is false."
}

variable "enable_private_service_connect" {
  type        = bool
  default     = false
  description = "Whether to enable Private Service Connect (PSC) on the Index Endpoint."
}

variable "psc_project_allowlist" {
  type        = list(string)
  default     = []
  description = "List of GCP project IDs allowed to connect to this endpoint via Private Service Connect."
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
  description = "Custom ID for the deployed index. Must start with a letter and contain only alphanumeric characters and underscores. If empty, derived from display_name."
}

variable "machine_type" {
  type        = string
  default     = "e2-standard-16"
  description = "Machine type for the deployed index nodes (e.g., e2-standard-16, e2-standard-2, n1-standard-16)."
}

variable "min_replicas" {
  type        = number
  default     = 1
  description = "Minimum number of node replicas for autoscaling."

  validation {
    condition     = var.min_replicas >= 1
    error_message = "min_replicas must be at least 1."
  }
}

variable "max_replicas" {
  type        = number
  default     = 2
  description = "Maximum number of node replicas for autoscaling."

  validation {
    condition     = var.max_replicas >= 1
    error_message = "max_replicas must be at least 1."
  }
}

variable "deployment_group" {
  type        = string
  default     = null
  description = "Optional deployment group for coordinating dedicated resource sharing across deployed indexes."
}

variable "reserved_ip_ranges" {
  type        = list(string)
  default     = []
  description = "Optional list of reserved IP ranges for the private endpoint."
}
