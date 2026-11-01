# Output definitions for pattern_4_VertexAISearch (Private)

output "data_store_id" {
  description = "The ID of the created Discovery Engine Data Store."
  value       = module.discovery_engine.data_store_id
}

output "data_store_name" {
  description = "Full resource name of the Discovery Engine Data Store."
  value       = module.discovery_engine.data_store_name
}

output "search_engine_id" {
  description = "The ID of the created Search Engine (null if create_search_engine = false)."
  value       = module.discovery_engine.search_engine_id
}

output "search_engine_name" {
  description = "Full resource name of the Search Engine (null if create_search_engine = false)."
  value       = module.discovery_engine.search_engine_name
}

output "staging_bucket_name" {
  description = "Private GCS bucket name for document ingestion."
  value       = var.create_staging_bucket ? google_storage_bucket.staging[0].name : null
}

output "staging_bucket_uri" {
  description = "GCS URI for uploading documents to be indexed by Vertex AI Search."
  value       = var.create_staging_bucket ? "gs://${google_storage_bucket.staging[0].name}" : null
}

output "service_account_email" {
  description = "Email of the service account for Vertex AI Search operations."
  value       = google_service_account.search_admin.email
}

output "allowed_invoker_members" {
  description = "List of IAM identities granted viewer access to this private search engine."
  value       = var.allowed_invoker_members
}
