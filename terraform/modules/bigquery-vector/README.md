# BigQuery Vector Search Module

This module provisions a BigQuery dataset and embedding schema table configured for SQL-native vector search (`VECTOR_SEARCH()` and `ML.GENERATE_EMBEDDING`) across large analytical document corpuses without moving data.

## Features

- **Petabyte-Scale Search**: Optimized for batch RAG and analytical queries over enterprise data.
- **Pre-configured Schema**: Standardized schema supporting dense vectors (`FLOAT64 REPEATED`) and JSON metadata.

## Usage

```hcl
module "bigquery_vector" {
  source = "../../modules/bigquery-vector"

  project_id = "my-gcp-project"
  location   = "US"
  dataset_id = "enterprise_rag_analytics"
  table_id   = "document_embeddings"
}
```
