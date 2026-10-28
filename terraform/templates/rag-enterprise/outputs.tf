# Output definitions for the Enterprise Cloud Spanner RAG template

# Public HTTPS URL of the Cloud Run FastAPI RAG service
output "service_uri" {
  description = "The HTTPS endpoint URL of the Cloud Run FastAPI RAG service."
  value       = module.cloud_run.service_uri
}

# The Cloud Spanner instance ID
output "spanner_instance_id" {
  description = "Cloud Spanner instance ID."
  value       = module.spanner.instance_id
}

# The Cloud Spanner database name
output "spanner_database_name" {
  description = "Cloud Spanner database name."
  value       = module.spanner.database_name
}

# Formatted Spanner database connection string for application clients
output "spanner_connection_string" {
  description = "Formatted Spanner database reference for application clients."
  value       = module.spanner.connection_string
}

# Name of the dedicated enterprise VPC network
output "vpc_network_name" {
  description = "Name of the dedicated enterprise VPC network."
  value       = module.networking.network_name
}

# Name of the Serverless VPC Access Connector
output "vpc_connector_name" {
  description = "Name of the Serverless VPC Access Connector."
  value       = module.networking.connector_name
}

# Email of the service account running the Cloud Run service
output "service_account_email" {
  description = "Service account running the Cloud Run RAG service."
  value       = module.cloud_run.service_account_email
}
