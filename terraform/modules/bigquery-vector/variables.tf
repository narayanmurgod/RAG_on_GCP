# Input variables for the BigQuery Vector Search module

# GCP project ID hosting the dataset
variable "project_id" {
  type        = string
  description = "GCP Project ID hosting the BigQuery dataset."
}

# Geographic location for the dataset
variable "location" {
  type        = string
  default     = "US"
  description = "Geographic location for the BigQuery dataset (e.g. US, EU, us-central1)."
}

# Unique ID for the BigQuery dataset
variable "dataset_id" {
  type        = string
  description = "Unique ID for the BigQuery dataset."
}

# Description of the dataset
variable "description" {
  type        = string
  default     = "BigQuery Vector Search Dataset for Analytical RAG"
  description = "Description for the dataset."
}

# Name of the table storing document embeddings
variable "table_id" {
  type        = string
  default     = "rag_documents"
  description = "Name of the BigQuery table storing document embeddings."
}

# Resource labels attached to dataset and table
variable "labels" {
  type        = map(string)
  default     = {}
  description = "Resource labels attached to the dataset and table."
}

# Whether to delete all tables on dataset destruction
variable "delete_contents_on_destroy" {
  type        = bool
  default     = false
  description = "Whether to delete all tables in the dataset when destroying the dataset."
}
