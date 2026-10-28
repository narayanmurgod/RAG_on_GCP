# Vertex AI RAG Engine (Managed RAG Corpus) Module

This module provisions a turnkey serverless RAG Corpus (`google_vertex_ai_rag_corpus`) on Google Cloud Vertex AI, eliminating the operational complexity of managing vector databases, index endpoints, or shard sizing.

## Features

- **Zero DB Management**: Out-of-the-box managed Vector DB supporting exact `knn` or fast scalable `ann` tree search.
- **Dedicated Vector Search Bridging**: Can optionally point to a custom Vertex AI Vector Search Index & Endpoint if specialized high-throughput infrastructure is needed.
- **Automated Document Staging**: Provisions a secure GCS bucket configured for uploading documents (PDFs, DOCX, Markdown, etc.) ready for RAG ingestion.

## Usage

```hcl
module "rag_engine" {
  source = "../../modules/rag-engine"

  project_id   = "my-gcp-project"
  region       = "us-central1"
  display_name = "quickstart-rag-corpus"
  description  = "Enterprise policy and documentation RAG corpus"
  db_type      = "rag_managed_knn"

  create_staging_bucket = true
}
```
