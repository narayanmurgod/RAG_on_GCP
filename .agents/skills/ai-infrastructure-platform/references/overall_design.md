# AI Infrastructure Platform (AIP)
## Overall Solution Design Document (HLD v1.0)

**Version:** 1.0  
**Status:** Draft  
**Document Type:** Solution Architecture / High-Level Design (HLD)

---

## 1. Executive Summary

The AI Infrastructure Platform (AIP) is an enterprise self-service platform that enables developers, AI engineers, and platform teams to provision standardized AI infrastructure using approved Infrastructure-as-Code templates.

Rather than provide Terraform directly, AIP presents users with a guided deployment experience. Users either describe what they want to build through a conversational assistant or use a guided wizard. Based on this selection blueprint, the platform maps the request to a pre-approved Terraform template, populates deployment parameters, and triggers an automated CI/CD pipeline.

AIP does not generate Terraform code. All infrastructure is provisioned using version-controlled, tested Terraform templates published by the Platform Engineering team.

Version 1 targets Microsoft Azure and Microsoft Foundry, while the architecture is designed to support AWS and Google Cloud Platform in future releases without redesign.

---

## 2. Objectives

The platform aims to:
- Enable self-service AI infrastructure provisioning.
- Eliminate the need for Terraform knowledge.
- Enforce enterprise standards and guardrails.
- Ensure only approved templates are deployed.
- Provide a governed deployment process.
- Integrate with enterprise CI/CD pipelines.
- Provide deployment visibility and troubleshooting.
- Establish a cloud-agnostic architecture for future AWS and GCP support.

---

## 3. High-Level Architecture

```text
                             +-----------------------------------+
                             |             End Users             |
                             | - Platform Engineer               |
                             | - Approver                        |
                             | - Administrator                   |
                             +-----------------+-----------------+
                                               |
                                               v
                             +-----------------------------------+
                             |     React / Next.js Frontend      |
                             | Dashboard | Deploy AI Environment |
                             | Chat Assistant | Guided Wizard    |
                             | Blueprint Catalog                 |
                             | Deployment Progress | History     |
                             | Administration | Notifications    |
                             +-----------------+-----------------+
                                               | (REST APIs)
                                               v
                             +-----------------------------------+
                             |       Python FastAPI Backend      |
                             | Authentication (Entra ID)         |
                             | Authorization / RBAC              |
                             | Blueprint Catalog Service         |
                             | Template Catalog Service          |
                             | Model Catalog Service             |
                             | Deployment Service (Orchestrator) |
                             | Pipeline Integration Service      |
                             | Notification Service | Audit Svc  |
                             +-----------------+-----------------+
                                               |
                                               v
                             +-----------------------------------+
                             |     CI/CD Integration Layer       |
                             | GitHub Actions | Azure DevOps     |
                             +-----------------+-----------------+
                                               |
                                               v
                             +-----------------------------------+
                             |    Terraform Deployment Layer     |
                             | Blueprint -> Terraform Template   |
                             |           -> Terraform Modules    |
                             |           -> Azure Resources      |
                             +-----------------+-----------------+
                                               |
                                               v
                             +-----------------------------------+
                             |          Microsoft Azure          |
                             | Microsoft Foundry | Azure OpenAI  |
                             | Azure AI Search   | Azure Storage |
                             | Azure Key Vault   | Cosmos DB     |
                             | API Management    | VNet / Private|
                             | AI Speech/Lang    | Azure Monitor |
                             +-----------------------------------+
```

---

## 4. Solution Components

The AI Infrastructure Platform (AIP) is composed of four primary layers:
1. **Frontend Layer:** Provides the user interface and user experience.
2. **Backend API Layer:** Orchestration engine for the platform: validates user requests, resolves Blueprints into approved Terraform templates, triggers CI/CD pipelines, tracks deployment status, and returns deployment outputs.
3. **CI/CD & Deployment Layer:** Executes approved Terraform templates using enterprise-approved CI/CD pipelines.
4. **Terraform Infrastructure Layer:** Contains reusable Terraform modules and deployment templates.

### Tech Stack Summary

| Layer | Technology |
|---|---|
| Frontend | React 19 + Next.js + TypeScript |
| UI Components | Fluent UI |
| Styling | Tailwind CSS |
| Backend API | Python FastAPI (Python 3.12+) |
| Validation | Pydantic |
| ORM | SQLAlchemy |
| Database Migration | Alembic |
| Database | PostgreSQL |
| Authentication | Microsoft Entra ID (MSAL) |
| CI/CD | GitHub Actions / Azure DevOps Pipelines |
| IaC | Terraform |
| Cloud | Microsoft Azure |
| AI Platform | Microsoft Foundry |
| Default LLM | GPT-4o-mini |
| Monitoring | Azure Monitor (Log Analytics, App Insights) |
| Secrets | Azure Key Vault |

---

## 5. Blueprint Catalog

### Blueprint Philosophy
A Blueprint represents an enterprise AI solution, not a piece of infrastructure code. Users never deploy Terraform directly — users deploy Blueprints. Each Blueprint is mapped to exactly one approved Terraform template.

### Azure Blueprints - Standard Public (Version 1)
- **BP-01: Minimal AI Workspace**: Microsoft Foundry, Azure OpenAI, AI Agents (`azure-standard-public-minimal-ai-workspace.tf`)
- **BP-02: RAG Starter**: + Azure AI Search, Azure Storage, Azure Key Vault (`azure-standard-public-rag-starter.tf`)
- **BP-03: Enterprise RAG**: + Cosmos DB (`azure-standard-public-enterprise-rag.tf`)
- **BP-04: Enterprise APIs**: + API Management (`azure-standard-public-enterprise-apis.tf`)
- **BP-05: Internet-Grounded Agents**: + Bing Grounding (`azure-standard-public-internet-grounded-agents.tf`)
- **BP-06: Multimodal AI Platform**: + Azure Speech, Azure Language (`azure-standard-public-multimodal-ai-platform.tf`)
- **BP-07: Enterprise AI Platform (Governed)**: + Log Analytics, Application Insights, Azure Monitor (`azure-standard-public-enterprise-platform.tf`)

### Azure Blueprints - Standard Private (Version 1)
- **BP-08:** Minimal AI Workspace (Private) (`azure-standard-private-minimal-ai-workspace.tf`)
- **BP-09:** RAG Starter (Private) (`azure-standard-private-rag-starter.tf`)
- **BP-10:** Enterprise RAG (Private) (`azure-standard-private-enterprise-rag.tf`)
- **BP-11:** Enterprise APIs (Private) (`azure-standard-private-enterprise-apis.tf`)
- **BP-12:** Internet-Grounded Agents (Private) (`azure-standard-private-internet-grounded-agents.tf`)
- **BP-13:** Multimodal AI Platform (Private) (`azure-standard-private-multimodal-ai-platform.tf`)
- **BP-14:** Enterprise AI Platform (Private) (`azure-standard-private-enterprise-platform.tf`)

---

## 6. Template & Model Catalogs

- **Template Catalog:** Managed by Administrators. Maps Blueprints to Terraform root templates.
- **Model Catalog:** Administrators maintain supported models. Users select from approved models:
  - `GPT-4o-mini` (Default)
  - `GPT-4o`
  - `GPT-4o nano`
  - `text-embedding-3`

---

## 7. User Roles

- **Platform Engineer:** Create deployments, view deployments, retry failed deployments, view outputs.
- **Approver:** Approve/reject deployments, view deployment history.
- **Administrator:** Register templates, configure CI/CD, configure supported models, manage users, cloud connections.

---

## 8. Deployment Workflow & CI/CD

```text
User -> Auth -> Dashboard -> Deploy AI Environment -> Blueprint Selection -> Parameter Input -> Validation -> Review & Deploy -> Backend API -> PipelineProvider (GitHub Actions / ADO) -> Terraform (Init -> Validate -> Plan -> Apply -> Outputs) -> Azure Provisioning -> Portal Notification
```

---

## 9. Error Handling & Security

- **Error Translation:** Translate Terraform errors into friendly, actionable diagnostic cards with stage, failing resource, cause, and remediation suggestion.
- **Security:** Microsoft Entra ID authentication, RBAC, HTTPS only, Azure Key Vault for all sensitive secrets, Managed Identity for Azure resource-to-resource authentication.

---

## 10. Roadmap

- **Phase 1 (v1.0):** Azure + Foundry, React + Next.js, FastAPI, GitHub/ADO, 14 Blueprints.
- **Phase 2:** AWS Support (Amazon Bedrock, AWS AgentCore).
- **Phase 3:** Google Cloud Platform Support (Vertex AI, Agent Development Kit).
- **Phase 4:** Day 2 Operations (Cost visibility, Policy validation, Drift detection, Deployment cloning, Enterprise governance).
