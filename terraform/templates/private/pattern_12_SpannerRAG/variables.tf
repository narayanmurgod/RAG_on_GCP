# Input variables for pattern_12_SpannerRAG (Private)

# Core
variable "project_id" {
  type        = string
  description = "GCP Project ID hosting Spanner resources."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for resources."
}

variable "display_name" {
  type        = string
  default     = "pattern12-spanner-rag"
  description = "Display name prefix for resources."
}

variable "labels" {
  type = map(string)
  default = {
    environment = "private"
    pattern     = "pattern-12-spannerrag"
    managed-by  = "aip-terraform"
  }
  description = "Resource labels attached to all resources."
}

# Networking Configuration
variable "use_existing_network" {
  type        = bool
  default     = false
  description = "Whether to use an existing VPC network instead of creating a new one."
}

variable "network_name" {
  type        = string
  default     = "pattern12-spanner-vpc"
  description = "Name of the custom VPC network to create if use_existing_network is false."
}

variable "existing_network_name" {
  type        = string
  default     = ""
  description = "VPC network ID or self link if use_existing_network is true."
}

variable "existing_connector_id" {
  type        = string
  default     = null
  description = "Existing Serverless VPC Access connector ID if use_existing_network is true."
}

variable "app_subnet_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "Primary CIDR block for application compute resources and database endpoints."
}

variable "connector_cidr" {
  type        = string
  default     = "10.8.0.0/28"
  description = "Dedicated /28 CIDR block for Serverless VPC Access connector."
}

variable "enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Whether to create a Cloud NAT gateway for outbound egress."
}

# Spanner Configuration
variable "instance_id" {
  type        = string
  default     = "pattern12-spanner-instance"
  description = "Unique ID for the Cloud Spanner instance."
}

variable "spanner_config" {
  type        = string
  default     = "regional-us-central1"
  description = "Spanner instance regional or multi-regional configuration."
}

variable "processing_units" {
  type        = number
  default     = 100
  description = "Compute capacity allocated in processing units (100 to 1000 PUs)."
}

variable "database_name" {
  type        = string
  default     = "rag-knowledge-base"
  description = "Name of the Spanner database."
}

variable "embedding_dimension" {
  type        = number
  default     = 768
  description = "Vector embedding dimension for documents table."
}

variable "distance_type" {
  type        = string
  default     = "COSINE"
  description = "Distance metric for vector search index (COSINE, EUCLIDEAN, DOT_PRODUCT)."
}

variable "enable_vector_index" {
  type        = bool
  default     = true
  description = "Whether to create the vector search index."
}

variable "enable_graph_rag" {
  type        = bool
  default     = true
  description = "Whether to deploy the Spanner Graph schema for Graph-Augmented RAG."
}

variable "graph_name" {
  type        = string
  default     = "KnowledgeGraph"
  description = "Name of the property graph created in Spanner Graph."
}

variable "deletion_protection" {
  type        = bool
  default     = false
  description = "Whether to prevent accidental database deletion."
}

# IAM Invoker Restrictions
variable "allowed_invoker_members" {
  type        = list(string)
  default     = []
  description = "List of IAM members permitted to connect to the Spanner database."
}

# Cloud Run Serving Layer (Optional)
variable "enable_cloud_run" {
  type        = bool
  default     = false
  description = "Enable optional Cloud Run RAG retrieval / generation serving service."
}

variable "container_image" {
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
  description = "Container image URL deployed to Cloud Run."
}

variable "min_instances" {
  type        = number
  default     = 0
  description = "Minimum number of Cloud Run instances."
}

variable "max_instances" {
  type        = number
  default     = 5
  description = "Maximum number of Cloud Run instances."
}

variable "embedding_model" {
  type        = string
  default     = "text-embedding-005"
  description = "Vertex AI embedding model used for vector generation."
}

variable "generation_model" {
  type        = string
  default     = "gemini-1.5-flash-002"
  description = "Vertex AI generation model used for RAG synthesis."
}
