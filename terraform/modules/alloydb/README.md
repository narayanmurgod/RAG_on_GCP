# AlloyDB for PostgreSQL Module (with ScaNN & pgvector)

This module provisions an AlloyDB for PostgreSQL cluster and primary instance within a private VPC, optimized for enterprise transactional RAG requiring ACID guarantees and ultra-fast ScaNN-indexed vector retrieval.

## Features

- **Private Networking**: Connects exclusively via Google Cloud VPC.
- **ScaNN Accelerated**: Built-in support for Google's ScaNN vector indexing algorithm alongside standard PostgreSQL `pgvector`.

## Usage

```hcl
module "alloydb" {
  source = "../../modules/alloydb"

  project_id            = "my-gcp-project"
  region                = "us-central1"
  cluster_id            = "enterprise-rag-alloydb"
  network_id            = module.networking.network_id
  initial_user_password = "SecurePassword123!"

  cpu_count = 2
}
```
