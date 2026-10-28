output "reasoning_engine_id" {
  description = "Full resource name of the Vertex AI Reasoning Engine: projects/{p}/locations/{l}/reasoningEngines/{id}"
  value       = google_vertex_ai_reasoning_engine.this.name
}

output "reasoning_engine_name" {
  description = "Short display name of the Reasoning Engine as registered in Vertex AI."
  value       = google_vertex_ai_reasoning_engine.this.display_name
}

output "deployment_type" {
  description = "Active deployment type used for this agent runtime instance."
  value       = var.deployment_type
}

output "region" {
  description = "GCP region where the Reasoning Engine is deployed."
  value       = var.region
}

output "project_id" {
  description = "GCP project ID of the Reasoning Engine."
  value       = var.project_id
}
