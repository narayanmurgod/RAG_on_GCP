# Cloud Spanner Module for RAG & Graph RAG

This module provisions an enterprise-grade Google Cloud Spanner instance and database configured for high-scale Retrieval-Augmented Generation (RAG) and Graph-Augmented RAG.

## Features

- **Vector Search Ready**: Auto-generates `documents` table with `ARRAY<FLOAT64>(vector_length=>N)` and a `CREATE VECTOR INDEX` with configurable distance metrics (`COSINE`, `EUCLIDEAN`, `DOT_PRODUCT`).
- **Spanner Graph Support**: Creates `entities` and `relationships` tables together with `CREATE PROPERTY GRAPH KnowledgeGraph` for Graph RAG workflows.
- **Enterprise Security**: Supports Customer-Managed Encryption Keys (CMEK) and least-privilege IAM bindings (`roles/spanner.databaseUser`).
- **Scalable**: Supports fractional processing units (100 to 1000 PUs) up to multi-node configurations.

## Usage

```hcl
module "spanner" {
  source = "../../modules/spanner"

  project_id       = "my-gcp-project"
  instance_id      = "enterprise-rag-spanner"
  config           = "regional-us-central1"
  processing_units = 100

  database_name       = "rag_knowledge_db"
  embedding_dimension = 768
  distance_type       = "COSINE"
  enable_vector_index = true
  enable_graph_rag    = true

  authorized_service_accounts = [
    module.cloud_run.service_account_email
  ]
}
```
