locals {
  # Generate a compliant deployed_index_id if not explicitly provided
  # Deployed index ID must start with a letter and contain only lowercase/uppercase letters, numbers, and underscores
  generated_deployed_id = "dep_${replace(lower(var.display_name), "/[^a-z0-9_]/", "_")}"
  deployed_index_id     = var.deployed_index_id != "" ? var.deployed_index_id : local.generated_deployed_id
}

# ── 1. Vector Search Index ───────────────────────────────────────────────────

resource "google_vertex_ai_index" "this" {
  project      = var.project_id
  region       = var.region
  display_name = var.display_name
  description  = var.description
  labels       = var.labels

  index_update_method = var.index_update_method

  metadata {
    contents_delta_uri    = var.contents_delta_uri
    is_complete_overwrite = var.is_complete_overwrite

    config {
      dimensions                  = var.dimensions
      approximate_neighbors_count = var.approximate_neighbors_count
      distance_measure_type       = var.distance_measure_type
      feature_norm_type           = var.feature_norm_type
      shard_size                  = var.shard_size

      dynamic "algorithm_config" {
        for_each = var.algorithm == "tree_ah" ? [1] : []
        content {
          tree_ah_config {
            leaf_node_embedding_count    = var.tree_ah_leaf_node_embedding_count
            leaf_nodes_to_search_percent = var.tree_ah_leaf_nodes_to_search_percent
          }
        }
      }

      dynamic "algorithm_config" {
        for_each = var.algorithm == "brute_force" ? [1] : []
        content {
          brute_force_config {}
        }
      }
    }
  }
}

# ── 2. Vector Search Index Endpoint ──────────────────────────────────────────

resource "google_vertex_ai_index_endpoint" "this" {
  project      = var.project_id
  region       = var.region
  display_name = "${var.display_name}-endpoint"
  description  = "Endpoint for ${var.display_name}"
  labels       = var.labels

  public_endpoint_enabled = var.public_endpoint_enabled
  network                 = var.network

  dynamic "private_service_connect_config" {
    for_each = var.enable_private_service_connect ? [1] : []
    content {
      enable_private_service_connect = true
      project_allowlist              = var.psc_project_allowlist
    }
  }
}

# ── 3. Deployed Index Association ─────────────────────────────────────────────

resource "google_vertex_ai_index_endpoint_deployed_index" "this" {
  count = var.deploy_index ? 1 : 0

  index_endpoint     = google_vertex_ai_index_endpoint.this.id
  index              = google_vertex_ai_index.this.id
  deployed_index_id  = local.deployed_index_id
  display_name       = "${var.display_name}-deployment"
  deployment_group   = var.deployment_group
  reserved_ip_ranges = length(var.reserved_ip_ranges) > 0 ? var.reserved_ip_ranges : null

  dedicated_resources {
    machine_spec {
      machine_type = var.machine_type
    }
    min_replica_count = var.min_replicas
    max_replica_count = var.max_replicas
  }
}
