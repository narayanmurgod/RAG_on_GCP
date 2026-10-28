# agent-runtime

Reusable Terraform module for provisioning a **Vertex AI Agent Engine** (Reasoning Engine) on Google Cloud Platform.

## Design Philosophy

This module is intentionally **thin** — it owns only the `google_vertex_ai_reasoning_engine` resource. All supporting infrastructure (GCS bucket, IAM service accounts, Artifact Registry) is created by the **calling template** and passed in via input variables. This keeps the module composable and reusable across environments and deployment types.

## Three Deployment Types

| `deployment_type` | What it provisions | Best for |
|---|---|---|
| `source_code` | Managed runtime with `.tar.gz` source archive + `requirements.txt` on GCS | Standard ADK/Gemini agents, fast iteration |
| `gcs_package` | Managed runtime with pre-pickled `agent.pkl` + requirements on GCS | Serialized agents built via `cloudpickle` |
| `byoc` | Custom container image from Artifact Registry | Enterprise agents with custom runtimes or FastAPI wrappers |

Only **one** deployment type is active per instance, controlled by `var.deployment_type`.

## Module Files

```
agent-runtime/
├── main.tf       # google_vertex_ai_reasoning_engine resource (dynamic blocks per type)
├── variables.tf  # All input variables
├── outputs.tf    # Reasoning Engine ID, name, deployment_type, region, project
└── README.md     # This file
```

## Usage

This module is called from the deployment templates:

```
terraform/templates/public/   → calls this module with public.tfvars
terraform/templates/private/  → calls this module with private.tfvars
```

### Minimal Example (source_code)

```hcl
module "agent_runtime" {
  source = "../../modules/agent-runtime"

  project_id      = "my-gcp-project"
  region          = "us-central1"
  display_name    = "my-rag-agent"
  deployment_type = "source_code"

  source_code_config = {
    source_archive_gcs_uri = "gs://my-bucket/source/agent_source.tar.gz"
    requirements_gcs_uri   = "gs://my-bucket/source/requirements.txt"
    python_version         = "3.11"
  }

  min_instances = 0
  max_instances = 3
  env_vars = {
    MODEL_NAME  = "gemini-2.5-flash"
    ENVIRONMENT = "dev"
  }
}
```

### Minimal Example (gcs_package)

```hcl
module "agent_runtime" {
  source = "../../modules/agent-runtime"

  project_id      = "my-gcp-project"
  region          = "us-central1"
  display_name    = "my-pickled-agent"
  deployment_type = "gcs_package"

  gcs_package_config = {
    pickle_gcs_uri       = "gs://my-bucket/package/agent.pkl"
    requirements_gcs_uri = "gs://my-bucket/package/requirements.txt"
    # dependencies_gcs_uri is optional
    python_version       = "3.11"
  }
}
```

### Minimal Example (byoc)

```hcl
module "agent_runtime" {
  source = "../../modules/agent-runtime"

  project_id      = "my-gcp-project"
  region          = "us-central1"
  display_name    = "my-custom-agent"
  deployment_type = "byoc"

  byoc_config = {
    image_uri = "us-central1-docker.pkg.dev/my-project/agents/my-agent:v1.0.0"
  }

  resource_limits = {
    cpu    = "4"
    memory = "8Gi"
  }
}
```

> **Note:** For `byoc`, the Docker image must be pushed to Artifact Registry **before** `terraform apply`. The Artifact Registry repository is created in the calling template, not this module.

## Inputs

| Name | Type | Default | Required | Description |
|---|---|---|---|---|
| `project_id` | `string` | — | ✅ | GCP project ID |
| `region` | `string` | `us-central1` | | Vertex AI region |
| `display_name` | `string` | — | ✅ | Display name for the Reasoning Engine |
| `description` | `string` | `"GCP Agent Runtime..."` | | Resource description |
| `agent_framework` | `string` | `google-adk` | | Framework: `google-adk` \| `langchain` \| `langgraph` \| `llamaindex` \| `custom` |
| `deployment_type` | `string` | — | ✅ | `source_code` \| `gcs_package` \| `byoc` |
| `source_code_config` | `object` | `null` | if `source_code` | GCS URIs for source archive + requirements |
| `gcs_package_config` | `object` | `null` | if `gcs_package` | GCS URIs for pickle + requirements + deps |
| `byoc_config` | `object` | `null` | if `byoc` | Artifact Registry image URI |
| `min_instances` | `number` | `0` | | Min running instances (0 = scale-to-zero) |
| `max_instances` | `number` | `3` | | Max autoscaling instances |
| `container_concurrency` | `number` | `10` | | Max concurrent requests per instance |
| `env_vars` | `map(string)` | `{}` | | Environment variables injected at startup |
| `resource_limits` | `object` | `{cpu="2", memory="4Gi"}` | | CPU/memory limits (byoc only) |
| `class_methods` | `list(object)` | `[{name="query"}]` | | Agent interface methods |
| `labels` | `map(string)` | `{}` | | GCP resource labels |

## Outputs

| Name | Description |
|---|---|
| `reasoning_engine_id` | Full resource name: `projects/{p}/locations/{l}/reasoningEngines/{id}` |
| `reasoning_engine_name` | Display name registered in Vertex AI |
| `deployment_type` | Active deployment type |
| `region` | Deployment region |
| `project_id` | GCP project |

## Provider Requirement

```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0, < 9.0"
    }
  }
}
```

## Prerequisites

Before calling this module, the calling template must:
1. Enable the `aiplatform.googleapis.com` API on the project.
2. Create a GCS bucket and upload agent artifacts (for `source_code` / `gcs_package`).
3. Create and configure a Service Account with `roles/aiplatform.user` and `roles/storage.objectViewer`.
4. For `byoc`: Create an Artifact Registry Docker repository and push the image.
