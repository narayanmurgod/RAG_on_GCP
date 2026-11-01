# Sample variable inputs for pattern_1_RAGEngine (Public)

project_id   = "my-gcp-project"
region       = "us-central1"
display_name = "pattern1-rag-engine"
description  = "Vertex AI RAG Engine — Public Pattern 1"

labels = {
  environment = "public"
  pattern     = "pattern-1-ragengine"
  managed-by  = "aip-terraform"
}

# ── Vector DB Backend ─────────────────────────────────────────────────────────
# Options: "rag_managed_knn" | "rag_managed_ann" | "vertex_vector_search" | "pinecone" | "weaviate"
vector_db_type        = "rag_managed_knn"
create_staging_bucket = true
# staging_bucket_name = "my-gcp-project-rag-staging-bucket"

# ── Optional: Cloud Run Serving Layer ─────────────────────────────────────────
enable_cloud_run      = false
container_image       = "us-docker.pkg.dev/cloudrun/container/hello"
min_instances         = 0
max_instances         = 5
allow_unauthenticated = true
embedding_model       = "text-embedding-004"
generation_model      = "gemini-1.5-flash"

# ── When vector_db_type = "vertex_vector_search" ──────────────────────────────
# vs_dimensions       = 768
# vs_algorithm        = "tree_ah"
# vs_distance_measure = "DOT_PRODUCT_DISTANCE"
# vs_machine_type      = "e2-standard-2"
# vs_min_replicas      = 1
# vs_max_replicas      = 3

# ── When vector_db_type = "pinecone" ──────────────────────────────────────────
# pinecone_api_key     = "pcsk_your_pinecone_api_key"
# pinecone_environment = "us-east-1"
# pinecone_index_name  = "rag-knowledge-index"

# ── When vector_db_type = "weaviate" ──────────────────────────────────────────
# weaviate_api_key     = "your-weaviate-api-key"
# weaviate_cluster_url = "https://your-cluster.weaviate.cloud"
# weaviate_collection  = "RAGCollection"
