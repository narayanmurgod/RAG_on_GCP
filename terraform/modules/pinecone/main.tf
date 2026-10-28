# Secret Manager secret and IAM accessor binding for Pinecone API keys

# Secret Manager secret resource for Pinecone API key
resource "google_secret_manager_secret" "api_key" {
  project   = var.project_id
  secret_id = "${var.secret_id_prefix}-api-key"
  labels    = var.labels

  replication {
    auto {}
  }
}

# Secret payload version storing the sensitive key
resource "google_secret_manager_secret_version" "api_key_version" {
  secret      = google_secret_manager_secret.api_key.id
  secret_data = var.api_key
}

# Grant secret accessor IAM role to authorized service accounts
resource "google_secret_manager_secret_iam_member" "accessors" {
  for_each  = toset(var.authorized_service_accounts)
  project   = var.project_id
  secret_id = google_secret_manager_secret.api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${each.value}"
}
