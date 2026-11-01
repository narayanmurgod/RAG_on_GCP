locals {
  # Derive GCS object URIs from the bucket name + fixed object paths.
  # These are passed into the module so the module stays URI-agnostic.
  source_archive_gcs_uri = var.deployment_type == "source_code" ? "gs://${var.staging_bucket_name}/source/agent_source.tar.gz" : null
  source_req_gcs_uri     = var.deployment_type == "source_code" ? "gs://${var.staging_bucket_name}/source/requirements.txt" : null

  pickle_gcs_uri  = var.deployment_type == "gcs_package" ? "gs://${var.staging_bucket_name}/package/agent.pkl" : null
  pkg_req_gcs_uri = var.deployment_type == "gcs_package" ? "gs://${var.staging_bucket_name}/package/requirements.txt" : null
  pkg_dep_gcs_uri = (var.deployment_type == "gcs_package" && var.local_dependencies_path != "") ? "gs://${var.staging_bucket_name}/package/dependencies.tar.gz" : null
}

# ── Enable Required APIs ───────────────────────────────────────────────────────

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

# ── GCS Staging Bucket ────────────────────────────────────────────────────────

resource "google_storage_bucket" "staging" {
  name                        = var.staging_bucket_name
  project                     = var.project_id
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = false
  labels                      = var.labels

  versioning {
    enabled = false
  }
}

# ── GCS Object Uploads: source_code ───────────────────────────────────────────

resource "google_storage_bucket_object" "source_archive" {
  count  = var.deployment_type == "source_code" && var.local_source_archive_path != "" ? 1 : 0
  name   = "source/agent_source.tar.gz"
  bucket = google_storage_bucket.staging.name
  source = var.local_source_archive_path
}

resource "google_storage_bucket_object" "source_requirements" {
  count  = var.deployment_type == "source_code" && var.local_requirements_path != "" ? 1 : 0
  name   = "source/requirements.txt"
  bucket = google_storage_bucket.staging.name
  source = var.local_requirements_path
}

# ── GCS Object Uploads: gcs_package ───────────────────────────────────────────

resource "google_storage_bucket_object" "pickle_object" {
  count  = var.deployment_type == "gcs_package" && var.local_pickle_path != "" ? 1 : 0
  name   = "package/agent.pkl"
  bucket = google_storage_bucket.staging.name
  source = var.local_pickle_path
}

resource "google_storage_bucket_object" "package_requirements" {
  count  = var.deployment_type == "gcs_package" && var.local_requirements_path != "" ? 1 : 0
  name   = "package/requirements.txt"
  bucket = google_storage_bucket.staging.name
  source = var.local_requirements_path
}

resource "google_storage_bucket_object" "dependencies_archive" {
  count  = var.deployment_type == "gcs_package" && var.local_dependencies_path != "" ? 1 : 0
  name   = "package/dependencies.tar.gz"
  bucket = google_storage_bucket.staging.name
  source = var.local_dependencies_path
}

# ── Artifact Registry: BYOC ───────────────────────────────────────────────────

resource "google_project_service" "artifact_registry" {
  count              = var.deployment_type == "byoc" ? 1 : 0
  project            = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "agents" {
  count         = var.deployment_type == "byoc" && var.artifact_registry_repo_id != "" ? 1 : 0
  project       = var.project_id
  location      = var.region
  repository_id = var.artifact_registry_repo_id
  format        = "DOCKER"
  description   = "Docker images for GCP Agent Runtime (BYOC) — Public"
  labels        = var.labels

  depends_on = [google_project_service.artifact_registry]
}

# ── IAM: Service Account ──────────────────────────────────────────────────────

resource "google_service_account" "agent_runtime" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "Agent Runtime SA — ${var.display_name} (Public)"
}

resource "google_project_iam_member" "aiplatform_user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.agent_runtime.email}"
}

resource "google_project_iam_member" "storage_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.agent_runtime.email}"
}

resource "google_project_iam_member" "artifact_registry_reader" {
  count   = var.deployment_type == "byoc" ? 1 : 0
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.agent_runtime.email}"
}

# ── Module: agent-runtime ─────────────────────────────────────────────────────

module "agent_runtime" {
  source = "../../modules/agent-runtime"

  project_id      = var.project_id
  region          = var.region
  display_name    = var.display_name
  description     = var.description
  agent_framework = var.agent_framework
  deployment_type = var.deployment_type
  labels          = var.labels

  # source_code: pass computed GCS URIs (null when not active)
  source_code_config = var.deployment_type == "source_code" ? {
    source_archive_gcs_uri = local.source_archive_gcs_uri
    requirements_gcs_uri   = local.source_req_gcs_uri
    python_version         = var.source_code_config != null ? var.source_code_config.python_version : "3.11"
  } : null

  # gcs_package: pass computed GCS URIs (null when not active)
  gcs_package_config = var.deployment_type == "gcs_package" ? {
    pickle_gcs_uri       = local.pickle_gcs_uri
    requirements_gcs_uri = local.pkg_req_gcs_uri
    dependencies_gcs_uri = local.pkg_dep_gcs_uri
    python_version       = var.gcs_package_config != null ? var.gcs_package_config.python_version : "3.11"
  } : null

  # byoc: pass image_uri directly from tfvars
  byoc_config = var.byoc_config

  min_instances         = var.min_instances
  max_instances         = var.max_instances
  container_concurrency = var.container_concurrency
  env_vars              = var.env_vars
  resource_limits       = var.resource_limits
  class_methods         = var.class_methods

  depends_on = [
    google_project_service.aiplatform,
    google_service_account.agent_runtime,
    google_storage_bucket_object.source_archive,
    google_storage_bucket_object.source_requirements,
    google_storage_bucket_object.pickle_object,
    google_storage_bucket_object.package_requirements,
    google_storage_bucket_object.dependencies_archive,
    google_artifact_registry_repository.agents,
  ]
}
