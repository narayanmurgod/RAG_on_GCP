locals {
  class_methods_json = jsonencode([
    for m in var.class_methods : {
      name        = m.name
      description = m.description
    }
  ])
}

resource "google_vertex_ai_reasoning_engine" "this" {
  project      = var.project_id
  location     = var.region
  display_name = var.display_name
  description  = var.description

  spec {
    agent_framework = var.agent_framework
    class_methods   = local.class_methods_json

    # ── Deployment Type: source_code ─────────────────────────────────────────
    # Uploads a .tar.gz source archive + requirements.txt to GCS.
    # GCS URIs are created by the calling template, not this module.
    dynamic "package_spec" {
      for_each = var.deployment_type == "source_code" ? [1] : []
      content {
        dependency_files_gcs_uri = var.source_code_config.source_archive_gcs_uri
        requirements_gcs_uri     = var.source_code_config.requirements_gcs_uri
        python_version           = var.source_code_config.python_version
      }
    }

    # ── Deployment Type: gcs_package ─────────────────────────────────────────
    # Pre-pickled agent object (agent.pkl) + requirements + optional deps.
    # Pickle file must be generated externally (e.g. via cloudpickle) before apply.
    dynamic "package_spec" {
      for_each = var.deployment_type == "gcs_package" ? [1] : []
      content {
        pickle_object_gcs_uri    = var.gcs_package_config.pickle_gcs_uri
        requirements_gcs_uri     = var.gcs_package_config.requirements_gcs_uri
        dependency_files_gcs_uri = var.gcs_package_config.dependencies_gcs_uri
        python_version           = var.gcs_package_config.python_version
      }
    }

    # ── Scaling / env: source_code & gcs_package ─────────────────────────────
    dynamic "deployment_spec" {
      for_each = var.deployment_type != "byoc" ? [1] : []
      content {
        min_replicas          = var.min_instances
        max_replicas          = var.max_instances
        container_concurrency = var.container_concurrency
        env                   = var.env_vars
      }
    }

    # ── Deployment Type: byoc ─────────────────────────────────────────────────
    # Bring Your Own Container. Image URI must already exist in Artifact Registry.
    # Artifact Registry repo is created by the calling template, not this module.
    dynamic "deployment_spec" {
      for_each = var.deployment_type == "byoc" ? [1] : []
      content {
        min_replicas          = var.min_instances
        max_replicas          = var.max_instances
        container_concurrency = var.container_concurrency
        env                   = var.env_vars

        resource_limits = {
          cpu    = var.resource_limits.cpu
          memory = var.resource_limits.memory
        }
      }
    }
  }
}
