# Sample variable inputs for pattern_6_BigQueryRAG (Private)

project_id   = "my-gcp-project"
location     = "US"
region       = "us-central1"
display_name = "pattern6-bigquery-rag"
dataset_id   = "pattern6_rag_dataset"
table_id     = "rag_documents"

delete_contents_on_destroy = false

# Private Access & Restricted Invokers
allowed_invoker_members = [
  "serviceAccount:backend-api-sa@my-gcp-project.iam.gserviceaccount.com"
]

# Networking Configuration
# Option A: Create a new VPC (use_existing_network = false)
use_existing_network = false
network_name         = "rag-bq-private-vpc"
app_subnet_cidr      = "10.0.1.0/24"
connector_cidr       = "10.8.0.0/28"
enable_nat_gateway   = true

# Option B: Use existing VPC (uncomment below and set use_existing_network = true)
# use_existing_network  = true
# existing_network_name = "projects/my-gcp-project/global/networks/my-existing-vpc"
# existing_connector_id = "projects/my-gcp-project/locations/us-central1/connectors/my-existing-connector"

# Optional: Cloud Storage staging bucket for batch ingestion (Private)
create_staging_bucket = false
# staging_bucket_name = "my-gcp-project-bq-staging-pvt"

# Optional: Cloud Run Serving Layer (Private)
enable_cloud_run = false
container_image  = "us-docker.pkg.dev/cloudrun/container/hello"
min_instances    = 1
max_instances    = 5
embedding_model  = "text-embedding-004"
generation_model = "gemini-1.5-pro"

labels = {
  environment = "private"
  pattern     = "pattern-6-bigqueryrag"
  managed-by  = "aip-terraform"
}
