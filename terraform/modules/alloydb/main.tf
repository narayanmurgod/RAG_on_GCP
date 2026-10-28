# AlloyDB for PostgreSQL cluster and primary instance resources

locals {
  # Resolved cluster display name
  display_name = var.display_name != "" ? var.display_name : var.cluster_id
}

# AlloyDB cluster resource inside private VPC
resource "google_alloydb_cluster" "this" {
  project      = var.project_id
  location     = var.region
  cluster_id   = var.cluster_id
  display_name = local.display_name
  labels       = var.labels

  network_config {
    network = var.network_id
  }

  initial_user {
    password = var.initial_user_password
  }
}

# AlloyDB primary instance resource for read/write queries
resource "google_alloydb_instance" "primary" {
  cluster       = google_alloydb_cluster.this.name
  instance_id   = var.instance_id
  instance_type = "PRIMARY"
  labels        = var.labels

  machine_config {
    cpu_count = var.cpu_count
  }

  database_flags = var.database_flags
}
