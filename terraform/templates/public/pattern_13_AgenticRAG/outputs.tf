# Output definitions for pattern_13_AgenticRAG (Public)

output "reasoning_engine_id" {
  description = "The Vertex AI Reasoning Engine resource ID."
  value       = module.agent_runtime.reasoning_engine_id
}

output "reasoning_engine_name" {
  description = "Display name of the Reasoning Engine."
  value       = module.agent_runtime.reasoning_engine_name
}

output "rag_corpus_id" {
  description = "The unique identifier of the created RAG Corpus."
  value       = module.rag_engine.corpus_id
}

output "rag_corpus_name" {
  description = "Full resource name of the Vertex AI RAG Corpus."
  value       = module.rag_engine.corpus_name
}

output "service_account_email" {
  description = "Email of the service account created for Agentic RAG operations."
  value       = google_service_account.agent_rag.email
}

output "cloud_run_url" {
  description = "Cloud Run service URL (null when enable_cloud_run = false)."
  value       = var.enable_cloud_run ? module.cloud_run[0].service_url : null
}
