# Output definitions for the Vertex AI RAG Engine module

# Full resource name of the Vertex AI RAG Corpus
output "corpus_name" {
  description = "Resource name of the Vertex AI RAG Corpus (e.g. projects/{project}/locations/{region}/ragCorpora/{id})."
  value       = google_vertex_ai_rag_corpus.this.name
}

# The unique identifier of the created RAG Corpus
output "corpus_id" {
  description = "The ID of the created RAG Corpus."
  value       = element(split("/", google_vertex_ai_rag_corpus.this.name), length(split("/", google_vertex_ai_rag_corpus.this.name)) - 1)
}

# Display name of the RAG Corpus
output "display_name" {
  description = "Display name of the RAG Corpus."
  value       = google_vertex_ai_rag_corpus.this.display_name
}

# Region hosting the RAG Corpus
output "region" {
  description = "Region where the RAG Corpus is deployed."
  value       = var.region
}

# Name of the Cloud Storage document staging bucket
output "staging_bucket_name" {
  description = "The GCS bucket for document ingestion (if created)."
  value       = var.create_staging_bucket ? google_storage_bucket.staging[0].name : null
}

# GCS URI of the document staging bucket
output "staging_bucket_uri" {
  description = "GCS URI for uploading documents to be imported into the RAG Corpus."
  value       = var.create_staging_bucket ? "gs://${google_storage_bucket.staging[0].name}" : null
}
