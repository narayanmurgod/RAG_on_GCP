project_id   = "my-gcp-project-id"
region       = "us-central1"
display_name = "rag-vector-search-private"
description  = "Vertex AI Vector Search Index with Private Network Endpoint for Enterprise RAG"

# Networking (VPC Peering or Private Service Connect)
network                        = "projects/123456789/global/networks/ai-vpc"
enable_private_service_connect = false
psc_project_allowlist          = []
reserved_ip_ranges             = []

# Access Control
allowed_invoker_members = [
  "serviceAccount:app-backend-sa@my-gcp-project-id.iam.gserviceaccount.com"
]

# Storage
create_staging_bucket = true
staging_bucket_name   = ""

# Vector Index Configuration (Matched with text-embedding-004)
dimensions                  = 768
approximate_neighbors_count = 150
distance_measure_type       = "DOT_PRODUCT_DISTANCE"
shard_size                  = "SHARD_SIZE_SMALL"
algorithm                   = "tree_ah"
index_update_method         = "STREAM_UPDATE"

# Deployment & Compute
deploy_index = true
machine_type = "e2-standard-16"
min_replicas = 1
max_replicas = 2

labels = {
  environment = "prod"
  workload    = "rag"
  managed_by  = "aip-terraform"
}
