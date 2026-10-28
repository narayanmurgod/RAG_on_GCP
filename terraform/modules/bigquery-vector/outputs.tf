# Output definitions for the BigQuery Vector Search module

# The BigQuery dataset ID
output "dataset_id" {
  description = "The BigQuery dataset ID."
  value       = google_bigquery_dataset.this.dataset_id
}

# The BigQuery table ID storing vector embeddings
output "table_id" {
  description = "The BigQuery table ID storing vector embeddings."
  value       = google_bigquery_table.documents.table_id
}

# Fully-qualified table identifier (project.dataset.table) for SQL queries
output "table_full_id" {
  description = "Fully-qualified table identifier (project.dataset.table) for SQL queries."
  value       = "${var.project_id}.${google_bigquery_dataset.this.dataset_id}.${google_bigquery_table.documents.table_id}"
}
