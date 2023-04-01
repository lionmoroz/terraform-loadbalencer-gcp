resource "google_compute_network" "vpc" {
  name                    = "${var.network}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.subnetwork}"
  network       = google_compute_network.vpc.self_link
  ip_cidr_range = "${var.subnetwork_ip_range}"
  region        = "${var.region}"
}


resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.network}-allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["${var.network}-allow-ssh"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "icmp" {
  name    = "${var.network}-firewall-icmp"
  network = "${google_compute_network.vpc.name}"

  allow {
    protocol = "icmp"
  }

  source_ranges = ["${google_compute_subnetwork.subnet.ip_cidr_range}"]
}

resource "google_compute_router" "nginx" {
  name    = "${var.router_name}"
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.vpc.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nginx" {
  name                               = "${var.router_nat_name}"
  router                             = google_compute_router.nginx.name
  region                             = google_compute_router.nginx.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}



resource "google_compute_instance_template" "web_instance_template" {
  name = "${var.instance_template_name}"
  machine_type = "${var.instance_template_machine_type}"
  tags         = ["allow-health-check", "${var.network}-allow-ssh"]

  disk {
    source_image = "${var.instance_template_source_image}"
    auto_delete  = true
    boot         = true
  }

    // networking
  network_interface {
    network = google_compute_network.vpc.self_link
    subnetwork = google_compute_subnetwork.subnet.self_link
    }

  lifecycle {
    create_before_destroy = true
  }

  metadata = {
    ssh-keys  = "${var.ssh_user}:${file("${var.public_key_path}")}"

  }

  // Startup script to install NGINX
  metadata_startup_script = <<-SCRIPT
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y nginx
    INSTANCE_NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/name")
    echo "Hello, World from instance: $INSTANCE_NAME!" > /var/www/html/index.html
    sudo service nginx start
    sudo systemctl enable nginx
    SCRIPT
}


# MIG
resource "google_compute_instance_group_manager" "nginx" {
  name     = "${var.group_name}"
  zone     = "${var.zone}"
  named_port {
    name = "http"
    port = 80
  }
  version {
    instance_template = google_compute_instance_template.web_instance_template.id
    name              = "primary"
  }
  base_instance_name = "${var.group_base_instance_name}"
  target_size        = var.group_target_size
}

resource "google_compute_autoscaler" "nginx" {
  name   = "${var.autoscaler_name}"
  zone   = "${var.zone}"
  target = google_compute_instance_group_manager.nginx.id

  autoscaling_policy {
    max_replicas    = var.autoscaler_max_replicas
    min_replicas    = var.group_target_size
    cooldown_period = 60

    cpu_utilization {
      target = 0.3
    }
  }
}


# reserved IP address
resource "google_compute_global_address" "nginx" {
  name     = "${var.reserved_ip_name}"
}

# forwarding rule
resource "google_compute_global_forwarding_rule" "nginx" {
  name                  = "${var.forwarding_rule_name}"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.nginx.id
  ip_address            = google_compute_global_address.nginx.id
}

# http proxy
resource "google_compute_target_http_proxy" "nginx" {
  name     = "${var.http_proxy_name}"
  url_map  = google_compute_url_map.nginx.id
}

# url map
resource "google_compute_url_map" "nginx" {
  name            = "${var.url_map_name}"
  default_service = google_compute_backend_service.nginx.id
}

# backend service with custom request and response headers
resource "google_compute_backend_service" "nginx" {
  name                    = "${var.backend_service_name}"
  protocol                = "HTTP"
  port_name               = "http"
  load_balancing_scheme   = "EXTERNAL"
  timeout_sec             = 10
  health_checks           = [google_compute_health_check.nginx.id]
  backend {
    group           = google_compute_instance_group_manager.nginx.instance_group
  }
}

# health check
resource "google_compute_health_check" "nginx" {
  name     = "${var.health_check_name}"
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}


# allow access from health check ranges
resource "google_compute_firewall" "nginx" {
  name          = "${var.google_firewall_name}"
  direction     = "INGRESS"
  network       = google_compute_network.vpc.id
  source_ranges = ["130.211.0.0/22","35.191.0.0/16"]
  allow {
    protocol = "tcp"
  }
  target_tags = ["allow-health-check"]
}
