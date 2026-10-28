# Cloud SQL for PostgreSQL Module (with pgvector)

This module provisions a managed PostgreSQL database on Cloud SQL configured with `cloudsql.enable_pgvector = on` for vector search alongside application data.

## Features

- **pgvector Built-in**: Enables the `cloudsql.enable_pgvector` database flag on creation.
- **Private VPC Compatible**: Can connect to a private VPC network for secure communication with Cloud Run services.

## Usage

```hcl
module "cloud_sql" {
  source = "../../modules/cloud-sql-pg"

  project_id      = "my-gcp-project"
  region          = "us-central1"
  instance_name   = "rag-cloudsql-pg"
  database_name   = "rag_knowledge_db"
  user_name       = "rag_user"
  user_password   = "SecurePassword123!"
  private_network = module.networking.network_id
}
```
