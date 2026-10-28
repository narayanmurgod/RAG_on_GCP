# Output definitions for the Cloud Spanner RAG module

# The Cloud Spanner instance ID
output "instance_id" {
  description = "The Cloud Spanner instance ID."
  value       = google_spanner_instance.this.name
}

# The display name of the Spanner instance
output "instance_display_name" {
  description = "The display name of the Cloud Spanner instance."
  value       = google_spanner_instance.this.display_name
}

# The current operational state of the instance
output "instance_state" {
  description = "The current operational state of the Spanner instance."
  value       = google_spanner_instance.this.state
}

# The Cloud Spanner database name
output "database_name" {
  description = "The Cloud Spanner database name."
  value       = google_spanner_database.this.name
}

# Full resource ID of the Spanner database
output "database_id" {
  description = "Full resource ID of the Spanner database."
  value       = "${google_spanner_instance.this.name}/${google_spanner_database.this.name}"
}

# The Spanner instance location configuration
output "config" {
  description = "The Spanner instance location configuration."
  value       = google_spanner_instance.this.config
}

# Formatted database connection string for application clients
output "connection_string" {
  description = "Formatted Spanner database reference for application clients."
  value       = "projects/${var.project_id}/instances/${google_spanner_instance.this.name}/databases/${google_spanner_database.this.name}"
}
