# Output definitions for the Weaviate integration module

# Secret Manager secret ID for API key
output "api_key_secret_id" {
  description = "The Secret Manager secret ID storing the Weaviate API key."
  value       = google_secret_manager_secret.api_key.secret_id
}

# Full resource name of the Weaviate API key secret
output "api_key_secret_name" {
  description = "Full resource name of the Weaviate API key secret."
  value       = google_secret_manager_secret.api_key.name
}

# Secret Manager secret ID for Cluster URL
output "cluster_url_secret_id" {
  description = "The Secret Manager secret ID storing the Weaviate Cluster URL."
  value       = google_secret_manager_secret.cluster_url.secret_id
}

# Full resource name of the Weaviate Cluster URL secret
output "cluster_url_secret_name" {
  description = "Full resource name of the Weaviate Cluster URL secret."
  value       = google_secret_manager_secret.cluster_url.name
}

# The target Weaviate collection name
output "collection_name" {
  description = "The target Weaviate collection name."
  value       = var.collection_name
}
