# Output definitions for pattern_8_CloudSQLRAG (Private)

output "instance_name" {
  description = "Name of the Cloud SQL instance."
  value       = module.cloud_sql.instance_name
}

output "connection_name" {
  description = "Connection name for Cloud SQL Proxy or Cloud Run (project:region:instance)."
  value       = module.cloud_sql.connection_name
}

output "database_name" {
  description = "Name of the created PostgreSQL database."
  value       = module.cloud_sql.database_name
}

output "user_name" {
  description = "Database user name."
  value       = module.cloud_sql.user_name
}

output "private_ip_address" {
  description = "Private IP address of the database inside the VPC."
  value       = module.cloud_sql.private_ip_address
}

output "staging_bucket_name" {
  description = "The GCS staging bucket name (null if create_staging_bucket = false)."
  value       = var.create_staging_bucket ? google_storage_bucket.staging[0].name : null
}

output "staging_bucket_uri" {
  description = "The GCS staging bucket URI (null if create_staging_bucket = false)."
  value       = var.create_staging_bucket ? "gs://${google_storage_bucket.staging[0].name}" : null
}

output "service_account_email" {
  description = "Email of the service account created for Cloud SQL RAG operations."
  value       = google_service_account.cloudsql_rag.email
}

output "allowed_invoker_members" {
  description = "List of IAM identities granted Cloud SQL client access."
  value       = var.allowed_invoker_members
}

output "vpc_connector_id" {
  description = "Serverless VPC Access connector ID used for private Cloud Run egress (null when enable_cloud_run = false)."
  value       = local.resolved_vpc_connector_id
}

output "cloud_run_url" {
  description = "Private Cloud Run service URL (null when enable_cloud_run = false)."
  value       = var.enable_cloud_run ? module.cloud_run[0].service_url : null
}
