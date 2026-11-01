---
name: ai-infrastructure-platform
description: >-
  Use this skill when designing, building, configuring, or deploying the enterprise AI Infrastructure Platform (AIP).
  Covers the overall solution architecture (HLD), the Blueprint Catalog (BP-01 to BP-14 for public and private Azure environments),
  the Python FastAPI backend services, the PipelineProvider CI/CD abstraction for GitHub Actions and Azure DevOps, the React 19/Next.js/Fluent UI frontend,
  and the modular Terraform infrastructure layer for Microsoft Foundry, Azure OpenAI, AI Search, and supporting Azure services.
---

# AI Infrastructure Platform (AIP) Skill

This skill guides engineers and autonomous agents through architecting, implementing, operating, and extending the enterprise **AI Infrastructure Platform (AIP)** as specified in the Overall Solution Design Document (HLD v1.0).

---

## 1. Core Principles & Philosophy

When developing or operating AIP, adhere strictly to these fundamental tenets:

1. **Users Deploy Blueprints, Never Terraform**:
   - AIP presents a self-service catalog of business solutions (e.g., "Enterprise RAG", "Minimal AI Workspace", "Internet-Grounded Agents").
   - Users interact via an AI Chat Assistant or a Guided Wizard. They never write or edit raw Terraform.
2. **Pre-Approved, Tested Templates Only**:
   - AIP **does not** generate Terraform code dynamically.
   - All deployments map to version-controlled, validated Terraform templates authored by the Platform Engineering team.
3. **Cloud-Agnostic Abstraction**:
   - Blueprints decouple the user experience from the underlying cloud implementation.
   - BP-03 ("Enterprise RAG") currently maps to Azure (`azure-standard-private-enterprise-rag.tf`), but will map to AWS (Amazon Bedrock) and GCP (Vertex AI) in future phases without altering user-facing interfaces.
4. **Decoupled CI/CD Execution**:
   - The platform never executes Terraform directly.
   - The backend delegates execution to enterprise CI/CD pipelines (GitHub Actions or Azure DevOps) through a unified `PipelineProvider` abstraction.
5. **System of Record**:
   - The Backend Deployment Service owns deployment metadata, parameters, status, and history in PostgreSQL, rather than relying solely on CI/CD runner logs.

---

## 2. Solution Architecture & Tech Stack

```text
End Users (Platform Engineer, Approver, Administrator)
                      |
                      v
React 19 + Next.js + Fluent UI + Tailwind CSS Frontend
  (Dashboard, Chat Assistant, Guided Wizard, Blueprint Catalog, Progress, History, Admin)
                      |  [REST APIs]
                      v
Python FastAPI (Python 3.12+) Backend API Layer
  - Authentication (Entra ID) & RBAC (Role-Based Access Control)
  - Blueprint Catalog Service & Template Catalog Service
  - Model Catalog Service (GPT-4o-mini default)
  - Deployment Service (Orchestration & State)
  - Pipeline Integration Service (PipelineProvider abstraction)
  - Notification Service & Audit Service
                      |
                      v
CI/CD Integration Layer (GitHub Actions / Azure DevOps Pipelines)
  [Validate -> Init -> Validate -> Plan -> (Optional Approval) -> Apply -> Outputs]
                      |
                      v
Terraform Layer (Modules & Blueprint Templates) -> Microsoft Azure Resources
```

### Technology Matrix
- **Frontend**: React 19, Next.js, TypeScript, Fluent UI, Tailwind CSS, React Hook Form, TanStack Query, Zustand, MSAL (`@azure/msal-react`).
- **Backend API**: Python 3.12+, FastAPI, Uvicorn, Pydantic v2, SQLAlchemy 2.0, Alembic, PostgreSQL, Azure SDK for Python.
- **CI/CD Integration**: GitHub REST API (`GitHubActionsProvider`), Azure DevOps REST API (`AzureDevOpsProvider`).
- **Cloud Infrastructure**: Microsoft Azure, Microsoft Foundry, Azure OpenAI, Azure AI Search, Azure Storage, Azure Key Vault, Cosmos DB, API Management, Azure Bastion, Private Endpoints/VNet.
- **Observability**: Azure Monitor, Log Analytics, Application Insights.
- **Secrets Management**: Azure Key Vault, Managed Identities.

---

## 3. Blueprint Catalog Reference

AIP maintains two catalog tiers in Version 1: **Standard Public** (BP-01 to BP-07) and **Standard Private** (BP-08 to BP-14).
*Default Azure OpenAI Model across all blueprints:* `GPT-4o-mini`.

### Standard Public Blueprints (v1)
- **BP-01: Minimal AI Workspace**
  - *Purpose:* Rapid experimentation for AI engineers, data scientists, hackathons.
  - *Services:* Microsoft Foundry, Azure OpenAI, AI Agents.
  - *Template:* `azure-standard-public-minimal-ai-workspace.tf`
- **BP-02: RAG Starter**
  - *Purpose:* Entry-level Retrieval-Augmented Generation.
  - *Services:* BP-01 + Azure AI Search, Azure Storage, Azure Key Vault.
  - *Template:* `azure-standard-public-rag-starter.tf`
- **BP-03: Enterprise RAG**
  - *Purpose:* Production-grade enterprise RAG.
  - *Services:* BP-02 + Azure Cosmos DB.
  - *Template:* `azure-standard-public-enterprise-rag.tf`
- **BP-04: Enterprise APIs**
  - *Purpose:* Governed AI capabilities exposed securely as APIs.
  - *Services:* BP-01/02 + Azure API Management (APIM).
  - *Template:* `azure-standard-public-enterprise-apis.tf`
- **BP-05: Internet-Grounded Agents**
  - *Purpose:* Autonomous agents grounded with live web search.
  - *Services:* BP-01 + Bing Grounding.
  - *Template:* `azure-standard-public-internet-grounded-agents.tf`
- **BP-06: Multimodal AI Platform**
  - *Purpose:* Voice and language-enabled platform.
  - *Services:* BP-01 + Azure AI Speech, Azure AI Language.
  - *Template:* `azure-standard-public-multimodal-ai-platform.tf`
- **BP-07: Enterprise AI Platform (Governed)**
  - *Purpose:* Full observability on top of the enterprise platform.
  - *Services:* BP-03 + Log Analytics workspace, Application Insights, Azure Monitor, Diagnostic Settings.
  - *Template:* `azure-standard-public-enterprise-platform.tf`

### Standard Private Blueprints (v1)
Every Private Blueprint mirrors its public counterpart while enforcing enterprise network isolation:
- Virtual Network (VNet) & dedicated subnets
- Network Security Groups (NSGs)
- Private Endpoints and Azure Private Link
- Public network access disabled (`publicNetworkAccess = "Disabled"`)
- User-Assigned Managed Identity
- Optional Azure Bastion

- **BP-08:** Minimal AI Workspace (Private) -> `azure-standard-private-minimal-ai-workspace.tf`
- **BP-09:** RAG Starter (Private) -> `azure-standard-private-rag-starter.tf`
- **BP-10:** Enterprise RAG (Private) -> `azure-standard-private-enterprise-rag.tf`
- **BP-11:** Enterprise APIs (Private) -> `azure-standard-private-enterprise-apis.tf`
- **BP-12:** Internet-Grounded Agents (Private) -> `azure-standard-private-internet-grounded-agents.tf`
- **BP-13:** Multimodal AI Platform (Private) -> `azure-standard-private-multimodal-ai-platform.tf`
- **BP-14:** Enterprise AI Platform (Private) -> `azure-standard-private-enterprise-platform.tf`

---

## 4. Backend Implementation Guidelines

### 4.1 CI/CD Provider Abstraction
All CI/CD pipeline triggers and status checks must go through the `PipelineProvider` abstract interface. Do not allow controllers or services to couple directly to GitHub or Azure DevOps APIs.

See reference implementation in:
[pipeline_provider_interface.py](./examples/pipeline_provider_interface.py)

```python
from abc import ABC, abstractmethod
from pydantic import BaseModel

class PipelineProvider(ABC):
    @abstractmethod
    async def trigger_deployment(self, request: DeploymentRequest) -> PipelineRun:
        pass

    @abstractmethod
    async def get_status(self, run_id: str) -> PipelineStatus:
        pass

    @abstractmethod
    async def get_logs(self, run_id: str) -> str:
        pass

    @abstractmethod
    async def cancel_deployment(self, run_id: str) -> bool:
        pass
```

### 4.2 Standard Pipeline Lifecycle
Enterprise pipelines must strictly execute in the following stages:
1. `Validate Request`: Validate parameters, schema, naming conventions, and quotas.
2. `Terraform Init`: Initialize backend storage state.
3. `Terraform Validate`: Validate template syntax and resource definitions.
4. `Terraform Plan`: Generate execution plan.
5. `Approval (Optional)`: Required for production or high-cost tiers.
6. `Terraform Apply`: Provision resources into Azure.
7. `Collect Outputs`: Retrieve endpoints, connection strings (via Key Vault references), and resource IDs.
8. `Notify Portal`: Webhook/polling callback updating the AIP Deployment Service.

### 4.3 Error Handling & Diagnostics
The platform must transform cryptic Terraform or cloud errors into actionable messages for the end user:
```json
{
  "status": "failed",
  "stage": "Terraform Apply",
  "step": "Azure AI Search",
  "reason": "Quota unavailable for SKU standard in eastus",
  "suggested_action": "Select an alternate region (e.g., eastus2) or request a quota increase via Azure Support.",
  "pipeline_run_id": "gh-run-8492041",
  "raw_logs_url": "/api/v1/deployments/dep-1024/logs"
}
```

---

## 5. User Roles and RBAC Matrix

| Role | Permissions | Restrictions |
|---|---|---|
| **Platform Engineer** | Create deployments, view own/team deployments, retry failed deployments, retrieve outputs | Cannot register templates, configure CI/CD, or manage users |
| **Approver** | Review pending deployments, approve/reject deployments, view deployment audit history | Cannot initiate deployments or register templates |
| **Administrator** | Register/deprecate Terraform templates, configure CI/CD integrations, enable/disable models, manage users and roles, configure cloud connections | Full administrative control |

---

## 6. Repository Layout Standards

When developing the AIP codebase, adhere to this repository structure:

```text
ai-infrastructure-platform/
├── docs/                      # Solution design, UX requirements, specifications
│   └── overall_design.md      # High-Level Design document (HLD v1.0)
├── frontend/                  # Next.js 15+ / React 19 portal
│   ├── src/
│   │   ├── app/               # App router (dashboard, deploy, blueprints, admin)
│   │   ├── components/        # Fluent UI & Tailwind components
│   │   ├── hooks/             # TanStack Query & MSAL hooks
│   │   └── store/             # Zustand state management
├── backend/                   # Python FastAPI service
│   ├── app/
│   │   ├── api/v1/            # API routers (deployments, blueprints, templates, models, audit)
│   │   ├── core/              # Config, security, Entra ID JWT verification
│   │   ├── db/                # SQLAlchemy models, Alembic migrations, PostgreSQL session
│   │   ├── providers/         # PipelineProvider, GitHubActionsProvider, AzureDevOpsProvider
│   │   └── services/          # BlueprintCatalog, Deployment, ModelCatalog, Notification, Audit
├── terraform/
│   ├── modules/               # Reusable Azure modules (foundry, openai, search, storage, etc.)
│   ├── templates/             # Approved root templates (azure/public/*, azure/private/*)
│   └── upstream/              # Reference Microsoft templates (non-shipped reference code)
└── .agents/skills/            # Project skills and agent runbooks
```

---

## 7. Supporting References and Examples

- [Overall Solution Design Document](./references/overall_design.md): Full verbatim transcribed HLD document.
- [Blueprints Catalog Deep Dive](./references/blueprints_catalog.md): Complete specifications for BP-01 through BP-14.
- [Pipeline Provider Reference](./examples/pipeline_provider_interface.py): Python source code for CI/CD abstraction.
- [Blueprint Schema](./examples/blueprint_schema.json): Pydantic / JSON schema for Blueprints.
