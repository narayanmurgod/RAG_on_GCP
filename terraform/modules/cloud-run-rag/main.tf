# Cloud Run service, dedicated IAM service account, and role bindings

# Dedicated service account for the Cloud Run microservice
resource "google_service_account" "cloud_run" {
  project      = var.project_id
  account_id   = "${substr(replace(lower(var.service_name), "/[^a-z0-9-]/", "-"), 0, 26)}-sa"
  display_name = "Cloud Run SA for ${var.service_name}"
}

# Grant Vertex AI user role for LLM generation and vector embeddings
resource "google_project_iam_member" "aiplatform_user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

# Grant Cloud Logging write permissions
resource "google_project_iam_member" "log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

# Grant Cloud Trace agent role for distributed tracing
resource "google_project_iam_member" "trace_agent" {
  project = var.project_id
  role    = "roles/cloudtrace.agent"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

# Cloud Run v2 service resource
resource "google_cloud_run_v2_service" "this" {
  project  = var.project_id
  location = var.region
  name     = var.service_name
  labels   = var.labels

  template {
    service_account = google_service_account.cloud_run.email

    containers {
      image = var.container_image

      ports {
        container_port = var.container_port
      }

      resources {
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
      }

      # Inject environment variables for model and database configuration
      dynamic "env" {
        for_each = var.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }
    }

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    # Optional Serverless VPC Access connector for private egress
    dynamic "vpc_access" {
      for_each = var.vpc_connector_id != null ? [1] : []
      content {
        connector = var.vpc_connector_id
        egress    = var.vpc_egress
      }
    }
  }
}

# Optional public unauthenticated invoker role binding
resource "google_cloud_run_v2_service_iam_member" "public_invoker" {
  count    = var.allow_unauthenticated ? 1 : 0
  project  = var.project_id
  location = google_cloud_run_v2_service.this.location
  name     = google_cloud_run_v2_service.this.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
