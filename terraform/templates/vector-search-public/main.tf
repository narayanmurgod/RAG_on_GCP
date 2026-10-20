locals {
  bucket_name = var.staging_bucket_name != "" ? var.staging_bucket_name : "${var.project_id}-vs-staging-${replace(lower(var.display_name), "/[^a-z0-9]/", "-")}"
}

# ── Enable Required Google Cloud APIs ─────────────────────────────────────────

resource "google_project_service" "aiplatform" {
  project            = var.project_id
  service            = "aiplatform.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "storage" {
  project            = var.project_id
  service            = "storage.googleapis.com"
  disable_on_destroy = false
}

# ── GCS Staging Bucket (Optional batch imports & embeddings data) ──────────────

resource "google_storage_bucket" "staging" {
  count                       = var.create_staging_bucket ? 1 : 0
  name                        = local.bucket_name
  project                     = var.project_id
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = false
  labels                      = var.labels

  versioning {
    enabled = false
  }

  depends_on = [google_project_service.storage]
}

# ── Service Account & IAM for Vector Search Operations ────────────────────────

resource "google_service_account" "vector_search" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "Vector Search SA — ${var.display_name} (Public)"
}

resource "google_project_iam_member" "aiplatform_user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.vector_search.email}"
}

resource "google_project_iam_member" "storage_viewer" {
  count   = var.create_staging_bucket ? 1 : 0
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.vector_search.email}"
}

# ── Vector Search Module ──────────────────────────────────────────────────────

module "vector_search" {
  source = "../../modules/vector-search"

  project_id   = var.project_id
  region       = var.region
  display_name = var.display_name
  description  = var.description
  labels       = var.labels

  dimensions                  = var.dimensions
  approximate_neighbors_count = var.approximate_neighbors_count
  distance_measure_type       = var.distance_measure_type
  shard_size                  = var.shard_size
  algorithm                   = var.algorithm
  index_update_method         = var.index_update_method
  contents_delta_uri          = var.contents_delta_uri

  # Public endpoint enabled
  public_endpoint_enabled        = true
  network                        = null
  enable_private_service_connect = false

  # Deployment sizing
  deploy_index      = var.deploy_index
  deployed_index_id = var.deployed_index_id
  machine_type      = var.machine_type
  min_replicas      = var.min_replicas
  max_replicas      = var.max_replicas

  depends_on = [
    google_project_service.aiplatform,
    google_service_account.vector_search,
  ]
}
