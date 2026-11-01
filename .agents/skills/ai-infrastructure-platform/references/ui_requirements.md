# AI Infrastructure Self-Service Portal
## User Interface Requirements (Version 1.0)

---

## 1. Overview

### Purpose
The AI Infrastructure Self-Service Portal provides a centralized, enterprise-grade interface for provisioning Microsoft Foundry environments using standardized Terraform templates.

The primary objective is to simplify AI infrastructure deployment while ensuring that only approved, tested Terraform templates are used. The portal does not generate Terraform code. Instead, it maps user selections to pre-built Terraform templates maintained by the Platform Engineering team.

**This approach ensures:**
- Self-service
- Governance
- Predictable deployments
- Reduced deployment failures
- Faster maintenance
- Enterprise security

Although Version 1 focuses on Microsoft Azure and Microsoft Foundry, the platform is intentionally designed to support additional cloud providers (AWS and Google Cloud Platform) in future releases.

---

## 2. Product Vision

Provide a single enterprise portal where developers, AI engineers, and platform teams can provision AI infrastructure without requiring Terraform expertise.

**The portal should provide:**
- Guided infrastructure selection
- AI-assisted template recommendation
- CI/CD pipeline integration
- Deployment monitoring
- Audit logging
- Secure role-based access

---

## 3. Product Principles

The UI shall follow these principles:
- **No Terraform knowledge required**
- **No infrastructure code generation**
- **Only approved templates may be deployed**
- **Governed deployments**
- **Enterprise ready**
- **Designed for multiple cloud providers**
- **Cloud-agnostic architecture**
- **Clean modern user experience**
- **Minimal clicks**

---

## 4. Supported Cloud Providers

### Version 1
- **Supported:** Microsoft Azure
- **Supported AI Platform:** Microsoft Foundry

### Future Releases
- **Supported Clouds:** Amazon Web Services (AWS), Google Cloud Platform (GCP)
- **Future AI Platforms:** Amazon Bedrock, AWS AgentCore, Google Gemini Enterprise Agent Platform, Google Agent Development Kit

*The UI architecture must not contain Azure-specific assumptions.*

---

## 5. Supported Deployment Model

The portal provisions infrastructure using predefined Terraform templates.

**The portal shall NOT:**
- Generate Terraform
- Modify Terraform code
- Create infrastructure dynamically

**The portal shall:**
- Select an existing Terraform template
- Populate template variables
- Trigger CI/CD pipeline
- Monitor deployment
- Display deployment outputs

---

## 6. High-Level Architecture

```text
                        +---------------------------------------+
                        |       AI Infrastructure Portal        |
                        |      User Interface (React / Next.js) |
                        +-------------------+-------------------+
                                            |
                                            v
                        +---------------------------------------+
                        |     Template Recommendation Layer     |
                        +-------------------+-------------------+
                                            |
                                            v
                        +---------------------------------------+
                        |     Template Configuration Engine     |
                        +-------------------+-------------------+
                                            |
                                            v
                        +---------------------------------------+
                        |     Terraform Variable Generator      |
                        +-------------------+-------------------+
                                            |
                                            v
                        +---------------------------------------+
                        |  GitHub Actions / Azure DevOps Pipeline|
                        +-------------------+-------------------+
                                            |
                                            v
                        +---------------------------------------+
                        |      Approved Terraform Templates     |
                        +-------------------+-------------------+
                                            |
                                            v
                        +---------------------------------------+
                        |            Microsoft Azure            |
                        +---------------------------------------+
```

---

## 7. User Roles

The application shall support Role-Based Access Control (RBAC):

### Platform Engineer
**Responsibilities:**
- Create deployments
- View deployments
- Retry failed deployments
- View deployment outputs
- View pipeline logs
- Cancel running deployments

**Cannot:**
- Approve production deployments
- Manage users
- Modify system configuration

### Approver
**Responsibilities:**
- Review deployment requests
- Approve deployments
- Reject deployments
- View deployment history

**Cannot:**
- Modify templates
- Manage users

### Administrator
**Responsibilities:**
- Manage users
- Configure cloud connections
- Configure GitHub
- Configure Azure DevOps
- Register Terraform templates
- Configure default settings
- View all deployments
- View audit logs

---

## 8. Main Navigation

- **Dashboard**
- **Deploy AI Environment**
- **Templates**
- **My Deployments**
- **Deployment History**
- **Administration** *(visible only to Administrators)*

---

## 9. Dashboard

The Dashboard provides a high-level overview.

**Widgets:**
- Active Deployments
- Recent Deployments
- Failed Deployments
- Template Usage
- Quick Deploy
- Deployment History

**Quick Actions:**
- New Deployment
- View Templates
- Retry Failed Deployment

---

## 10. Deploy AI Environment

The portal shall support two deployment experiences:

### Option 1: AI Assistant (Chat)
Users describe what they want.
*Example:* "I need an enterprise RAG environment with private networking."

**The assistant shall:**
- Understand the request
- Recommend one existing template
- Explain why the template was selected
- Pre-fill configuration parameters
- Allow the user to review and modify the configuration before deployment

*The AI Assistant must not generate Terraform or alter template definitions. It may only recommend from the catalog of approved templates and pre-fill configuration values.*

### Option 2: Guided Deployment Wizard
The wizard asks a sequence of questions.

**Example flow:**
- **Step 1:** Select Cloud Provider (Azure; Future: AWS, GCP)
- **Step 2:** Deployment Type (Standard Public / Standard Private)
- **Step 3:** Select AI Platform (Microsoft Foundry)
- **Step 4:** Select AI Solution (e.g., AI Chatbot, RAG, AI Agent, Enterprise AI APIs, Voice Assistant)
- **Step 5:** Networking (Public / Private)
- **Step 6:** Select Template (The UI displays recommended templates, e.g., Enterprise RAG with resources: Foundry, Azure OpenAI, Search, Storage, Key Vault, Cosmos)
- **Step 7:** Configuration (User configures deployment parameters: Resource Group, Region, Environment, Project Name, Project Prefix; Azure OpenAI: Model Name [Default: GPT-4o-mini], Deployment Name, Capacity / TPM)
- **Step 8:** Review (Displays Cloud, Selected Template, Resources, Parameters, Estimated Deployment Time, Target Subscription, Deploy button)

---

## 11. Template Catalog

The portal shall maintain an internal catalog of approved templates.

**Each template contains:**
- Name
- Description
- Cloud
- AI Platform
- Deployment Type
- Supported Services
- Terraform Repository
- Terraform Path
- Version
- Status

*Users cannot modify template definitions.*

---

## 12. Deployment Flow

```text
User -> Template Selected -> Populate Variables -> Validate -> Trigger Pipeline -> Monitor -> Complete
```

---

## 13. Pipeline Integration

**Supported Platforms:**
- GitHub Actions
- Azure DevOps

The Administrator configures the CI/CD provider. The portal triggers the configured pipeline using predefined inputs such as:
- Deployment identifier
- Template version
- Terraform variable values
- Target cloud subscription
- Environment
- Deployment metadata

*The portal does not execute Terraform directly.*

---

## 14. Deployment Status

Every deployment shall expose status.

**Statuses:**
- Queued
- Waiting for Approval
- In Progress
- Failed
- Cancelled
- Completed

**Progress Stages:**
```text
Queued -> Initializing -> Planning -> Provisioning -> Validating -> Completed
```

---

## 15. Deployment Details

Every deployment page shall display:

**General:**
- Deployment ID
- User
- Status
- Cloud
- Environment
- Start Time
- End Time

**Infrastructure:**
- Resources Created

**Terraform Outputs Examples:**
- Foundry URL
- Azure OpenAI Endpoint
- AI Search Endpoint
- Storage Account
- Key Vault URI
- Cosmos Endpoint

**Pipeline:**
- Provider Name
- Build Number
- Triggered By
- Commit / Run ID
- Duration
- Logs

---

## 16. Error Handling

If deployment fails, display:
- Failure Summary
- Pipeline Stage
- Failing Step
- Terraform Error
- Suggested Resolution
- Actions: Retry, View Logs (Raw Pipeline Logs)

*The portal should present user-friendly summaries while preserving access to the original pipeline logs for troubleshooting.*

---

## 17. Templates Page

The Templates page displays all available templates:
- Template Name
- Description
- Cloud
- AI Platform
- Version
- Deployment Type
- Services Included

*Users may inspect template details but cannot modify them.*

---

## 18. My Deployments

**Display:**
- Deployment Name
- Template
- Status
- Cloud
- Environment
- Subscription
- Created Date

**Actions:**
- View
- Retry
- Cancel (while running)

---

## 19. Deployment History

Maintains historical deployments.
- Deployment ID
- User
- Status
- Template
- Timestamp
- Duration
- Cloud

---

## 20. Administration

Administrator capabilities:
- **Users:** Create User, Delete User, Assign Role
- **CI/CD:** Configure GitHub Actions / Azure DevOps (Repository, Workflow/Pipeline Name, Branch, Authentication, Connection Status)
- **Templates:** Register Terraform templates (Name, Description, Repository, Path, Cloud, Version). *The portal does not edit template contents.*
- **Model Catalog:** Administrators maintain the list of supported Azure OpenAI models:
  - `GPT-4o-mini` (Default: Yes, Enabled: Yes)
  - `GPT-4o` (Default: No, Enabled: Yes)
  - `GPT-4o nano` (Default: No, Enabled: Yes)
  - `text-embedding-3` (Default: No, Enabled: Yes)

*The portal validates that only approved models can be selected.*

---

## 21. Notifications

The portal shall display notifications for:
- Deployment Started
- Approval Required
- Deployment Completed
- Deployment Failed
- Deployment Cancelled

---

## 22. Non-Functional Requirements

- **Performance:** Dashboard loads within 3 seconds under normal operating conditions. Deployment status refreshes automatically at configurable intervals.
- **Availability:** Target availability: 99.9%.
- **Security:** Microsoft Entra ID authentication, RBAC, HTTPS only, Secure secret storage, Audit logging.
- **Scalability:** Support concurrent deployments, support multiple Azure subscriptions, architecture ready for AWS and GCP expansion.
- **Usability:** Responsive web application, Clear visual cues, Accessible navigation, Consistent user experience.

---

## 23. Out of Scope (Version 1)

The following capabilities are intentionally excluded from the initial release:
- Terraform code generation
- Visual architecture designer
- Day 2 operations (scale, update, destroy, lifecycle management)
- Policy validation (OPA / Azure Policy)
- Automated cost estimation
- Drift detection
- Non-Azure deployments (AWS and GCP)
- Advanced governance features
- Custom template authoring through the UI

---

## 24. Future Roadmap

Planned enhancements include:
- AWS support (Amazon Bedrock, AWS AgentCore)
- Google Cloud support (Google Gemini Enterprise Agent Platform, Google Agent Development Kit)
- Day 2 operations
- Cost estimation
- Enterprise governance
- Policy validation
- Drift detection
- Deployment cloning
- Multi-region deployments
- Organization-wide dashboards
- Template version lifecycle management
- Integration with ITSM and approval workflows
- Advanced analytics and reporting

---

## 25. Success Criteria

The portal will be considered successful when it:
- Enables self-service provisioning without Terraform knowledge.
- Ensures all deployments use approved Terraform templates.
- Provides a consistent deployment experience across environments.
- Reduces infrastructure provisioning time.
- Simplifies troubleshooting through integrated deployment visibility.
- Establishes a cloud-agnostic foundation that can be extended to AWS and GCP in future releases without redesigning the user experience.
