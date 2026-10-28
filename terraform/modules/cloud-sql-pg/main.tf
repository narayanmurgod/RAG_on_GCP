# Cloud SQL PostgreSQL instance with pgvector extension, database, and user

# Cloud SQL PostgreSQL instance resource
resource "google_sql_database_instance" "this" {
  project             = var.project_id
  region              = var.region
  name                = var.instance_name
  database_version    = var.database_version
  deletion_protection = var.deletion_protection

  settings {
    tier            = var.tier
    user_labels     = var.labels
    disk_autoresize = true
    disk_size       = 20
    disk_type       = "PD_SSD"

    # Enable pgvector extension flag in PostgreSQL
    database_flags {
      name  = "cloudsql.enable_pgvector"
      value = "on"
    }

    # IP network configuration
    ip_configuration {
      ipv4_enabled    = var.enable_public_ip
      private_network = var.private_network
    }
  }
}

# PostgreSQL database resource
resource "google_sql_database" "this" {
  project  = var.project_id
  instance = google_sql_database_instance.this.name
  name     = var.database_name
}

# Application database user resource
resource "google_sql_user" "this" {
  project  = var.project_id
  instance = google_sql_database_instance.this.name
  name     = var.user_name
  password = var.user_password
}
