# Input variables for pattern_14_AgenticRAG (Private)

# Core
variable "project_id" {
  type        = string
  description = "GCP Project ID hosting Vertex AI Reasoning Engine and RAG Engine."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for resources (Reasoning Engine is supported in us-central1)."
}

variable "display_name" {
  type        = string
  default     = "pattern14-agentic-rag"
  description = "Display name prefix for resources."
}

variable "labels" {
  type = map(string)
  default = {
    environment = "private"
    pattern     = "pattern-14-agenticrag"
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
  default     = "pattern14-agentic-vpc"
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

# Agent Runtime Configuration
variable "agent_framework" {
  type        = string
  default     = "google-adk"
  description = "Agent framework tag: google-adk | langchain | langgraph | llamaindex | custom."
}

variable "deployment_type" {
  type        = string
  default     = "source_code"
  description = "Vertex AI Agent packaging model: source_code | gcs_package | byoc."
}

variable "source_archive_gcs_uri" {
  type        = string
  default     = "gs://placeholder-bucket/agent_source.tar.gz"
  description = "GCS URI of the packaged source code archive (.tar.gz)."
}

variable "requirements_gcs_uri" {
  type        = string
  default     = "gs://placeholder-bucket/requirements.txt"
  description = "GCS URI of the Python requirements.txt file."
}

variable "python_version" {
  type        = string
  default     = "3.11"
  description = "Python runtime version for Reasoning Engine container."
}

variable "class_methods" {
  type = list(object({
    name        = string
    description = string
  }))
  default = [
    {
      name        = "query"
      description = "Execute multi-step agent reasoning query with RAG retrieval."
    }
  ]
  description = "List of callable class methods exposed by the Reasoning Engine."
}

# RAG Knowledge Corpus Configuration
variable "corpus_name" {
  type        = string
  default     = "agentic-rag-corpus-pvt"
  description = "Name for the Vertex AI RAG corpus."
}

variable "embedding_model" {
  type        = string
  default     = "publishers/google/models/text-embedding-005"
  description = "Embedding model resource name for RAG Engine corpus."
}

# IAM Invoker Restrictions
variable "allowed_invoker_members" {
  type        = list(string)
  default     = []
  description = "List of IAM members permitted to invoke the Reasoning Engine and Cloud Run service."
}

# Cloud Run Serving Layer (Optional)
variable "enable_cloud_run" {
  type        = bool
  default     = false
  description = "Enable optional Cloud Run frontend / API gateway layer."
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

variable "generation_model" {
  type        = string
  default     = "gemini-1.5-flash-002"
  description = "Vertex AI generation model used for RAG synthesis."
}
