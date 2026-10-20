# Vertex AI Vector Search Terraform Module

An enterprise-grade Terraform module for provisioning Google Cloud **Vertex AI Vector Search** (formerly Matching Engine) to power high-scale, low-latency Retrieval-Augmented Generation (RAG) applications.

---

## Architecture Overview

```
+─────────────────────────────────────────────────────────────────────────────+
|                          VERTEX AI VECTOR SEARCH                            |
|                                                                             |
|  +─────────────────────────+            +────────────────────────────────+  |
|  |  google_vertex_ai_index |            | google_vertex_ai_index_endpoint|  |
|  |  * Dimensions (768)     |            | * Public Endpoint (IAM Auth)   |  |
|  |  * ScaNN Tree-AH        |            |   OR                           |  |
|  |  * Stream / Batch Mode  |            | * Private VPC / PSC            |  |
|  +───────────┬─────────────+            +───────────────┬────────────────+  |
|              │                                          │                   |
|              │        google_vertex_ai_index_endpoint_  │                   |
|              └───────>        deployed_index    <───────┘                   |
|                       * Dedicated machine (e2-standard-16)                  |
|                       * Autoscaling (min 1, max 2 replicas)                 |
+─────────────────────────────────────────────────────────────────────────────+
```

---

## Features

- **Google ScaNN Algorithm**: Employs Tree-AH (Tree-based Approximate Nearest Neighbor with anisotropic vector quantization) for single-digit millisecond query latency.
- **Real-Time Stream Updates**: Default `STREAM_UPDATE` mode allows online insertion, updating, and deletion of vector embeddings via the Vertex AI SDK.
- **Dual Networking Topology**: Supports both public HTTPS endpoints authenticated via Google IAM and private enterprise zero-trust configurations via VPC Peering or Private Service Connect (PSC).
- **Flexible Vector Configurations**: Built-in validation for embedding dimensions (e.g., 768 for `text-embedding-004`, 1536 for OpenAI models), distance metrics (`DOT_PRODUCT_DISTANCE`, `COSINE_DISTANCE`, `SQUARED_L2_DISTANCE`), and shard sizing.
- **Automated Deployment**: Automatically deploys the index to the index endpoint with dedicated machine specs and auto-scaling rules.

---

## Usage Example

### Public Endpoint Mode

```hcl
module "vector_search" {
  source = "../../modules/vector-search"

  project_id   = "my-gcp-project"
  region       = "us-central1"
  display_name = "rag-knowledge-base"
  description  = "RAG Vector Index for enterprise policy documents"

  # Embedding config for text-embedding-004
  dimensions            = 768
  distance_measure_type = "DOT_PRODUCT_DISTANCE"
  index_update_method   = "STREAM_UPDATE"

  # Public endpoint with IAM authentication
  public_endpoint_enabled = true

  # Compute sizing
  machine_type = "e2-standard-16"
  min_replicas = 1
  max_replicas = 2

  labels = {
    environment = "dev"
    managed_by  = "terraform"
  }
}
```

### Private VPC / PSC Mode

```hcl
module "vector_search" {
  source = "../../modules/vector-search"

  project_id   = "my-gcp-project"
  region       = "us-central1"
  display_name = "rag-knowledge-base-private"

  dimensions            = 768
  distance_measure_type = "DOT_PRODUCT_DISTANCE"

  # Private networking via VPC Peering
  public_endpoint_enabled = false
  network                 = "projects/123456789/global/networks/ai-vpc"

  machine_type = "e2-standard-16"
  min_replicas = 1
  max_replicas = 2
}
```

---

## Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `project_id` | GCP Project ID | `string` | n/a | yes |
| `region` | GCP region for Vector Search | `string` | `"us-central1"` | no |
| `display_name` | Human-readable display name for the Index | `string` | n/a | yes |
| `description` | Description attached to the Index | `string` | `"Vertex AI Vector Search Index deployed via AIP Terraform Module"` | no |
| `labels` | Resource labels | `map(string)` | `{}` | no |
| `dimensions` | Dimensionality of embeddings | `number` | `768` | no |
| `approximate_neighbors_count` | Default count of nearest neighbors returned | `number` | `150` | no |
| `distance_measure_type` | `DOT_PRODUCT_DISTANCE`, `COSINE_DISTANCE`, `SQUARED_L2_DISTANCE` | `string` | `"DOT_PRODUCT_DISTANCE"` | no |
| `shard_size` | Index shard size (`SHARD_SIZE_SMALL`, `MEDIUM`, `LARGE`) | `string` | `"SHARD_SIZE_SMALL"` | no |
| `algorithm` | `tree_ah` or `brute_force` | `string` | `"tree_ah"` | no |
| `tree_ah_leaf_node_embedding_count` | Number of embeddings per leaf node | `number` | `1000` | no |
| `tree_ah_leaf_nodes_to_search_percent` | Percentage of leaf nodes searched (1-100) | `number` | `10` | no |
| `index_update_method` | `STREAM_UPDATE` or `BATCH_UPDATE` | `string` | `"STREAM_UPDATE"` | no |
| `contents_delta_uri` | Optional GCS URI with embeddings data | `string` | `null` | no |
| `public_endpoint_enabled` | Enable public HTTPS endpoint with IAM auth | `bool` | `true` | no |
| `network` | VPC network resource ID for private peering | `string` | `null` | no |
| `enable_private_service_connect` | Enable Private Service Connect | `bool` | `false` | no |
| `psc_project_allowlist` | GCP project IDs allowed via PSC | `list(string)` | `[]` | no |
| `deploy_index` | Deploy the index to the endpoint | `bool` | `true` | no |
| `machine_type` | Machine type for serving nodes | `string` | `"e2-standard-16"` | no |
| `min_replicas` | Minimum node replicas | `number` | `1` | no |
| `max_replicas` | Maximum node replicas | `number` | `2` | no |

---

## Outputs

| Name | Description |
| :--- | :--- |
| `index_id` | Full resource ID of the Vertex AI Vector Search Index |
| `index_name` | Display name of the Vector Search Index |
| `index_endpoint_id` | Full resource ID of the Index Endpoint |
| `index_endpoint_name` | Display name of the Index Endpoint |
| `public_endpoint_domain_name` | DNS domain name of the public endpoint |
| `deployed_index_id` | Deployed index ID used for query matching |
| `region` | GCP region of deployment |
| `project_id` | GCP project ID |
