# Input variables for the AlloyDB for PostgreSQL module

# GCP project ID hosting AlloyDB
variable "project_id" {
  type        = string
  description = "GCP Project ID hosting AlloyDB resources."
}

# GCP region for the AlloyDB cluster
variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for the AlloyDB cluster."
}

# Unique ID for the AlloyDB cluster
variable "cluster_id" {
  type        = string
  description = "Unique ID for the AlloyDB cluster."
}

# Human-readable display name for the cluster
variable "display_name" {
  type        = string
  default     = ""
  description = "Display name for the cluster. Defaults to cluster_id if empty."
}

# Private VPC network ID for internal database access
variable "network_id" {
  type        = string
  description = "VPC Network ID (e.g., projects/{project}/global/networks/{network}) for private AlloyDB communication."
}

# Password for the initial postgres administrative user
variable "initial_user_password" {
  type        = string
  sensitive   = true
  description = "Password for the initial postgres administrative user."
}

# Unique instance ID for the primary database instance
variable "instance_id" {
  type        = string
  default     = "primary-instance"
  description = "Instance ID for the primary AlloyDB instance."
}

# Number of vCPUs for the primary instance
variable "cpu_count" {
  type        = number
  default     = 2
  description = "Number of vCPUs for the primary instance (e.g. 2, 4, 8, 16)."

  validation {
    condition     = contains([2, 4, 8, 16, 32, 64, 128], var.cpu_count)
    error_message = "cpu_count must be one of: 2, 4, 8, 16, 32, 64, 128."
  }
}

# PostgreSQL database configuration flags
variable "database_flags" {
  type        = map(string)
  default     = {}
  description = "PostgreSQL configuration flags (e.g. for vector indexing and ScaNN)."
}

# Resource labels attached to cluster and instance
variable "labels" {
  type        = map(string)
  default     = {}
  description = "Labels to attach to the AlloyDB cluster and instance."
}
