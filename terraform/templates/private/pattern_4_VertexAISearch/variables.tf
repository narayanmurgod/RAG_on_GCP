# Input variables for pattern_4_VertexAISearch (Private)

# ── Core ──────────────────────────────────────────────────────────────────────

variable "project_id" {
  type        = string
  description = "GCP Project ID hosting the private Vertex AI Search / Discovery Engine resources."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for regional resources like the private GCS staging bucket."
}

variable "location" {
  type        = string
  default     = "global"
  description = "Location for Discovery Engine data store (e.g. global, us, eu)."
}

variable "display_name" {
  type        = string
  default     = "pattern4-vertex-ai-search"
  description = "Display name prefix for private Vertex AI Search resources."
}

variable "labels" {
  type = map(string)
  default = {
    environment = "private"
    pattern     = "pattern-4-vertexaisearch"
    managed-by  = "aip-terraform"
  }
  description = "Resource labels attached to all resources."
}

# ── IAM & Access Control ──────────────────────────────────────────────────────

variable "allowed_invoker_members" {
  type        = list(string)
  default     = []
  description = "List of IAM identities granted access to query/view the Discovery Engine Search service (e.g. 'serviceAccount:sa@project.iam.gserviceaccount.com')."
}

# ── Discovery Engine Data Store Configuration ─────────────────────────────────

variable "data_store_id" {
  type        = string
  default     = "pattern4-data-store"
  description = "Unique ID for the Discovery Engine Data Store (lowercase letters, numbers, hyphens)."
}

variable "industry_vertical" {
  type        = string
  default     = "GENERIC"
  description = "Industry vertical for the data store (e.g. GENERIC, MEDIA, HEALTHCARE_FHIR)."
}

variable "content_config" {
  type        = string
  default     = "CONTENT_REQUIRED"
  description = "Content config for unstructured data (e.g. NO_CONTENT, CONTENT_REQUIRED, PUBLIC_WEBSITE)."
}

variable "solution_types" {
  type        = list(string)
  default     = ["SOLUTION_TYPE_SEARCH"]
  description = "Solution types for the data store (e.g. SOLUTION_TYPE_SEARCH, SOLUTION_TYPE_CHAT)."
}

# ── Discovery Engine Search Engine Configuration ──────────────────────────────

variable "create_search_engine" {
  type        = bool
  default     = true
  description = "Whether to deploy a search engine linked to the data store."
}

variable "engine_id" {
  type        = string
  default     = ""
  description = "Unique ID for the Search Engine. Defaults to data_store_id-engine if empty."
}

variable "collection_id" {
  type        = string
  default     = "default_collection"
  description = "Discovery Engine collection ID (typically default_collection)."
}

variable "search_tier" {
  type        = string
  default     = "SEARCH_TIER_ENTERPRISE"
  description = "Search tier: SEARCH_TIER_STANDARD or SEARCH_TIER_ENTERPRISE."
}

variable "search_add_ons" {
  type        = list(string)
  default     = ["SEARCH_ADD_ON_LLM"]
  description = "Add-on features to enable (e.g. SEARCH_ADD_ON_LLM for generative answers & summarization)."
}

# ── Cloud Storage Document Staging Bucket (Private) ───────────────────────────

variable "create_staging_bucket" {
  type        = bool
  default     = true
  description = "Whether to create a Cloud Storage staging bucket for document uploads and ingestion."
}

variable "staging_bucket_name" {
  type        = string
  default     = ""
  description = "Name of the GCS bucket. If empty and create_staging_bucket is true, a name will be generated."
}
