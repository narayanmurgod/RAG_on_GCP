# Quickstart sample variable inputs for Serverless RAG deployment

project_id            = "my-gcp-project"
region                = "us-central1"
display_name          = "rag-quickstart"
container_image       = "us-docker.pkg.dev/cloudrun/container/hello"
min_instances         = 0
max_instances         = 5
allow_unauthenticated = true
embedding_model       = "text-embedding-004"
generation_model      = "gemini-1.5-flash"

labels = {
  environment = "quickstart"
  managed-by  = "aip-terraform"
}
