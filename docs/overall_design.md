# AI Infrastructure Platform (AIP)
## Overall Solution Design Document

**Version:** 1.0  
**Status:** Draft  
**Document Type:** Solution Architecture / High-Level Design (HLD)

---

## Table of Contents 
1. Executive Summary
2. Objectives
3. High-Level Architecture
4. Solution Components
5. Blueprint Catalog
6. Template Catalog
7. Model Catalog
8. User Roles
9. Frontend Screens
10. Deployment Workflow
11. Backend Database
12. Error Handling
13. Security Architecture
14. Extensibility
15. Version 1 Scope
16. Future Roadmap
17. Repository Structure
18. Success Metrics

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

### 4.1 Frontend Layer

**Technology Stack:**
- **Framework:** React 19
- **Meta-Framework:** Next.js
- **Language:** TypeScript
- **UI Framework:** Fluent UI
- **Styling:** Tailwind CSS
- **Forms:** React Hook Form
- **State Management:** TanStack Query + Zustand
- **Authentication:** Microsoft Entra ID (MSAL)

**Responsibilities:**
- User authentication
- Dashboard
- Chat Assistant
- Guided Wizard
- Blueprint Catalog
- Deployment Progress
- Deployment History
- Administration
- Notifications

### 4.2 Backend API Layer

**Technology Stack:**
- **Framework:** Python FastAPI
- **Language:** Python 3.12+
- **ASGI Server:** Uvicorn
- **Validation:** Pydantic
- **ORM:** SQLAlchemy
- **Database Migration:** Alembic
- **Database:** PostgreSQL
- **Authentication:** Microsoft Entra ID
- **Azure SDK:** Azure SDK for Python
- **GitHub Integration:** GitHub REST API
- **Azure DevOps Integration:** Azure DevOps REST API

**Why FastAPI?**
- High performance, native asynchronous programming
- Automatic OpenAPI documentation
- Strong typing via Pydantic
- Seamless Azure SDK integration
- Excellent Python ecosystem
- Native support for agent / LLM frameworks
- Future compatibility with MCP servers and agent frameworks

**Core Services:**
- **Authentication Service:** Microsoft Entra ID authentication, JWT validation, token lifecycle management, service-to-service auth.
- **Authorization Service:** Role validation, permission checks, scope enforcement, RBAC enforcement (Platform Engineer, Approver, Administrator).
- **Blueprint Catalog Service:** Maintain the Blueprint catalog, resolve blueprints (used by AI Assistant), retrieve blueprint metadata, validate blueprint parameters, expose blueprint versions.
- **Template Catalog Service:** Map Blueprint -> Terraform Template, retrieve template metadata, validate template availability, expose template versions, maintain template parameters.
- **Model Catalog Service:** Maintain supported Azure OpenAI models, expose model metadata, configure the default model (GPT-4o-mini), enable/disable models.
- **Deployment Service:** Validate deployment requests, generate deployment parameters, persist deployment state, orchestrate CI/CD execution, track deployment progress, store outputs. Owns the system of record for deployment history.
- **Pipeline Integration Service:** Trigger GitHub Actions or Azure DevOps Pipelines, poll pipeline status, retrieve pipeline logs, cancel pipeline runs, retrieve Terraform outputs. Built behind a single provider interface (`PipelineProvider`).
- **Notification Service:** Deployment started, completed, failed, approval required.
- **Audit Service:** Deployment history, user activity, administrative changes, configuration drift events.

### 4.3 CI/CD Integration Layer

The platform never executes Terraform directly. Instead, it triggers enterprise-approved CI/CD pipelines.

**Supported Platforms:**
- GitHub Actions
- Azure DevOps Pipelines

**Responsibilities:**
- Receive deployment request
- Execute the Terraform workflow
- Capture deployment logs
- Publish deployment outputs
- Return Terraform outputs

**Standard Pipeline Stages:**
```text
Validate Request -> Terraform Init -> Terraform Validate -> Terraform Plan -> Approval (Optional) -> Terraform Apply -> Collect Outputs -> Notify Portal
```
The portal receives deployment updates by polling the pipeline APIs.

**Pipeline Provider Abstraction:**
Rather than letting the UI or backend call GitHub Actions or Azure DevOps APIs directly, the Pipeline Integration Service is built behind a single provider interface:
```python
class PipelineProvider(ABC):
    @abstractmethod
    async def trigger_deployment(self, request: DeploymentRequest) -> PipelineRun: ...
    
    @abstractmethod
    async def get_status(self, run_id: str) -> PipelineStatus: ...
    
    @abstractmethod
    async def get_logs(self, run_id: str) -> str: ...
    
    @abstractmethod
    async def cancel_deployment(self, run_id: str) -> bool: ...
```
Implemented by `GitHubActionsProvider` and `AzureDevOpsProvider`. Adding support for another CI/CD system in the future means implementing this interface once.

### 4.4 Terraform Infrastructure Layer

The Terraform layer contains all Infrastructure-as-Code assets maintained by the Platform Engineering team. End users never interact with Terraform directly.

**Responsibilities:**
- Maintain reusable modules
- Maintain approved deployment templates
- Provide Azure reference implementations
- Publish outputs to CI/CD pipelines
- Enforce infrastructure standards

**Repository Structure:**
```text
terraform/
  modules/
    foundry/
    openai/
    search/
    agents/ (Future)
    storage/
    keyvault/
    cosmosdb/
    apim/
    network/
    speech/
    language/
    monitoring/
  templates/
    azure/
      public/
      private/
      poc/ (Future)
      prod/ (Future)
  examples/
```

**Deployment Flow:**
```text
User -> Blueprint -> Approved Terraform Template -> Terraform Modules -> Azure Resources
```

---

## 5. Blueprint Catalog

### Blueprint Philosophy
A Blueprint represents an enterprise AI solution, not a piece of infrastructure code. Users never deploy Terraform directly — users deploy Blueprints. Each Blueprint is mapped to exactly one approved Terraform template.

This abstraction is the platform's most important abstraction:
- Blueprint names and descriptions can be updated without changing the user experience.
- The same Blueprint (e.g. "Enterprise RAG") can map to different cloud-specific implementations on Azure, AWS, and GCP once those clouds are supported.
- Templates can be versioned and swapped under the hood without changing the Blueprint identity.
- The UI stays cloud-agnostic even as the underlying infrastructure evolves.

### Blueprint Structure
Each Blueprint contains:
- **Blueprint ID:** Unique identifier (e.g. BP-01)
- **Blueprint Name:** Display name shown to users
- **Description:** What the blueprint is for
- **Cloud:** Target cloud provider (e.g. Microsoft Azure)
- **AI Platform:** Target AI platform (e.g. Microsoft Foundry)
- **Target Workload:** e.g. RAG, Chatbot, Agent
- **Deployment Type:** Standard Public / Standard Private
- **Included Azure Services:** Services provisioned by the mapped template
- **Default Azure OpenAI Model:** Pre-selected model (user may override from the Model Catalog)
- **Terraform Template:** The approved Terraform template this Blueprint resolves to
- **Version:** Template / version
- **Status:** Active / Deprecated

### Blueprint Mapping Layer Examples
- **Enterprise RAG** -> `azure-standard-private-enterprise-rag.tf` -> Foundry, OpenAI, Agents, Search, Storage, Key Vault, Cosmos DB
- **Voice Assistant** -> `azure-standard-public-voice-assistant.tf` -> Foundry, OpenAI, Speech
- **AI Agent Workspace** -> `azure-standard-public-agent-workspace.tf` -> Foundry, OpenAI, Agents

### Azure Blueprints - Standard Public (Version 1)

| ID | Blueprint | Purpose | Services Included | Terraform Template |
|---|---|---|---|---|
| **BP-01** | Minimal AI Workspace | Rapid experimentation for AI engineers, data scientists, hackathons | Microsoft Foundry, Azure OpenAI, AI Agents | `azure-standard-public-minimal-ai-workspace.tf` |
| **BP-02** | RAG Starter | Entry-level Retrieval-Augmented Generation | + Azure AI Search, Azure Storage, Azure Key Vault | `azure-standard-public-rag-starter.tf` |
| **BP-03** | Enterprise RAG | Production-grade RAG | + Cosmos DB | `azure-standard-public-enterprise-rag.tf` |
| **BP-04** | Enterprise APIs | Governed AI capabilities exposed as APIs | + API Management | `azure-standard-public-enterprise-apis.tf` |
| **BP-05** | Internet-Grounded Agents | Agents grounded with live web search | + Bing Grounding | `azure-standard-public-internet-grounded-agents.tf` |
| **BP-06** | Multimodal AI Platform | Voice and language enabled platform | + Azure Speech, Azure Language | `azure-standard-public-multimodal-ai-platform.tf` |
| **BP-07** | Enterprise AI Platform (Governed) | Full observability on top of the enterprise platform | + Log Analytics, Application Insights, Azure Monitor, Diagnostic Settings | `azure-standard-public-enterprise-platform.tf` |

*Default model for all Standard Public Blueprints: GPT-4o-mini*

### Azure Blueprints - Standard Private (Version 1)

The private catalog mirrors the public catalog while enabling secure enterprise networking. Every private Blueprint additionally provides:
- Virtual Network (VNet)
- Network Security Groups (NSG)
- Private Endpoints and Private Link
- Azure Bastion (Optional)
- Public network access disabled
- User-Assigned Managed Identity

| ID | Blueprint | Same Services As | Terraform Template |
|---|---|---|---|
| **BP-08** | Minimal AI Workspace (Private) | BP-01 | `azure-standard-private-minimal-ai-workspace.tf` |
| **BP-09** | RAG Starter (Private) | BP-02 | `azure-standard-private-rag-starter.tf` |
| **BP-10** | Enterprise RAG (Private) | BP-03 | `azure-standard-private-enterprise-rag.tf` |
| **BP-11** | Enterprise APIs (Private) | BP-04 | `azure-standard-private-enterprise-apis.tf` |
| **BP-12** | Internet-Grounded Agents (Private) | BP-05 | `azure-standard-private-internet-grounded-agents.tf` |
| **BP-13** | Multimodal AI Platform (Private) | BP-06 | `azure-standard-private-multimodal-ai-platform.tf` |
| **BP-14** | Enterprise AI Platform (Private) | BP-07 | `azure-standard-private-enterprise-platform.tf` |

*Implementation note:* `azure-standard-private-enterprise-rag.tf` currently implements the BP-01/BP-02/BP-03 (public) and BP-08/BP-09/BP-10 (private) resource set: Foundry, OpenAI, AI Agents, AI Search, Storage, and Cosmos DB. The remaining Blueprints extend that same template using module-composition.

---

## 6. Template Catalog

Administrators register approved Terraform templates. Users can inspect a template's metadata but cannot edit it.

**Template Metadata:**
- Name
- Description
- Version
- Cloud
- AI Platform
- Path
- Inputs
- Outputs
- Status

---

## 7. Model Catalog

Administrators maintain the list of supported Azure OpenAI models. Users may only select from approved, enabled models.

**Supported Models:**
- `GPT-4o-mini` (Default)
- `GPT-4o`
- `GPT-4o nano`
- `text-embedding-3`

---

## 8. User Roles

- **Platform Engineer:** Can create deployments, view deployments, retry failed deployments, view outputs. Cannot: register templates, manage users.
- **Approver:** Can approve deployments, reject deployments, view deployment history. Cannot: create deployments, manage users.
- **Administrator:** Can: register templates, configure CI/CD, configure supported models, manage users, configure cloud connections.

---

## 9. Frontend Screens

The full screen-by-screen UX specification lives in `02_design.md` and `01_requirements.md`. Major screens:
- **Dashboard**
- **Deploy AI Environment** (AI Assistant / Guided Wizard)
- **Blueprint Catalog**
- **Deployment Progress**
- **Deployment History**
- **Administration**
- **Notifications**

---

## 10. Deployment Workflow

```text
User -> Authentication -> Dashboard -> Deploy AI Environment (Chat or Wizard) 
     -> Blueprint Selected + Template Selected 
     -> Configuration -> Validation -> Review & Deploy 
     -> Backend API -> CI/CD Pipeline -> Terraform -> Azure 
     -> Outputs -> Portal
```

---

## 11. Backend Database

**Suggested Entities:**
- Users
- Roles
- Blueprints
- Templates
- Deployments
- Deployment Parameters
- Deployment Outputs
- Models
- Pipeline Configuration
- Audit Logs

---

## 12. Error Handling

The platform presents user-friendly deployment failures while preserving access to raw pipeline logs.

*Example:*
```text
Deployment Failed
Stage: Terraform Apply
Step: Azure AI Search
Reason: Quota unavailable
Suggested Action: Deploy to another region.
```

---

## 13. Security Architecture

| Concern | Approach |
|---|---|
| Authentication | Microsoft Entra ID |
| Authorization | RBAC (Role-Based Access Control) |
| Transport | HTTPS only |
| Secrets | Azure Key Vault |
| Audit | Deployment history + audit logging |
| Least Privilege | Managed Identity |

---

## 14. Extensibility

The architecture is designed to support multiple cloud providers over time:
```text
Azure -> AWS -> Google Cloud
```
The user experience remains unchanged while the backend resolves cloud-specific templates for the selected Blueprint.

---

## 15. Version 1 Scope

**Included:**
- Azure support
- Microsoft Foundry
- React frontend
- Python FastAPI backend
- Blueprint catalog
- Template catalog
- Model catalog
- CI/CD integration
- GitHub Actions integration
- Azure DevOps integration
- Deployment monitoring
- RBAC

**Excluded:**
- Terraform generation
- Visual architecture designer
- Cost visibility dashboards
- AWS deployment
- GCP deployment
- Day 2 operations
- Drift detection
- Governance dashboards

---

## 16. Future Roadmap

- **Phase 2:** AWS support (Amazon Bedrock, AWS AgentCore)
- **Phase 3:** Google Cloud Platform (Vertex AI, Agent Development Kit)
- **Phase 4:** Day 2 operations (Cost visibility, Policy validation, Drift detection, Deployment cloning, Enterprise governance)

---

## 17. Repository Structure

```text
gemini-steel-framework/ (or tiger-ai-infra/)
├── docs/                      # Product, SI, and UX specifications (01_requirements.md, 02_design.md, xx_design.md)
├── frontend/                  # Frontend portal (React 19 + Next.js + TypeScript)
├── backend/                   # Backend API (Python FastAPI)
├── terraform/
│   ├── modules/               # Reusable modules
│   ├── templates/             # Blueprint root templates
│   └── upstream/              # Upstream Microsoft reference Terraform templates (source material, not shipped)
```

---

## 18. Success Metrics

The platform will be considered successful when it:
- Reduces AI infrastructure provisioning from days to minutes.
- Eliminates direct Terraform interaction for most users.
- Standardizes all deployments on pre-approved, version-controlled templates.
- Provides end-to-end deployment visibility and troubleshooting.
- Supports enterprise RBAC and governance.
- Establishes a reusable architecture that can be extended to AWS and GCP without redesigning the user experience.
