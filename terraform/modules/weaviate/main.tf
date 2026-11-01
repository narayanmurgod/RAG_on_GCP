# Secret Manager secrets and IAM accessor bindings for Weaviate API key and cluster URL

# Secret Manager secret resource for Weaviate API key
resource "google_secret_manager_secret" "api_key" {
  project   = var.project_id
  secret_id = "${var.secret_id_prefix}-api-key"
  labels    = var.labels

  replication {
    auto {}
  }
}

# Secret payload version storing the sensitive API key
resource "google_secret_manager_secret_version" "api_key_version" {
  secret      = google_secret_manager_secret.api_key.id
  secret_data = var.api_key
}

# Secret Manager secret resource for Weaviate Cluster URL / Endpoint
resource "google_secret_manager_secret" "cluster_url" {
  project   = var.project_id
  secret_id = "${var.secret_id_prefix}-cluster-url"
  labels    = var.labels

  replication {
    auto {}
  }
}

# Secret payload version storing the sensitive Cluster URL
resource "google_secret_manager_secret_version" "cluster_url_version" {
  secret      = google_secret_manager_secret.cluster_url.id
  secret_data = var.cluster_url
}

# Grant secret accessor IAM role for API key to authorized service accounts
resource "google_secret_manager_secret_iam_member" "api_key_accessors" {
  for_each  = toset(var.authorized_service_accounts)
  project   = var.project_id
  secret_id = google_secret_manager_secret.api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${each.value}"
}

# Grant secret accessor IAM role for Cluster URL to authorized service accounts
resource "google_secret_manager_secret_iam_member" "cluster_url_accessors" {
  for_each  = toset(var.authorized_service_accounts)
  project   = var.project_id
  secret_id = google_secret_manager_secret.cluster_url.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${each.value}"
}
