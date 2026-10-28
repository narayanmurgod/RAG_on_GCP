# Output definitions for the Vertex AI Search / Discovery Engine module

# The ID of the created Data Store
output "data_store_id" {
  description = "The ID of the created Discovery Engine Data Store."
  value       = google_discovery_engine_data_store.this.data_store_id
}

# Full resource name of the Data Store
output "data_store_name" {
  description = "Resource name of the Data Store."
  value       = google_discovery_engine_data_store.this.name
}

# The ID of the Search Engine (if created)
output "search_engine_id" {
  description = "The ID of the Search Engine (if created)."
  value       = var.create_search_engine ? google_discovery_engine_search_engine.this[0].engine_id : null
}

# Full resource name of the Search Engine
output "search_engine_name" {
  description = "Full resource name of the Search Engine."
  value       = var.create_search_engine ? google_discovery_engine_search_engine.this[0].name : null
}
