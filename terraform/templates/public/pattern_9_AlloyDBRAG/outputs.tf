# Output definitions for pattern_9_AlloyDBRAG (Public)

output "cluster_id" {
  description = "The AlloyDB cluster ID."
  value       = module.alloydb.cluster_id
}

output "cluster_name" {
  description = "The resource name of the AlloyDB cluster."
  value       = module.alloydb.cluster_name
}

output "instance_id" {
  description = "The primary instance ID."
  value       = module.alloydb.instance_id
}

output "primary_ip_address" {
  description = "Private IP address of the primary AlloyDB instance."
  value       = module.alloydb.primary_ip_address
}

output "service_account_email" {
  description = "Email of the service account created for AlloyDB RAG operations."
  value       = google_service_account.alloydb_rag.email
}

output "cloud_run_url" {
  description = "Cloud Run service URL (null when enable_cloud_run = false)."
  value       = var.enable_cloud_run ? module.cloud_run[0].service_url : null
}
