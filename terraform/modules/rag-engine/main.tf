# Vertex AI RAG Corpus and Cloud Storage document staging bucket

locals {
  # Generate bucket name if not explicitly specified
  generated_bucket_name = "${var.project_id}-rag-staging-${replace(lower(var.display_name), "/[^a-z0-9]/", "-")}"
  bucket_name           = var.staging_bucket_name != "" ? var.staging_bucket_name : local.generated_bucket_name
}

# Vertex AI RAG Corpus resource (managed vector database)
resource "google_vertex_ai_rag_corpus" "this" {
  project      = var.project_id
  region       = var.region
  display_name = var.display_name
  description  = var.description

  vector_db_config {
    # Managed vector DB configuration for KNN or ANN
    dynamic "rag_managed_db" {
      for_each = startswith(var.db_type, "rag_managed") ? [1] : []
      content {
        # Exact K-Nearest Neighbors search
        dynamic "knn" {
          for_each = var.db_type == "rag_managed_knn" ? [1] : []
          content {}
        }

        # Approximate Nearest Neighbors tree search
        dynamic "ann" {
          for_each = var.db_type == "rag_managed_ann" ? [1] : []
          content {
            leaf_count = var.ann_leaf_count
            tree_depth = var.ann_tree_depth
          }
        }
      }
    }

    # Dedicated Vertex AI Vector Search integration
    dynamic "vertex_vector_search" {
      for_each = var.db_type == "vertex_vector_search" ? [1] : []
      content {
        index          = var.vertex_vector_search_index
        index_endpoint = var.vertex_vector_search_endpoint
      }
    }
  }
}

# Cloud Storage staging bucket for document uploads
resource "google_storage_bucket" "staging" {
  count                       = var.create_staging_bucket ? 1 : 0
  name                        = local.bucket_name
  project                     = var.project_id
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = false
  labels                      = var.labels

  versioning {
    enabled = true
  }
}
