# Enterprise sample variable inputs for Cloud Spanner RAG deployment

project_id               = "my-gcp-project"
region                   = "us-central1"
display_name             = "rag-enterprise"
spanner_config           = "regional-us-central1"
spanner_processing_units = 100
spanner_database_name    = "rag_knowledge_db"
embedding_dimension      = 768
spanner_distance_type    = "COSINE"
enable_spanner_graph_rag = true

network_name    = "rag-enterprise-vpc"
app_subnet_cidr = "10.0.1.0/24"
connector_cidr  = "10.8.0.0/28"

container_image       = "us-docker.pkg.dev/cloudrun/container/hello"
min_instances         = 1
max_instances         = 10
allow_unauthenticated = false

embedding_model  = "text-embedding-004"
generation_model = "gemini-1.5-pro"

labels = {
  environment = "enterprise"
  managed-by  = "aip-terraform"
}
