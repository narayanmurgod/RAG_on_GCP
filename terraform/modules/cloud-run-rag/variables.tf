# Input variables for the Cloud Run RAG Serving module

# GCP project ID hosting the service
variable "project_id" {
  type        = string
  description = "GCP Project ID hosting the Cloud Run service."
}

# GCP region for the Cloud Run service
variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for the Cloud Run service."
}

# Name of the Cloud Run service
variable "service_name" {
  type        = string
  description = "Name of the Cloud Run service."
}

# Container image URI for the FastAPI microservice
variable "container_image" {
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
  description = "Container image URI for the FastAPI RAG service."
}

# Port the container listens on
variable "container_port" {
  type        = number
  default     = 8080
  description = "Port the container listens on."
}

# Minimum instances (0 enables serverless scale-to-zero)
variable "min_instances" {
  type        = number
  default     = 0
  description = "Minimum number of instances. Set to 0 for serverless scale-to-zero (Quickstart), >= 1 for Enterprise warm instances."
}

# Maximum instances for autoscaling
variable "max_instances" {
  type        = number
  default     = 5
  description = "Maximum number of instances for autoscaling."
}

# CPU limit per container instance
variable "cpu_limit" {
  type        = string
  default     = "1000m"
  description = "CPU allocation per container instance (e.g. 1000m, 2000m, 4000m)."
}

# Memory limit per container instance
variable "memory_limit" {
  type        = string
  default     = "1024Mi"
  description = "Memory allocation per container instance (e.g. 512Mi, 1024Mi, 2Gi, 4Gi)."
}

# Environment variables injected into the container
variable "env_vars" {
  type        = map(string)
  default     = {}
  description = "Environment variables passed into the container."
}

# Optional Serverless VPC Access connector for private internal egress
variable "vpc_connector_id" {
  type        = string
  default     = null
  description = "Resource ID of the Serverless VPC Access connector for private internal egress."
}

# VPC egress routing mode
variable "vpc_egress" {
  type        = string
  default     = "ALL_TRAFFIC"
  description = "VPC traffic routing mode: ALL_TRAFFIC or PRIVATE_RANGES_ONLY."

  validation {
    condition     = contains(["ALL_TRAFFIC", "PRIVATE_RANGES_ONLY"], var.vpc_egress)
    error_message = "vpc_egress must be either ALL_TRAFFIC or PRIVATE_RANGES_ONLY."
  }
}

# Whether to permit public unauthenticated invocations
variable "allow_unauthenticated" {
  type        = bool
  default     = true
  description = "Whether to allow public unauthenticated invocations (e.g. for quickstart testing). If false, calls require Cloud Run Invoker IAM role."
}

# Resource labels attached to the Cloud Run service
variable "labels" {
  type        = map(string)
  default     = {}
  description = "Resource labels attached to the Cloud Run service."
}
