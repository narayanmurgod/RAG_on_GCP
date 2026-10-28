# Output definitions for the Serverless RAG Quickstart template

# Public HTTPS URL of the Cloud Run FastAPI RAG service
output "service_uri" {
  description = "The public HTTPS endpoint URL of the Cloud Run FastAPI RAG service."
  value       = module.cloud_run.service_uri
}

# Full resource name of the Vertex AI RAG Corpus
output "rag_corpus_name" {
  description = "Resource name of the Vertex AI RAG Corpus."
  value       = module.rag_engine.corpus_name
}

# Cloud Storage bucket URI for uploading documents to be indexed
output "staging_bucket_uri" {
  description = "Cloud Storage bucket URI for uploading documents to be indexed."
  value       = module.rag_engine.staging_bucket_uri
}

# Email of the service account running the Cloud Run service
output "service_account_email" {
  description = "Service account running the Cloud Run RAG service."
  value       = module.cloud_run.service_account_email
}
