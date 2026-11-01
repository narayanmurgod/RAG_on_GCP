# Sample variable inputs for pattern_5_BigQueryRAG (Public)

project_id   = "my-gcp-project"
location     = "US"
region       = "us-central1"
display_name = "pattern5-bigquery-rag"
dataset_id   = "pattern5_rag_dataset"
table_id     = "rag_documents"

delete_contents_on_destroy = false

# Optional: Cloud Storage staging bucket for batch ingestion
create_staging_bucket = false
# staging_bucket_name = "my-gcp-project-bq-staging"

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
  pattern     = "pattern-5-bigqueryrag"
  managed-by  = "aip-terraform"
}
