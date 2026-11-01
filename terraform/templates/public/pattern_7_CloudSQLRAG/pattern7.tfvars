# Sample variable inputs for pattern_7_CloudSQLRAG (Public)

project_id    = "my-gcp-project"
region        = "us-central1"
display_name  = "pattern7-cloudsql-rag"
instance_name = "pattern7-sql-instance"

database_version    = "POSTGRES_16"
tier                = "db-custom-2-7680"
database_name       = "rag_knowledge_db"
user_name           = "rag_app_user"
user_password       = "ChangeMe-SuperSecretP@ss123"
deletion_protection = false

# Optional: Cloud Storage staging bucket
create_staging_bucket = false
# staging_bucket_name = "my-gcp-project-sql-staging"

# Optional: Cloud Run Serving Layer
enable_cloud_run      = false
container_image       = "us-docker.pkg.dev/cloudrun/container/hello"
min_instances         = 0
max_instances         = 5
allow_unauthenticated = true
embedding_model       = "text-embedding-004"
generation_model      = "gemini-1.5-flash"

labels = {
  environment = "public"
  pattern     = "pattern-7-cloudsqlrag"
  managed-by  = "aip-terraform"
}
