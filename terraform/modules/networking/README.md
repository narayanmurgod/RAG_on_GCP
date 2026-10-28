# Enterprise Networking Module

This module provisions an enterprise private VPC foundation on Google Cloud with Private Google Access, a dedicated `/28` Serverless VPC Access connector for Cloud Run egress, and an optional Cloud NAT gateway.

## Usage

```hcl
module "networking" {
  source = "../../modules/networking"

  project_id   = "my-gcp-project"
  region       = "us-central1"
  network_name = "enterprise-rag-vpc"
}
```
