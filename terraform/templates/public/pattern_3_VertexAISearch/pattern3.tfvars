# Sample variable inputs for pattern_3_VertexAISearch (Public)

project_id    = "my-gcp-project"
region        = "us-central1"
location      = "global"
display_name  = "pattern3-vertex-ai-search"
data_store_id = "pattern3-data-store"

industry_vertical    = "GENERIC"
content_config       = "CONTENT_REQUIRED"
create_search_engine = true
search_tier          = "SEARCH_TIER_STANDARD"
search_add_ons       = ["SEARCH_ADD_ON_LLM"]

create_staging_bucket = true
# staging_bucket_name = "my-gcp-project-search-staging"

labels = {
  environment = "public"
  pattern     = "pattern-3-vertexaisearch"
  managed-by  = "aip-terraform"
}
