# Terraform and provider version requirements for Serverless RAG Quickstart

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # HashiCorp Google Cloud provider
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0, < 9.0"
    }
  }
}

# Google Cloud provider initialization
provider "google" {
  project = var.project_id
  region  = var.region
}
