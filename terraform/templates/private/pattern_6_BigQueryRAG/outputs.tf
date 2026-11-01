# Output definitions for pattern_6_BigQueryRAG (Private)

output "dataset_id" {
  description = "The ID of the created BigQuery dataset."
  value       = module.bigquery_vector.dataset_id
}

output "table_id" {
  description = "The ID of the BigQuery table storing vector embeddings."
  value       = module.bigquery_vector.table_id
}

output "table_full_id" {
  description = "Fully-qualified table identifier (project.dataset.table) for SQL queries."
  value       = module.bigquery_vector.table_full_id
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
  description = "Email of the service account created for BigQuery RAG operations."
  value       = google_service_account.bigquery_rag.email
}

output "allowed_invoker_members" {
  description = "List of IAM identities granted BigQuery data viewer and job user permissions."
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
