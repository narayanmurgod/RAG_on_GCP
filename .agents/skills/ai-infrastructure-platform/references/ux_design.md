# AI Infrastructure Self-Service Portal
## User Experience Design Specification (Version 1.0)

---

## 1. Introduction

This document defines the complete User Experience (UX) for the AI Infrastructure Self-Service Portal.

It serves as the implementation blueprint for frontend development and defines:
- Screen hierarchy
- Navigation
- User journeys
- Page layouts
- Components
- Interaction behavior
- Validation
- Error handling

*This document complements the UI Requirements document.*

---

## 2. UX Design Principles

The portal shall adhere to the following principles:

- **Simplicity:** Users should not require Terraform knowledge.
- **Guided Experience:** Every workflow should progressively guide the user.
- **Visibility:** Deployment status should always be visible.
- **Consistency:** Common layouts, buttons, forms, and navigation across all pages.
- **Progressive Disclosure:** Show advanced settings only when needed.
- **Enterprise Ready:** Professional appearance similar to Azure Portal, GitLab, Databricks, Azure DevOps.

---

## 3. Primary Navigation

```text
+-------------------------------------------------------+
|  LOGO   [Search...]              [Quick Deploy] [🔔] [Profile] |
+-------------------------------------------------------+
| Dashboard                                             |
| Deploy AI Environment                                 |
| Templates                                             |
| My Deployments                                        |
| Deployment History                                    |
| Administration (Admins only)                          |
| User Profile                                          |
+-------------------------------------------------------+
```

- Navigation remains fixed on the left sidebar.
- Header contains: Search bar, Quick Deploy button, Notifications bell, User Profile.

---

## 4. User Journey

```text
Login
  |
  v
Dashboard
  |
  v
Deploy AI Environment
  |
  +---> Chat (AI Assistant)
  |       OR
  +---> Guided Wizard (7 Steps)
  |
  v
Template Recommendation & Selection
  |
  v
Configuration (General, Model, Advanced)
  |
  v
Review
  |
  v
Deploy
  |
  v
Pipeline Execution & Real-Time Progress
  |
  v
Deployment Complete
  |
  v
View Outputs (Endpoints, Keys, Logs)
```

---

## 5. Dashboard

**Purpose:** Provide immediate operational visibility and rapid shortcuts.

**Layout:**
- Header: `Welcome, <User Name>`
- **Quick Actions:**
  - `[ Deploy Environment ]`
  - `[ Browse Templates ]`
- **Deployment Summary Cards:**
  - Running
  - Completed
  - Failed
  - Pending Approval
- **Recent Deployments Table:**
  - Columns: Deployment Name, Status, Cloud, Created By, Date, Actions (View, Retry)
- **Latest Templates Carousel/List**
- **Recent Notifications Drawer**

---

## 6. Deploy AI Environment (Landing Page)

**Purpose:** Provide users with clear choice between conversational and guided paths.

```text
+----------------------------------------------------------------+
|                   How would you like to deploy?                |
|                                                                |
|   +--------------------------+   +--------------------------+  |
|   |      AI Assistant        |   |      Guided Wizard       |  |
|   | Describe what you want   |   | Step-by-step deployment  |  |
|   +--------------------------+   +--------------------------+  |
+----------------------------------------------------------------+
```

---

## 7. AI Assistant Screen

**Purpose:** Help users discover the correct template using natural language.

**Behavior:**
- The assistant recommends **only** approved templates and never generates Terraform.
- The assistant may:
  - Ask clarifying questions
  - Recommend one specific template
  - Explain the rationale for recommendation
  - Pre-fill deployment settings
- The assistant shall not:
  - Generate Terraform code
  - Modify template definitions
  - Create custom templates

**Layout:**
- Left/Center: Chat conversation window (`"What would you like to build?"`).
- Right/Bottom: **Recommended Template Card**:
  - Template Name: *Enterprise RAG*
  - Confidence: *High*
  - Resources Included: Foundry, Azure OpenAI, Search, Storage, Key Vault, Cosmos DB
  - Rationale: *"This template best matches your enterprise RAG and storage requirements."*
  - Button: `[ Continue to Configuration ]`

---

## 8. Guided Wizard (7-Step Flow)

The wizard displays a persistent progress stepper (`Step X of 7`):

### Step 1: Cloud Provider
- **Options:**
  - Azure (Active)
  - AWS (Coming Soon badge)
  - GCP (Coming Soon badge)

### Step 2: Deployment Type
- **Options:**
  - Standard Public
  - Standard Private (with enterprise networking)

### Step 3: Solution Type
- **Options:**
  - AI Chatbot
  - RAG
  - AI Agent
  - Enterprise APIs
  - Voice Assistant

### Step 4: Recommended Template
- Displays primary matching template card (e.g., *Enterprise RAG*).
- Shows: Description, Included Resources, Estimated Deploy Time.
- Action: `[ Select Template ]` (with secondary option: *"Browse other templates"*).

### Step 5: Configuration
- **General Settings:**
  - Resource Group
  - Subscription
  - Region
  - Environment (dev / test / prod)
  - Project Name
  - Naming Prefix
- **Azure OpenAI Configuration:**
  - Model Dropdown (Default: `GPT-4o-mini`, options: `GPT-4o`, `GPT-4o nano`, `text-embedding-3`)
  - Deployment Name
  - Capacity (TPM)
- **Advanced Settings (Collapsed by default):**
  - Tags
  - Custom Naming Prefix
  - Enable Diagnostics / Logging

### Step 6: Review
- Large summary card:
  - Cloud: *Azure*
  - Template: *Enterprise RAG*
  - Networking: *Private*
  - Model: *GPT-4o-mini*
  - Resources: Foundry, Search, Storage, Cosmos DB, Key Vault
- Action: `[ Deploy ]` button.

### Step 7: Deployment Launch
- Automatically redirects to the **Deployment Progress** screen.

---

## 9. Template Catalog Screen

**Purpose:** Allow users to browse and inspect approved templates.

**Layout:**
- Search bar
- Filters: Cloud, Deployment Type (Public/Private), Category
- **Template Cards Grid:**
  - Enterprise RAG, AI Agent, Voice Assistant, Enterprise APIs, Minimal AI Workspace
- **Template Details Modal/Drawer:**
  - Information & Description
  - Cloud & AI Platform
  - Included Services
  - Version & Terraform Module Version
  - Estimated Deployment Time
  - Supported Regions
  - Action: `[ Deploy This Template ]`

---

## 10. Deployment Progress Screen

*This becomes the primary operational screen immediately after initiating a deployment.*

**Layout:**
- Deployment Header: Name (e.g., `Enterprise-RAG-001`), Status badge (`Running`)
- Global Progress Bar
- **Pipeline Stage Stepper:**
  1. `Initializing` (Completed)
  2. `Terraform Plan` (Completed)
  3. `Azure OpenAI` (Running / Provisioning)
  4. `Search` (Pending)
  5. `Storage` (Pending)
- **Pipeline Metadata Card:**
  - CI/CD Provider: GitHub Actions / Azure DevOps
  - Triggered by, Start time
  - Button: `[ View Live Logs ]` (opens drawer/modal with streaming runner logs)
- Automatically updates status via polling / SSE / WebSocket without page reloads.

---

## 11. Deployment Details Screen (Post-Completion)

Shown upon successful completion:

**Overview Section:**
- Deployment Name, Cloud, Template, Status (`Completed`), Duration, Created By, Target Subscription.

**Resources Created:**
- Interactive service cards: Microsoft Foundry, Azure OpenAI, Azure AI Search, Azure Storage, Azure Key Vault, Cosmos DB.

**Terraform Outputs Table:**
- Keys & Values with one-click **Copy to Clipboard**:
  - `Foundry URL`
  - `OpenAI Endpoint`
  - `Search Endpoint`
  - `Key Vault URI`
  - `Cosmos DB Endpoint`

**Pipeline Summary:**
- Provider, Build/Run Number, Commit ID, Duration, Link to CI/CD run.

---

## 12. Failure Experience & Error Handling

Instead of raw, unformatted Terraform stack traces, the portal displays an actionable failure diagnostic card:

```text
+---------------------------------------------------------------+
|  ❌ Deployment Failed                                         |
|                                                               |
|  Stage:       Terraform Apply                                 |
|  Step:        Azure AI Search                                 |
|  Status:      Failed                                          |
|  Reason:      Quota unavailable for standard SKU in eastus.   |
|  Suggestion:  Choose another region (e.g., eastus2) or        |
|               request a quota increase via Azure Support.     |
|                                                               |
|  [ Retry Deployment ]            [ View Raw Pipeline Logs ]   |
+---------------------------------------------------------------+
```

---

## 13. My Deployments Screen

- Filters: Status (Running, Completed, Failed), Cloud, Environment.
- Deployment List Cards / Data Table.
- Actions:
  - `[ View ]` -> redirects to Deployment Details / Progress.
  - `[ Retry ]` -> re-triggers deployment with populated parameters.
  - `[ Cancel ]` -> active while deployment is running.

---

## 14. Deployment History Screen

- Complete audit trail of all deployments.
- Columns: Deployment ID, User, Template, Status, Date/Time, Duration, Cloud.

---

## 15. Administration Screen (Admins Only)

Divided into sub-tabs:

1. **Users Tab:**
   - User table, email, assigned role (Platform Engineer, Approver, Administrator), role dropdown.
2. **Templates Tab:**
   - Table of registered templates (Name, Version, Cloud, Repository Path, Status).
   - Actions: `[ Register Template ]`, `[ Disable Template ]`, `[ Update Version ]`.
   - *Admins cannot edit raw Terraform through the portal.*
3. **Model Catalog Tab:**
   - Table of models: Provider, Model ID, Default toggle, Enabled toggle.
   - Example:
     - `GPT-4o-mini`: Default: Yes | Enabled: Yes
     - `GPT-4o`: Default: No | Enabled: Yes
     - `GPT-4o nano`: Default: No | Enabled: Yes
     - `text-embedding-3`: Default: No | Enabled: Yes
4. **CI/CD Configuration Tab:**
   - Configure GitHub Actions or Azure DevOps connection:
     - Repository, Branch, Workflow/Pipeline Name, Authentication Token/Secret, Connection Status check button.

---

## 16. Notifications Center

- Slide-out drawer accessible via the bell icon `[🔔]` in the global header.
- Notifications emitted on:
  - Deployment Started
  - Approval Required
  - Deployment Completed
  - Deployment Failed
  - Deployment Cancelled

---

## 17. Form Validation Rules

Validation occurs before deployment can be submitted:
- **Required Fields:** Project Name, Environment, Resource Group, Region, Subscription.
- **Naming Conventions:** RegEx pattern check on Project Prefix and Resource Names.
- **Model Validation:** Ensures only active, admin-approved models can be selected.
- **Template Validation:** Deployment cannot proceed without an approved, active template selected.

---

## 18. Empty States & Feedback

- **No Deployments:**
  *"You haven't deployed any AI environments yet."* -> Action: `[ Deploy Environment ]`
- **No Templates:**
  *"No templates available. Please contact your Platform Administrator."*

---

## 19. Loading & Skeleton States

- Every page displays skeleton loaders during data fetch to prevent layout shifts.
- Avoid blank white screens; visual progress indicators must always be visible.

---

## 20. Responsive Behavior & Accessibility

- **Breakpoints:**
  - Desktop: Primary target (1280px+)
  - Tablet: Supported (768px - 1279px)
  - Mobile: Read-only monitoring for Version 1
- **Accessibility (WCAG 2.1 AA):**
  - Full keyboard navigation (Tab/Shift-Tab/Enter)
  - Screen reader aria-labels on all buttons and status icons
  - High contrast themes supported
  - Accessible color contrast ratios

---

## 21. Frontend Design System & Tech Stack

- **Framework:** Next.js (App Router) + React 19 + TypeScript
- **UI Components:** Fluent UI (`@fluentui/react-components` - standard for Microsoft/Azure enterprise apps)
- **CSS Utility:** Tailwind CSS
- **Forms:** React Hook Form + Zod schema validation
- **Icons:** Fluent UI System Icons
- **Charts:** Recharts
- **Notifications:** React Toast / Sonner
- **Data Fetching & State:** TanStack Query + Zustand

---

## 22. Blueprint Mapping Layer (Enterprise Recommendation)

The UX specification reinforces that the platform must expose **Blueprints** to users sitting one level above Terraform templates:

| Blueprint | Cloud | Maps to Template |
|---|---|---|
| Enterprise RAG | Azure | `azure-standard-private-enterprise-rag.tf` |
| AI Chatbot | Azure | `azure-standard-public-chatbot.tf` |
| Voice Assistant | Azure | `azure-standard-public-voice.tf` |

*The user interacts only with the Blueprint. The Platform Administrator maps each Blueprint to a specific Terraform template and version behind the scenes.*
