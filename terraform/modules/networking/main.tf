# Custom VPC network, subnets, Serverless VPC Access connector, and Cloud NAT

# Custom VPC network resource
resource "google_compute_network" "this" {
  project                 = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = false
}

# Application subnet resource with Private Google Access
resource "google_compute_subnetwork" "app" {
  project                  = var.project_id
  name                     = "${var.network_name}-app-subnet"
  ip_cidr_range            = var.app_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.this.id
  private_ip_google_access = true
}

# Serverless VPC Access connector resource for Cloud Run private egress
resource "google_vpc_access_connector" "this" {
  project       = var.project_id
  name          = var.connector_name
  region        = var.region
  network       = google_compute_network.this.name
  ip_cidr_range = var.connector_cidr
  min_instances = var.min_instances
  max_instances = var.max_instances

  depends_on = [google_compute_subnetwork.app]
}

# Cloud Router resource for managed NAT egress
resource "google_compute_router" "router" {
  count   = var.enable_nat_gateway ? 1 : 0
  project = var.project_id
  name    = "${var.network_name}-router"
  region  = var.region
  network = google_compute_network.this.id
}

# Cloud NAT resource providing outbound internet access without external IPs
resource "google_compute_router_nat" "nat" {
  count                              = var.enable_nat_gateway ? 1 : 0
  project                            = var.project_id
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.router[0].name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
