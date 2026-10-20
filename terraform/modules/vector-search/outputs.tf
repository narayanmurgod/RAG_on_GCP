output "index_id" {
  description = "The resource ID of the created Vertex AI Vector Search Index: projects/{project}/locations/{location}/indexes/{id}"
  value       = google_vertex_ai_index.this.id
}

output "index_name" {
  description = "The display name of the Vertex AI Vector Search Index."
  value       = google_vertex_ai_index.this.display_name
}

output "index_endpoint_id" {
  description = "The resource ID of the created Vertex AI Index Endpoint: projects/{project}/locations/{location}/indexEndpoints/{id}"
  value       = google_vertex_ai_index_endpoint.this.id
}

output "index_endpoint_name" {
  description = "The display name of the Vertex AI Index Endpoint."
  value       = google_vertex_ai_index_endpoint.this.display_name
}

output "public_endpoint_domain_name" {
  description = "The DNS domain name of the public endpoint for sending query requests."
  value       = google_vertex_ai_index_endpoint.this.public_endpoint_domain_name
}

output "deployed_index_id" {
  description = "The deployed index ID on the endpoint used for nearest neighbor querying."
  value       = var.deploy_index ? google_vertex_ai_index_endpoint_deployed_index.this[0].deployed_index_id : null
}

output "region" {
  description = "The GCP region where the Vector Search resources are provisioned."
  value       = var.region
}

output "project_id" {
  description = "The GCP project ID hosting the Vector Search resources."
  value       = var.project_id
}
