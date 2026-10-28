# Input variables for the Cloud SQL PostgreSQL module

# GCP project ID hosting Cloud SQL
variable "project_id" {
  type        = string
  description = "GCP Project ID hosting the Cloud SQL instance."
}

# GCP region for the Cloud SQL instance
variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for the Cloud SQL instance."
}

# Unique name for the Cloud SQL instance
variable "instance_name" {
  type        = string
  description = "Name for the Cloud SQL instance."
}

# PostgreSQL version engine
variable "database_version" {
  type        = string
  default     = "POSTGRES_16"
  description = "PostgreSQL version (e.g. POSTGRES_15, POSTGRES_16)."
}

# Machine tier sizing
variable "tier" {
  type        = string
  default     = "db-custom-2-7680"
  description = "Machine tier for the database (e.g. db-f1-micro, db-custom-2-7680, db-custom-4-15360)."
}

# Initial database name
variable "database_name" {
  type        = string
  default     = "rag_knowledge_db"
  description = "Name of the PostgreSQL database to create."
}

# Application database username
variable "user_name" {
  type        = string
  default     = "rag_app_user"
  description = "Username for the primary application database user."
}

# Application database user password
variable "user_password" {
  type        = string
  sensitive   = true
  description = "Password for the application database user."
}

# Whether to assign a public IPv4 address
variable "enable_public_ip" {
  type        = bool
  default     = false
  description = "Whether to assign a public IPv4 address to the Cloud SQL instance."
}

# Private VPC network self link for private IP connectivity
variable "private_network" {
  type        = string
  default     = null
  description = "VPC network self_link or ID for private IP access (recommended for enterprise)."
}

# Whether Terraform prevents accidental instance deletion
variable "deletion_protection" {
  type        = bool
  default     = false
  description = "Whether Terraform prevents accidental instance deletion."
}

# Resource labels attached to Cloud SQL instance
variable "labels" {
  type        = map(string)
  default     = {}
  description = "Resource labels attached to the Cloud SQL instance."
}
