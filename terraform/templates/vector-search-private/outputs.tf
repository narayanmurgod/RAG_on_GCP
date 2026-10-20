output "index_id" {
  description = "The resource ID of the created Vertex AI Vector Search Index."
  value       = module.vector_search.index_id
}

output "index_name" {
  description = "The display name of the Vertex AI Vector Search Index."
  value       = module.vector_search.index_name
}

output "index_endpoint_id" {
  description = "The resource ID of the created Vertex AI Index Endpoint."
  value       = module.vector_search.index_endpoint_id
}

output "index_endpoint_name" {
  description = "The display name of the Vertex AI Index Endpoint."
  value       = module.vector_search.index_endpoint_name
}

output "deployed_index_id" {
  description = "The deployed index ID on the endpoint used for nearest neighbor querying."
  value       = module.vector_search.deployed_index_id
}

output "network" {
  description = "The VPC network associated with this private endpoint."
  value       = var.network
}

output "enable_private_service_connect" {
  description = "Whether Private Service Connect is enabled on this endpoint."
  value       = var.enable_private_service_connect
}

output "service_account_email" {
  description = "Email of the service account authorized to query and manage vector embeddings."
  value       = google_service_account.vector_search.email
}

output "staging_bucket_name" {
  description = "Name of the GCS staging bucket if created."
  value       = var.create_staging_bucket ? google_storage_bucket.staging[0].name : null
}
