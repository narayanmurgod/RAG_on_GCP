# Cloud Run RAG Serving Module

This module provisions a containerized FastAPI microservice on Google Cloud Run optimized for high-throughput, low-latency streaming Retrieval-Augmented Generation (RAG).

## Features

- **Serverless Scaling**: Scales from 0 instances (Quickstart mode) up to N instances with autoscaling.
- **VPC Egress Support**: Can attach directly to a Serverless VPC Access connector for private communication with databases (Spanner, AlloyDB, Cloud SQL, etc.).
- **Built-in Security**: Dedicated Service Account pre-configured with `roles/aiplatform.user`, `roles/logging.logWriter`, and `roles/cloudtrace.agent`.

## Usage

```hcl
module "cloud_run" {
  source = "../../modules/cloud-run-rag"

  project_id      = "my-gcp-project"
  region          = "us-central1"
  service_name    = "rag-api-service"
  min_instances   = 0
  max_instances   = 5
  container_image = "us-docker.pkg.dev/my-project/rag-repo/fastapi-rag:latest"

  env_vars = {
    RAG_CORPUS_NAME = module.rag_engine.corpus_name
    MODEL_NAME      = "gemini-1.5-flash"
  }
}
```
