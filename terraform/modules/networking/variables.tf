# Input variables for the Enterprise Networking module

# GCP project ID hosting the VPC
variable "project_id" {
  type        = string
  description = "GCP Project ID hosting the networking resources."
}

# GCP region for subnets and connectors
variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for subnets and connectors."
}

# Name of the custom VPC network
variable "network_name" {
  type        = string
  default     = "rag-enterprise-vpc"
  description = "Name of the custom VPC network."
}

# CIDR block for the application compute and database subnet
variable "app_subnet_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "Primary CIDR block for application compute resources and database endpoints."
}

# Dedicated /28 CIDR block for the Serverless VPC Access Connector
variable "connector_cidr" {
  type        = string
  default     = "10.8.0.0/28"
  description = "Dedicated /28 CIDR block for the Serverless VPC Access Connector."
}

# Name of the Serverless VPC Access Connector
variable "connector_name" {
  type        = string
  default     = "rag-vpc-connector"
  description = "Name of the Serverless VPC Access Connector."
}

# Minimum instances for the Serverless VPC Access Connector
variable "min_instances" {
  type        = number
  default     = 2
  description = "Minimum instances for the Serverless VPC Access Connector."
}

# Maximum instances for the Serverless VPC Access Connector
variable "max_instances" {
  type        = number
  default     = 3
  description = "Maximum instances for the Serverless VPC Access Connector."
}

# Whether to create a Cloud NAT gateway for outbound egress
variable "enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Whether to create a Cloud NAT gateway for outbound internet access from private subnets."
}
