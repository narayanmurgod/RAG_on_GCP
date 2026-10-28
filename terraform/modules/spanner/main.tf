# Cloud Spanner instance, database, vector search index, and graph RAG schema

locals {
  # Resolved display name for the Spanner instance
  display_name = var.display_name != "" ? var.display_name : var.instance_id

  # Base documents table with vector embedding column
  base_ddl = [
    <<-EOT
      CREATE TABLE documents (
        doc_id STRING(64) NOT NULL,
        content STRING(MAX),
        metadata JSON,
        embedding ARRAY<FLOAT64>(vector_length=>${var.embedding_dimension}),
        created_at TIMESTAMP OPTIONS (allow_commit_timestamp=true)
      ) PRIMARY KEY (doc_id)
    EOT
  ]

  # Vector search index for approximate nearest neighbor retrieval
  vector_index_ddl = var.enable_vector_index ? [
    <<-EOT
      CREATE VECTOR INDEX documents_embedding_idx ON documents(embedding)
      OPTIONS (distance_type='${var.distance_type}')
    EOT
  ] : []

  # Spanner Graph DDL for Graph-Augmented RAG
  graph_rag_ddl = var.enable_graph_rag ? [
    <<-EOT
      CREATE TABLE entities (
        entity_id STRING(64) NOT NULL,
        name STRING(256),
        entity_type STRING(64),
        properties JSON
      ) PRIMARY KEY (entity_id)
    EOT
    ,
    <<-EOT
      CREATE TABLE relationships (
        from_id STRING(64) NOT NULL,
        to_id STRING(64) NOT NULL,
        relation_type STRING(64) NOT NULL,
        properties JSON
      ) PRIMARY KEY (from_id, to_id, relation_type)
    EOT
    ,
    <<-EOT
      CREATE PROPERTY GRAPH KnowledgeGraph
        NODE TABLES (
          entities
        )
        EDGE TABLES (
          relationships
            SOURCE KEY (from_id) REFERENCES entities (entity_id)
            DESTINATION KEY (to_id) REFERENCES entities (entity_id)
            LABEL relates_to
        )
    EOT
  ] : []

  # Combined DDL list executed on database creation
  all_ddl = concat(local.base_ddl, local.vector_index_ddl, local.graph_rag_ddl, var.extra_ddl_statements)
}

# Cloud Spanner instance resource
resource "google_spanner_instance" "this" {
  project          = var.project_id
  name             = var.instance_id
  config           = var.config
  display_name     = local.display_name
  processing_units = var.processing_units
  labels           = var.labels
  force_destroy    = var.force_destroy
}

# Cloud Spanner database resource with vector and graph DDL
resource "google_spanner_database" "this" {
  project                  = var.project_id
  instance                 = google_spanner_instance.this.name
  name                     = var.database_name
  version_retention_period = var.version_retention_period
  ddl                      = local.all_ddl
  deletion_protection      = false

  # Optional customer-managed encryption key configuration
  dynamic "encryption_config" {
    for_each = var.kms_key_name != null ? [1] : []
    content {
      kms_key_name = var.kms_key_name
    }
  }
}

# Grant database user IAM role to authorized service accounts
resource "google_spanner_database_iam_member" "users" {
  for_each = toset(var.authorized_service_accounts)

  project  = var.project_id
  instance = google_spanner_instance.this.name
  database = google_spanner_database.this.name
  role     = "roles/spanner.databaseUser"
  member   = "serviceAccount:${each.value}"
}
