# Input variables for the Vertex AI Search and Discovery Engine module

# GCP project ID hosting Discovery Engine resources
variable "project_id" {
  type        = string
  description = "GCP Project ID hosting Vertex AI Search / Discovery Engine resources."
}

# Location for Discovery Engine data store (e.g. global, us, eu)
variable "location" {
  type        = string
  default     = "global"
  description = "Location for Discovery Engine data store (e.g. global, us, eu)."
}

# Unique ID for the Discovery Engine Data Store
variable "data_store_id" {
  type        = string
  description = "Unique ID for the Discovery Engine Data Store (lowercase letters, numbers, hyphens)."
}

# Human-readable display name for the Data Store
variable "display_name" {
  type        = string
  description = "Human-readable display name for the Data Store."
}

# Industry vertical classification for the data store
variable "industry_vertical" {
  type        = string
  default     = "GENERIC"
  description = "Industry vertical for the data store (e.g. GENERIC, MEDIA, HEALTHCARE_FHIR)."
}

# Content configuration for unstructured document storage
variable "content_config" {
  type        = string
  default     = "CONTENT_REQUIRED"
  description = "Content config for unstructured data (e.g. NO_CONTENT, CONTENT_REQUIRED, PUBLIC_WEBSITE)."
}

# Supported solution types for the data store
variable "solution_types" {
  type        = list(string)
  default     = ["SOLUTION_TYPE_SEARCH"]
  description = "Solution types for the data store (e.g. SOLUTION_TYPE_SEARCH, SOLUTION_TYPE_CHAT)."
}

# Whether to create a search engine linked to the data store
variable "create_search_engine" {
  type        = bool
  default     = true
  description = "Whether to deploy a search engine linked to the data store."
}

# Unique ID for the Search Engine
variable "engine_id" {
  type        = string
  default     = ""
  description = "Unique ID for the Search Engine. Defaults to data_store_id-engine if empty."
}

# Collection ID within Discovery Engine
variable "collection_id" {
  type        = string
  default     = "default_collection"
  description = "Discovery Engine collection ID (typically default_collection)."
}

# Service tier for the search engine
variable "search_tier" {
  type        = string
  default     = "SEARCH_TIER_STANDARD"
  description = "Search tier: SEARCH_TIER_STANDARD or SEARCH_TIER_ENTERPRISE."
}

# Optional add-on features like generative answers with LLMs
variable "search_add_ons" {
  type        = list(string)
  default     = ["SEARCH_ADD_ON_LLM"]
  description = "Add-on features to enable (e.g. SEARCH_ADD_ON_LLM for generative answers & summarization)."
}
