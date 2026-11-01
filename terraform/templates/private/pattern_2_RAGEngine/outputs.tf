# Outputs for pattern_2_RAGEngine (Private)

output "corpus_name" {
  description = "Full resource name of the Vertex AI RAG Corpus."
  value       = module.rag_engine.corpus_name
}

output "corpus_id" {
  description = "Short ID of the Vertex AI RAG Corpus."
  value       = module.rag_engine.corpus_id
}

output "vector_db_type" {
  description = "Vector database backend configured for this deployment."
  value       = var.vector_db_type
}

output "staging_bucket_name" {
  description = "GCS bucket name for document ingestion."
  value       = module.rag_engine.staging_bucket_name
}

output "staging_bucket_uri" {
  description = "GCS URI for uploading documents to the RAG Corpus."
  value       = module.rag_engine.staging_bucket_uri
}

output "service_account_email" {
  description = "Email of the service account for RAG Engine operations."
  value       = google_service_account.rag_engine.email
}

output "allowed_invoker_members" {
  description = "List of IAM identities granted access to invoke the private RAG service."
  value       = var.allowed_invoker_members
}

output "vpc_connector_id" {
  description = "Serverless VPC Access connector ID used for private Cloud Run egress (null when enable_cloud_run = false)."
  value       = local.resolved_vpc_connector_id
}

output "cloud_run_url" {
  description = "Private Cloud Run service URL (null when enable_cloud_run = false)."
  value       = var.enable_cloud_run ? module.cloud_run[0].service_url : null
}

output "vector_search_index_id" {
  description = "Vertex AI Vector Search Index ID (null unless vector_db_type = vertex_vector_search)."
  value       = var.vector_db_type == "vertex_vector_search" ? module.vector_search[0].index_id : null
}

output "pinecone_secret_name" {
  description = "Secret Manager secret name for Pinecone API key (null unless vector_db_type = pinecone)."
  value       = var.vector_db_type == "pinecone" ? module.pinecone[0].secret_name : null
}

output "weaviate_api_key_secret_name" {
  description = "Secret Manager secret name for Weaviate API key (null unless vector_db_type = weaviate)."
  value       = var.vector_db_type == "weaviate" ? module.weaviate[0].api_key_secret_name : null
}
