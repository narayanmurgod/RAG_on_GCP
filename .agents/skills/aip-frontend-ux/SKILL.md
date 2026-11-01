---
name: aip-frontend-ux
description: >-
  Use this skill when designing, scaffolding, implementing, or styling frontend components and pages for the AI Infrastructure Self-Service Portal.
  Covers the React 19 / Next.js / Fluent UI / Tailwind CSS design system, screen layouts (Dashboard, Chat Assistant, 7-step Guided Wizard,
  Template Catalog, Deployment Progress stepper, Error Diagnostic card, Admin console), state management with TanStack Query and Zustand,
  and WCAG 2.1 AA accessibility guidelines based on ui_requirements.md and ux_design.md.
---

# AIP Frontend & UX Engineering Skill

This skill guides engineers and agents in building the user interface and user experience for the **AI Infrastructure Self-Service Portal** according to the specifications in `ui_requirements.md` and `ux_design.md`.

---

## 1. Core Frontend Philosophy & Design Principles

When implementing UI components or user flows, adhere to these guidelines:

1. **No Terraform Exposure**:
   - The UI never exposes raw Terraform code, HCL syntax, or files to standard users.
   - Users choose **Blueprints** and configure high-level parameters (e.g., Environment, Region, Model, Capacity).
2. **Two Deployment Paths**:
   - **AI Assistant (Chat)**: Conversational interface that recommends an approved template, explains why, and pre-fills the configuration.
   - **Guided Wizard (7 Steps)**: Progressive stepper ensuring error-free configuration.
3. **Visibility & Continuous Feedback**:
   - Deployment status is always visible with real-time pipeline steppers (`Initializing` -> `Planning` -> `Provisioning` -> `Validating` -> `Completed`).
   - Use skeleton loaders during data fetch; never display unstyled empty screens.
4. **Actionable Failure Diagnostics**:
   - Never display raw stack traces.
   - Display structured error diagnostic cards with Stage, Failing Step, Reason, and Suggested Action.
5. **Fluent UI + Tailwind CSS Aesthetic**:
   - Matches enterprise Microsoft portals (Azure Portal, Azure DevOps, Databricks).

---

## 2. Technology Stack & Component Architecture

```text
frontend/
├── src/
│   ├── app/                                 # Next.js App Router
│   │   ├── (auth)/login/page.tsx            # MSAL Entra ID login
│   │   ├── dashboard/page.tsx               # Operational dashboard
│   │   ├── deploy/
│   │   │   ├── page.tsx                     # Landing (AI Chat vs. Wizard selector)
│   │   │   ├── chat/page.tsx                # AI Assistant conversational deploy
│   │   │   └── wizard/page.tsx              # 7-step progressive wizard
│   │   ├── templates/page.tsx               # Template Catalog browser & details drawer
│   │   ├── deployments/
│   │   │   ├── page.tsx                     # My Deployments list & filters
│   │   │   ├── [id]/progress/page.tsx       # Live pipeline progress stepper
│   │   │   └── [id]/details/page.tsx        # Completed resources & copyable outputs
│   │   ├── history/page.tsx                 # Historical audit trail
│   │   └── admin/page.tsx                   # Admin tabs (Users, Templates, Models, CI/CD)
│   ├── components/
│   │   ├── layout/                          # Sidebar, Header, NotificationCenter
│   │   ├── wizard/                          # Step 1 to 7 components
│   │   ├── chat/                            # AssistantMessage, RecommendedTemplateCard
│   │   ├── deployment/                      # PipelineStepper, DiagnosticCard, OutputsTable
│   │   └── ui/                              # Fluent UI wrappers & Tailwind atoms
│   ├── hooks/                               # useDeployment, useTemplates, useModels
│   ├── store/                               # Zustand store for Wizard & Chat state
│   └── lib/                                 # API client, MSAL config, validation schemas
```

---

## 3. Screen Specifications & Implementation Details

### 3.1 Primary Navigation & Header
- **Sidebar (Fixed Left)**: Logo, Dashboard, Deploy AI Environment, Templates, My Deployments, Deployment History, Administration (Admins only), User Profile.
- **Global Header**: Search input, `[ Quick Deploy ]` primary action, `[🔔]` Notifications bell, User Profile avatar.

### 3.2 Deploy AI Environment - Two Paths
#### Option A: AI Assistant (Chat)
- Chat container with conversational prompt history.
- When the assistant identifies the user's intent:
  - Renders a **Recommended Template Card** inline.
  - Card displays: Template Name (e.g., *Enterprise RAG*), Confidence badge (`High`), Included Resources list, Rationale explanation, and `[ Continue to Configuration ]` CTA.
  - Assistant strictly recommends approved templates; it **never** authors Terraform.

#### Option B: Guided Deployment Wizard (7 Steps)
The wizard uses a persistent visual stepper:
- **Step 1 (Cloud Provider)**: Select Azure (Active), AWS (Coming Soon badge), GCP (Coming Soon badge).
- **Step 2 (Deployment Type)**: Toggle between `Standard Public` and `Standard Private` (with VNet/Private Link).
- **Step 3 (Solution Type)**: Cards for `AI Chatbot`, `RAG`, `AI Agent`, `Enterprise APIs`, `Voice Assistant`.
- **Step 4 (Template Recommendation)**: Card showing recommended template, description, services, estimated deploy time, with `[ Select ]` or `[ Browse Other Templates ]`.
- **Step 5 (Configuration)**:
  - General: Resource Group, Subscription, Region, Environment (`dev`/`test`/`prod`), Project Name, Naming Prefix.
  - Azure OpenAI: Model dropdown (pre-selected default `GPT-4o-mini`, options: `GPT-4o`, `GPT-4o nano`, `text-embedding-3`), Deployment Name, Capacity (TPM).
  - Advanced (Accordion, collapsed by default): Tags, Custom Naming Prefix, Enable Diagnostics.
- **Step 6 (Review)**: Comprehensive summary card detailing Cloud, Template, Networking, Model, and Resource checklist with `[ Deploy ]` button.
- **Step 7 (Launch)**: Triggers deployment and immediately redirects to `Deployment Progress`.

### 3.3 Deployment Progress (Operational Hub)
- **Header**: Deployment Name (e.g., `Enterprise-RAG-001`), Status badge (`Running`).
- **Progress Bar**: Smooth animated percentage bar.
- **Pipeline Stage Stepper**:
  - `Initializing` (Completed)
  - `Terraform Plan` (Completed)
  - `Azure OpenAI` (In Progress / Spinner)
  - `Search` (Pending)
  - `Storage` (Pending)
- **CI/CD Integration Card**: Provider badge (GitHub Actions / Azure DevOps), Build number, `[ View Live Logs ]` button which opens an offcanvas slide-over drawer streaming raw runner logs.
- Automatically polls `/api/v1/deployments/{id}` every 3-5 seconds.

### 3.4 Completed Deployment Details
- **Overview Card**: Status (`Completed`), duration, creator, target subscription.
- **Resources Created**: Interactive cards for Foundry, OpenAI, Search, Storage, Key Vault, Cosmos DB.
- **Outputs Table**: Key/value rows for endpoints (`Foundry URL`, `OpenAI Endpoint`, `Search Endpoint`, `Key Vault URI`) with one-click **Copy to Clipboard**.

### 3.5 Failure Experience (Diagnostic Card)
Instead of raw error traces, render an actionable card:
```tsx
<DiagnosticCard
  stage="Terraform Apply"
  failingStep="Azure AI Search"
  reason="Quota unavailable for standard SKU in eastus."
  suggestion="Choose another region (e.g., eastus2) or request a quota increase via Azure Support."
  onRetry={handleRetry}
  onViewLogs={openLogsDrawer}
/>
```

### 3.6 Administration Console (Tabs)
- **Users**: User list, roles (Platform Engineer, Approver, Administrator), assign role modal.
- **Templates**: Registered templates, paths, versions, enable/disable switches.
- **Model Catalog**: Table of models, default toggle (default `GPT-4o-mini`), enabled switches.
- **CI/CD**: Settings for GitHub Actions and Azure DevOps (repo, branch, workflow name, auth token).

---

## 4. State Management & Form Validation

- **Form Management**: React Hook Form with Zod schemas for Step 5 configuration.
- **Validation Rules**:
  - `projectName`: `^[a-z0-9-]{3,24}$` (lowercase alphanumeric and hyphens).
  - `environment`: Enum (`dev`, `test`, `prod`).
  - `model`: Must match an active model from the Model Catalog query.
- **Server Cache & Polling**:
  ```typescript
  const { data: deployment } = useQuery({
    queryKey: ['deployment', deploymentId],
    queryFn: () => fetchDeployment(deploymentId),
    refetchInterval: (query) => 
      ['queued', 'in_progress', 'initializing'].includes(query.state.data?.status) ? 3000 : false,
  });
  ```

---

## 5. Accessibility & Non-Functional UX Standards

- **WCAG 2.1 AA Compliance**:
  - Contrast ratio >= 4.5:1 for normal text.
  - Visible focus rings (`focus-visible:ring-2 focus-visible:ring-primary`).
  - Screen reader attributes (`aria-expanded`, `aria-current="step"`, `aria-live="polite"`).
- **Responsive Layout**: Desktop (1280px+) primary, Tablet supported, Mobile read-only dashboard.
- **Performance**: Initial dashboard load under 3.0s using server components and code-splitting.
