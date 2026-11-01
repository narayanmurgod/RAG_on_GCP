# Sample variable inputs for pattern_4_VertexAISearch (Private)

project_id    = "my-gcp-project"
region        = "us-central1"
location      = "global"
display_name  = "pattern4-vertex-ai-search"
data_store_id = "pattern4-data-store"

# ── Private Access & Restricted Invokers ─────────────────────────────────────
allowed_invoker_members = [
  "serviceAccount:backend-api-sa@my-gcp-project.iam.gserviceaccount.com"
]

industry_vertical    = "GENERIC"
content_config       = "CONTENT_REQUIRED"
create_search_engine = true
search_tier          = "SEARCH_TIER_ENTERPRISE"
search_add_ons       = ["SEARCH_ADD_ON_LLM"]

create_staging_bucket = true
# staging_bucket_name = "my-gcp-project-search-staging-pvt"

labels = {
  environment = "private"
  pattern     = "pattern-4-vertexaisearch"
  managed-by  = "aip-terraform"
}
