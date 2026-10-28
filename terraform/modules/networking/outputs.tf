# Output definitions for the Enterprise Networking module

# The ID of the VPC network
output "network_id" {
  description = "The ID of the VPC network."
  value       = google_compute_network.this.id
}

# The name of the VPC network
output "network_name" {
  description = "The name of the VPC network."
  value       = google_compute_network.this.name
}

# The ID of the application subnet
output "app_subnet_id" {
  description = "The ID of the application subnet."
  value       = google_compute_subnetwork.app.id
}

# The resource ID of the Serverless VPC Access Connector
output "connector_id" {
  description = "The resource ID of the Serverless VPC Access Connector."
  value       = google_vpc_access_connector.this.id
}

# The name of the Serverless VPC Access Connector
output "connector_name" {
  description = "The name of the Serverless VPC Access Connector."
  value       = google_vpc_access_connector.this.name
}
