# Sample variable inputs for pattern_8_CloudSQLRAG (Private)

project_id    = "my-gcp-project"
region        = "us-central1"
display_name  = "pattern8-cloudsql-rag"
instance_name = "pattern8-sql-instance"

database_version    = "POSTGRES_16"
tier                = "db-custom-2-7680"
database_name       = "rag_knowledge_db"
user_name           = "rag_app_user"
user_password       = "ChangeMe-SuperSecretP@ss123"
deletion_protection = false

# Private Access & Restricted Invokers
allowed_invoker_members = [
  "serviceAccount:backend-api-sa@my-gcp-project.iam.gserviceaccount.com"
]

# Networking Configuration
# Option A: Create a new VPC (use_existing_network = false)
use_existing_network = false
network_name         = "rag-sql-private-vpc"
app_subnet_cidr      = "10.0.1.0/24"
connector_cidr       = "10.8.0.0/28"
enable_nat_gateway   = true

# Option B: Use existing VPC (uncomment below and set use_existing_network = true)
# use_existing_network  = true
# existing_network_name = "projects/my-gcp-project/global/networks/my-existing-vpc"
# existing_connector_id = "projects/my-gcp-project/locations/us-central1/connectors/my-existing-connector"

# Optional: Cloud Storage staging bucket (Private)
create_staging_bucket = false
# staging_bucket_name = "my-gcp-project-sql-staging-pvt"

# Optional: Cloud Run Serving Layer (Private)
enable_cloud_run = false
container_image  = "us-docker.pkg.dev/cloudrun/container/hello"
min_instances    = 1
max_instances    = 5
embedding_model  = "text-embedding-004"
generation_model = "gemini-1.5-pro"

labels = {
  environment = "private"
  pattern     = "pattern-8-cloudsqlrag"
  managed-by  = "aip-terraform"
}
