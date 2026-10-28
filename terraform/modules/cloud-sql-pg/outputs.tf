# Output definitions for the Cloud SQL PostgreSQL module

# Name of the Cloud SQL instance
output "instance_name" {
  description = "Name of the Cloud SQL instance."
  value       = google_sql_database_instance.this.name
}

# Full connection name for Cloud SQL Proxy or Cloud Run
output "connection_name" {
  description = "The connection name of the instance for Cloud SQL Proxy or Cloud Run (project:region:instance)."
  value       = google_sql_database_instance.this.connection_name
}

# Name of the created PostgreSQL database
output "database_name" {
  description = "Name of the created database."
  value       = google_sql_database.this.name
}

# The private IPv4 address assigned for VPC communication
output "private_ip_address" {
  description = "The first private IPv4 address assigned for VPC communication."
  value       = google_sql_database_instance.this.private_ip_address
}

# Name of the database application user
output "user_name" {
  description = "Database user name."
  value       = google_sql_user.this.name
}
