# Vertex AI Search Data Store and Search Engine resources

locals {
  # Resolved engine ID defaulting to data_store_id-engine
  engine_id = var.engine_id != "" ? var.engine_id : "${var.data_store_id}-engine"
}

# Discovery Engine Data Store resource
resource "google_discovery_engine_data_store" "this" {
  project           = var.project_id
  location          = var.location
  data_store_id     = var.data_store_id
  display_name      = var.display_name
  industry_vertical = var.industry_vertical
  content_config    = var.content_config
  solution_types    = var.solution_types
}

# Discovery Engine Search Engine resource linked to the data store
resource "google_discovery_engine_search_engine" "this" {
  count = var.create_search_engine ? 1 : 0

  project        = var.project_id
  location       = var.location
  collection_id  = var.collection_id
  engine_id      = local.engine_id
  display_name   = "${var.display_name} Engine"
  data_store_ids = [google_discovery_engine_data_store.this.data_store_id]

  search_engine_config {
    search_tier    = var.search_tier
    search_add_ons = var.search_add_ons
  }
}
