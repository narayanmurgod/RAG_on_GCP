# Output definitions for the AlloyDB module

# The unique cluster ID
output "cluster_id" {
  description = "The AlloyDB cluster ID."
  value       = google_alloydb_cluster.this.cluster_id
}

# The resource name of the AlloyDB cluster
output "cluster_name" {
  description = "The resource name of the AlloyDB cluster."
  value       = google_alloydb_cluster.this.name
}

# The primary instance ID
output "instance_id" {
  description = "The primary instance ID."
  value       = google_alloydb_instance.primary.instance_id
}

# Private IP address for internal VPC connections
output "primary_ip_address" {
  description = "The private IP address of the primary AlloyDB instance for internal VPC connections."
  value       = google_alloydb_instance.primary.ip_address
}
