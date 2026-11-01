# Input variables for pattern_10_AlloyDBRAG (Private)

# Core
variable "project_id" {
  type        = string
  description = "GCP Project ID hosting AlloyDB resources."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for all resources."
}

variable "display_name" {
  type        = string
  default     = "pattern10-alloydb-rag"
  description = "Display name prefix for resources."
}

variable "labels" {
  type = map(string)
  default = {
    environment = "private"
    pattern     = "pattern-10-alloydbrag"
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
  default     = "pattern10-alloydb-vpc"
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

# AlloyDB Configuration
variable "cluster_id" {
  type        = string
  default     = "pattern10-alloydb-cluster"
  description = "Unique ID for the AlloyDB cluster."
}

variable "initial_user_password" {
  type        = string
  sensitive   = true
  description = "Password for the initial postgres administrative user."
}

variable "instance_id" {
  type        = string
  default     = "primary-instance"
  description = "Instance ID for primary AlloyDB instance."
}

variable "cpu_count" {
  type        = number
  default     = 2
  description = "Number of vCPUs for primary instance (2, 4, 8, 16, 32, 64, 128)."
}

variable "database_flags" {
  type        = map(string)
  default     = {}
  description = "PostgreSQL configuration flags for vector indexing and ScaNN."
}

# IAM Invoker Restrictions
variable "allowed_invoker_members" {
  type        = list(string)
  default     = []
  description = "List of IAM members permitted to connect to AlloyDB cluster."
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
