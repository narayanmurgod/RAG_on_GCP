# Sample variable inputs for pattern_2_RAGEngine (Private)

project_id   = "my-gcp-project"
region       = "us-central1"
display_name = "pattern2-rag-engine"
description  = "Vertex AI RAG Engine — Private Pattern 2"

labels = {
  environment = "private"
  pattern     = "pattern-2-ragengine"
  managed-by  = "aip-terraform"
}

# ── Private Access & Restricted Invokers ─────────────────────────────────────
allowed_invoker_members = [
  "serviceAccount:backend-api-sa@my-gcp-project.iam.gserviceaccount.com"
]

# ── Networking Configuration ──────────────────────────────────────────────────
# Option A: Create a new VPC (use_existing_network = false)
use_existing_network = false
network_name         = "rag-private-vpc"
app_subnet_cidr      = "10.0.1.0/24"
connector_cidr       = "10.8.0.0/28"
enable_nat_gateway   = true

# Option B: Use existing VPC (uncomment below and set use_existing_network = true)
# use_existing_network  = true
# existing_network_name = "projects/my-gcp-project/global/networks/my-existing-vpc"
# existing_connector_id = "projects/my-gcp-project/locations/us-central1/connectors/my-existing-connector"

# ── Vector DB Backend ─────────────────────────────────────────────────────────
# Options: "rag_managed_knn" | "rag_managed_ann" | "vertex_vector_search" | "pinecone" | "weaviate"
vector_db_type        = "rag_managed_knn"
create_staging_bucket = true
# staging_bucket_name = "my-gcp-project-rag-pvt-staging-bucket"

# ── Optional: Cloud Run Serving Layer ─────────────────────────────────────────
enable_cloud_run = false
container_image  = "us-docker.pkg.dev/cloudrun/container/hello"
min_instances    = 1
max_instances    = 5
embedding_model  = "text-embedding-004"
generation_model = "gemini-1.5-pro"

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
