# Output definitions for pattern_11_SpannerRAG (Public)

output "spanner_instance_id" {
  description = "The Cloud Spanner instance ID."
  value       = module.spanner.instance_id
}

output "spanner_database_name" {
  description = "The Cloud Spanner database name."
  value       = module.spanner.database_name
}

output "spanner_database_id" {
  description = "Full resource ID of the Spanner database."
  value       = module.spanner.database_id
}

output "spanner_connection_string" {
  description = "Formatted Spanner database reference for application clients."
  value       = module.spanner.connection_string
}

output "service_account_email" {
  description = "Email of the service account created for Spanner RAG operations."
  value       = google_service_account.spanner_rag.email
}

output "cloud_run_url" {
  description = "Cloud Run service URL (null when enable_cloud_run = false)."
  value       = var.enable_cloud_run ? module.cloud_run[0].service_url : null
}
