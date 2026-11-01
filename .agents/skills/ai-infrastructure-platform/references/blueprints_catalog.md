# Blueprint Catalog Reference (Version 1.0)

A Blueprint represents an enterprise AI solution rather than raw infrastructure code. Users select Blueprints via conversational AI or guided wizard; the platform resolves the blueprint to a tested, pre-approved Terraform template.

---

## Standard Public Blueprints (Azure)

| Blueprint ID | Name | Target Workload | Services Included | Terraform Template | Default Model |
|---|---|---|---|---|---|
| **BP-01** | Minimal AI Workspace | Hackathons, experimentation, prototyping | Microsoft Foundry, Azure OpenAI, AI Agents | `azure-standard-public-minimal-ai-workspace.tf` | GPT-4o-mini |
| **BP-02** | RAG Starter | Entry-level RAG applications | Microsoft Foundry, Azure OpenAI, AI Agents, Azure AI Search, Azure Storage, Azure Key Vault | `azure-standard-public-rag-starter.tf` | GPT-4o-mini |
| **BP-03** | Enterprise RAG | Production-grade RAG with chat history persistence | Microsoft Foundry, Azure OpenAI, AI Agents, Azure AI Search, Azure Storage, Azure Key Vault, Azure Cosmos DB | `azure-standard-public-enterprise-rag.tf` | GPT-4o-mini |
| **BP-04** | Enterprise APIs | Governed AI services exposed to internal/external clients | BP-02 + Azure API Management (APIM) with rate limiting and policy enforcement | `azure-standard-public-enterprise-apis.tf` | GPT-4o-mini |
| **BP-05** | Internet-Grounded Agents | AI agents requiring real-time web knowledge | BP-01 + Bing Grounding integration | `azure-standard-public-internet-grounded-agents.tf` | GPT-4o-mini |
| **BP-06** | Multimodal AI Platform | Voice assistants, speech-to-text, translation, NLP | BP-01 + Azure AI Speech, Azure AI Language | `azure-standard-public-multimodal-ai-platform.tf` | GPT-4o-mini |
| **BP-07** | Enterprise AI Platform (Governed) | Enterprise-wide multi-tenant AI platform with full observability | BP-03 + Log Analytics, Application Insights, Azure Monitor, Diagnostic Settings | `azure-standard-public-enterprise-platform.tf` | GPT-4o-mini |

---

## Standard Private Blueprints (Azure)

The private catalog mirrors the public catalog while enabling enterprise-grade network security and compliance:
- Dedicated Azure Virtual Network (VNet) with isolated subnets
- Network Security Groups (NSGs) with default-deny inbound rules
- Azure Private Endpoints & Azure Private Link for all PaaS services (Foundry, OpenAI, Search, Storage, Key Vault, Cosmos DB)
- Public network access strictly disabled (`publicNetworkAccess = "Disabled"`)
- Azure Bastion (optional) for jump-host management
- User-Assigned Managed Identity for passwordless Azure service authentication

| Blueprint ID | Name | Base Public Service Equivalency | Terraform Template |
|---|---|---|---|
| **BP-08** | Minimal AI Workspace (Private) | BP-01 + Private Networking | `azure-standard-private-minimal-ai-workspace.tf` |
| **BP-09** | RAG Starter (Private) | BP-02 + Private Networking | `azure-standard-private-rag-starter.tf` |
| **BP-10** | Enterprise RAG (Private) | BP-03 + Private Networking | `azure-standard-private-enterprise-rag.tf` |
| **BP-11** | Enterprise APIs (Private) | BP-04 + Private Networking | `azure-standard-private-enterprise-apis.tf` |
| **BP-12** | Internet-Grounded Agents (Private) | BP-05 + Private Networking | `azure-standard-private-internet-grounded-agents.tf` |
| **BP-13** | Multimodal AI Platform (Private) | BP-06 + Private Networking | `azure-standard-private-multimodal-ai-platform.tf` |
| **BP-14** | Enterprise AI Platform (Private) | BP-07 + Private Networking | `azure-standard-private-enterprise-platform.tf` |

---

## Blueprint Implementation & Extension Pattern

- `azure-standard-private-enterprise-rag.tf` serves as the primary implementation blueprint covering Foundry, OpenAI, AI Search, Storage, Key Vault, and Cosmos DB.
- Higher-tier blueprints (APIM, Bing Grounding, Speech/Language, Observability) extend this base template by enabling modular blocks via Terraform composition.
- In future roadmap phases (AWS and GCP), the same Blueprint IDs (e.g., BP-03 "Enterprise RAG") will map to `aws-standard-private-enterprise-rag.tf` (Amazon Bedrock, OpenSearch, S3, DynamoDB) and `gcp-standard-private-enterprise-rag.tf` (Vertex AI, Vertex Search, Cloud Storage, Cloud Firestore) without changing user workflows or frontend screens.
