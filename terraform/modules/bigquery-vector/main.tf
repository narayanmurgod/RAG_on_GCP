# BigQuery dataset and vector embeddings table for analytical RAG

# BigQuery dataset resource
resource "google_bigquery_dataset" "this" {
  project                    = var.project_id
  dataset_id                 = var.dataset_id
  location                   = var.location
  description                = var.description
  labels                     = var.labels
  delete_contents_on_destroy = var.delete_contents_on_destroy
}

# BigQuery table resource schema configured for VECTOR_SEARCH()
resource "google_bigquery_table" "documents" {
  project             = var.project_id
  dataset_id          = google_bigquery_dataset.this.dataset_id
  table_id            = var.table_id
  labels              = var.labels
  deletion_protection = false

  # Pre-configured schema with dense FLOAT64 array embedding
  schema = jsonencode([
    {
      name        = "doc_id"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Unique document chunk identifier"
    },
    {
      name        = "content"
      type        = "STRING"
      mode        = "NULLABLE"
      description = "Raw text content of the passage"
    },
    {
      name        = "metadata"
      type        = "JSON"
      mode        = "NULLABLE"
      description = "Extensible structured metadata"
    },
    {
      name        = "embedding"
      type        = "FLOAT64"
      mode        = "REPEATED"
      description = "Dense vector representation for VECTOR_SEARCH()"
    },
    {
      name        = "created_at"
      type        = "TIMESTAMP"
      mode        = "NULLABLE"
      description = "Ingestion timestamp"
    }
  ])
}
