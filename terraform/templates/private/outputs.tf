output "reasoning_engine_id" {
  description = "Full resource name of the Vertex AI Reasoning Engine."
  value       = module.agent_runtime.reasoning_engine_id
}

output "reasoning_engine_name" {
  description = "Display name of the Reasoning Engine."
  value       = module.agent_runtime.reasoning_engine_name
}

output "deployment_type" {
  description = "Active deployment type (source_code | gcs_package | byoc)."
  value       = module.agent_runtime.deployment_type
}

output "service_account_email" {
  description = "Email of the service account created for the Agent Engine runtime."
  value       = google_service_account.agent_runtime.email
}

output "staging_bucket_name" {
  description = "Name of the GCS staging bucket."
  value       = google_storage_bucket.staging.name
}

output "staging_bucket_uri" {
  description = "GCS URI of the staging bucket."
  value       = "gs://${google_storage_bucket.staging.name}"
}

output "artifact_registry_repo" {
  description = "Artifact Registry repository ID (BYOC only, null otherwise)."
  value       = var.deployment_type == "byoc" && var.artifact_registry_repo_id != "" ? google_artifact_registry_repository.agents[0].name : null
}

output "allowed_invoker_members" {
  description = "IAM members granted restricted invoker access to the Reasoning Engine."
  value       = var.allowed_invoker_members
}
