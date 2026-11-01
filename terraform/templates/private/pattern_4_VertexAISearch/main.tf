# pattern_4_VertexAISearch — Private Vertex AI Search Deployment
# Provisions a private Vertex AI Search (Discovery Engine) Data Store and Search Engine with restricted IAM invokers and Cloud Storage document staging.

locals {
  staging_bucket_name = var.staging_bucket_name != "" ? var.staging_bucket_name : "${var.project_id}-${var.display_name}-staging-pvt"
}

# ── Enable Required Google Cloud APIs ─────────────────────────────────────────

resource "google_project_service" "discoveryengine" {
  project            = var.project_id
  service            = "discoveryengine.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "storage" {
  project            = var.project_id
  service            = "storage.googleapis.com"
  disable_on_destroy = false
}

# ── Cloud Storage Staging Bucket (Private) ────────────────────────────────────

resource "google_storage_bucket" "staging" {
  count                       = var.create_staging_bucket ? 1 : 0
  name                        = local.staging_bucket_name
  project                     = var.project_id
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = false
  labels                      = var.labels

  versioning {
    enabled = true
  }

  depends_on = [google_project_service.storage]
}

# ── IAM: Service Account & Core Roles ─────────────────────────────────────────

resource "google_service_account" "search_admin" {
  project      = var.project_id
  account_id   = "search-p4-sa"
  display_name = "Vertex AI Search SA — ${var.display_name} (Private Pattern 4)"
}

resource "google_project_iam_member" "discoveryengine_editor" {
  project = var.project_id
  role    = "roles/discoveryengine.editor"
  member  = "serviceAccount:${google_service_account.search_admin.email}"
}

resource "google_project_iam_member" "storage_admin" {
  count   = var.create_staging_bucket ? 1 : 0
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.search_admin.email}"
}

# ── IAM: Restricted Invoker Access (Private Only) ─────────────────────────────

resource "google_project_iam_member" "restricted_invokers" {
  for_each = toset(var.allowed_invoker_members)
  project  = var.project_id
  role     = "roles/discoveryengine.viewer"
  member   = each.value
}

# ── Module: discovery-engine ──────────────────────────────────────────────────

module "discovery_engine" {
  source = "../../../modules/discovery-engine"

  project_id           = var.project_id
  location             = var.location
  data_store_id        = var.data_store_id
  display_name         = var.display_name
  industry_vertical    = var.industry_vertical
  content_config       = var.content_config
  solution_types       = var.solution_types
  create_search_engine = var.create_search_engine
  engine_id            = var.engine_id
  collection_id        = var.collection_id
  search_tier          = var.search_tier
  search_add_ons       = var.search_add_ons

  depends_on = [
    google_project_service.discoveryengine,
    google_service_account.search_admin,
    google_project_iam_member.restricted_invokers,
  ]
}
