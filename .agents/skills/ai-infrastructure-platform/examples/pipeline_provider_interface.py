"""
AI Infrastructure Platform (AIP)
CI/CD Pipeline Provider Abstraction

This interface isolates the FastAPI backend from direct coupling to GitHub Actions
or Azure DevOps Pipelines APIs. Supporting a new CI/CD runner simply requires
implementing this interface.
"""

from abc import ABC, abstractmethod
from enum import Enum
from typing import Dict, Any, Optional
from pydantic import BaseModel, Field


class PipelineStatusEnum(str, Enum):
    QUEUED = "queued"
    IN_PROGRESS = "in_progress"
    SUCCESS = "success"
    FAILED = "failed"
    CANCELLED = "cancelled"
    WAITING_APPROVAL = "waiting_approval"


class DeploymentRequest(BaseModel):
    deployment_id: str
    blueprint_id: str
    template_name: str
    template_version: str
    target_cloud: str = "azure"
    parameters: Dict[str, Any] = Field(default_factory=dict)
    requester_email: str
    environment: str = "dev"  # dev, test, prod


class PipelineRun(BaseModel):
    run_id: str
    pipeline_provider: str
    status: PipelineStatusEnum
    web_url: str
    started_at: Optional[str] = None


class PipelineStatus(BaseModel):
    run_id: str
    status: PipelineStatusEnum
    current_stage: Optional[str] = None  # e.g., "Terraform Apply"
    failing_step: Optional[str] = None   # e.g., "Azure AI Search"
    error_message: Optional[str] = None
    terraform_outputs: Optional[Dict[str, Any]] = None


class PipelineProvider(ABC):
    """
    Abstract base class for triggering and monitoring CI/CD pipeline runs.
    """

    @abstractmethod
    async def trigger_deployment(self, request: DeploymentRequest) -> PipelineRun:
        """Trigger an enterprise CI/CD workflow to execute the Terraform plan and apply."""
        pass

    @abstractmethod
    async def get_status(self, run_id: str) -> PipelineStatus:
        """Query the pipeline status, current stage, and failure details."""
        pass

    @abstractmethod
    async def get_logs(self, run_id: str) -> str:
        """Retrieve deployment logs from the CI/CD runner."""
        pass

    @abstractmethod
    async def cancel_deployment(self, run_id: str) -> bool:
        """Cancel an in-flight deployment pipeline."""
        pass


class GitHubActionsProvider(PipelineProvider):
    """
    GitHub Actions implementation using the GitHub REST API (workflow_dispatch).
    """

    def __init__(self, token: str, repo: str, owner: str, workflow_file: str = "deploy.yml"):
        self.token = token
        self.repo = repo
        self.owner = owner
        self.workflow_file = workflow_file

    async def trigger_deployment(self, request: DeploymentRequest) -> PipelineRun:
        # POST /repos/{owner}/{repo}/actions/workflows/{workflow_file}/dispatches
        return PipelineRun(
            run_id=f"gha-{request.deployment_id}",
            pipeline_provider="github_actions",
            status=PipelineStatusEnum.QUEUED,
            web_url=f"https://github.com/{self.owner}/{self.repo}/actions",
        )

    async def get_status(self, run_id: str) -> PipelineStatus:
        # GET /repos/{owner}/{repo}/actions/runs/{run_id}
        return PipelineStatus(run_id=run_id, status=PipelineStatusEnum.IN_PROGRESS)

    async def get_logs(self, run_id: str) -> str:
        # GET /repos/{owner}/{repo}/actions/runs/{run_id}/logs
        return "Terraform Plan executed successfully. Applying Azure Foundry..."

    async def cancel_deployment(self, run_id: str) -> bool:
        # POST /repos/{owner}/{repo}/actions/runs/{run_id}/cancel
        return True


class AzureDevOpsProvider(PipelineProvider):
    """
    Azure DevOps implementation using the ADO Pipelines REST API.
    """

    def __init__(self, pat_token: str, organization: str, project: str, pipeline_id: int):
        self.pat_token = pat_token
        self.organization = organization
        self.project = project
        self.pipeline_id = pipeline_id

    async def trigger_deployment(self, request: DeploymentRequest) -> PipelineRun:
        # POST https://dev.azure.com/{org}/{project}/_apis/pipelines/{pipeline_id}/runs?api-version=7.1-preview.1
        return PipelineRun(
            run_id=f"ado-{request.deployment_id}",
            pipeline_provider="azure_devops",
            status=PipelineStatusEnum.QUEUED,
            web_url=f"https://dev.azure.com/{self.organization}/{self.project}/_build",
        )

    async def get_status(self, run_id: str) -> PipelineStatus:
        return PipelineStatus(run_id=run_id, status=PipelineStatusEnum.IN_PROGRESS)

    async def get_logs(self, run_id: str) -> str:
        return "Terraform logs retrieved from ADO build artifacts..."

    async def cancel_deployment(self, run_id: str) -> bool:
        return True
