# Output definitions for the Pinecone integration module

# Secret Manager secret ID
output "secret_id" {
  description = "The Secret Manager secret ID storing the Pinecone API key."
  value       = google_secret_manager_secret.api_key.secret_id
}

# Full resource name of the Pinecone secret
output "secret_name" {
  description = "Full resource name of the Pinecone secret."
  value       = google_secret_manager_secret.api_key.name
}

# The target Pinecone index name
output "index_name" {
  description = "The target Pinecone index name."
  value       = var.index_name
}

# The Pinecone environment or region
output "environment" {
  description = "The Pinecone environment / region."
  value       = var.environment
}
