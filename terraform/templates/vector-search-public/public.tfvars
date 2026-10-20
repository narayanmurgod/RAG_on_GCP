project_id   = "my-gcp-project-id"
region       = "us-central1"
display_name = "rag-vector-search-public"
description  = "Vertex AI Vector Search Index with Public Endpoint for RAG"

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
  environment = "dev"
  workload    = "rag"
  managed_by  = "aip-terraform"
}
