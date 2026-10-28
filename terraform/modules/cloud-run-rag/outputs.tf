# Output definitions for the Cloud Run RAG Serving module

# Name of the Cloud Run service
output "service_name" {
  description = "Name of the Cloud Run service."
  value       = google_cloud_run_v2_service.this.name
}

# Public HTTPS URL of the deployed Cloud Run service
output "service_uri" {
  description = "The main HTTPS endpoint URL of the deployed Cloud Run service."
  value       = google_cloud_run_v2_service.this.uri
}

# Service account email assigned to Cloud Run
output "service_account_email" {
  description = "The email of the dedicated Cloud Run Service Account."
  value       = google_service_account.cloud_run.email
}

# GCP region hosting the Cloud Run service
output "location" {
  description = "The GCP region of the service."
  value       = google_cloud_run_v2_service.this.location
}
