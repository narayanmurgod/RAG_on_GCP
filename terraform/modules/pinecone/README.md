# Pinecone Integration Module

This module manages third-party SaaS Pinecone credentials securely in Google Cloud Secret Manager, granting least-privilege `roles/secretmanager.secretAccessor` IAM permissions to authorized compute workloads (such as Cloud Run RAG services).

## Usage

```hcl
module "pinecone" {
  source = "../../modules/pinecone"

  project_id = "my-gcp-project"
  api_key    = "pc-api-key-here"
  index_name = "knowledge-base"

  authorized_service_accounts = [
    module.cloud_run.service_account_email
  ]
}
```
