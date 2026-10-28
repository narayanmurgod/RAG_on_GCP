# Vertex AI Search / Discovery Engine Module

This module provisions Google Cloud's turnkey semantic search engine (`google_discovery_engine_data_store` and `google_discovery_engine_search_engine`), enabling out-of-the-box chunking, automatic embedding generation, semantic retrieval, and extractive summaries for enterprise RAG.

## Features

- **Turnkey Ingestion**: Prepares unstructured document storage with zero database maintenance.
- **LLM Grounding Ready**: Configured with `SEARCH_ADD_ON_LLM` for generative answers and inline citations.

## Usage

```hcl
module "discovery_engine" {
  source = "../../modules/discovery-engine"

  project_id    = "my-gcp-project"
  location      = "global"
  data_store_id = "enterprise-docs-store"
  display_name  = "Enterprise Documents"

  create_search_engine = true
  search_tier          = "SEARCH_TIER_STANDARD"
}
```
