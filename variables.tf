variable project_name {
  type        = string
  default     = ""

}


variable region {
  type        = string
  default     = "europe-west1"

}

variable zone {
  type        = string
  default     = "europe-west1-b"

}


variable network {
  type        = string
  default     = "vpc-ladbalancer"

}

variable subnetwork {
  type        = string
  default     = "subnet-ladbalancer"
}

variable subnetwork_ip_range {
  type        = string
  default     = "10.0.0.0/24"
}


variable router_name {
  type        = string
  default     = "my-router"
}

variable router_nat_name {
  type        = string
  default     = "my-router-nat"
}

variable instance_template_name {
  type        = string
  default     = "nginx-instance-templates"
}

variable instance_template_machine_type {
  type        = string
  default     = "e2-small"
}

variable instance_template_source_image {
  type        = string
  default     = "debian-cloud/debian-10"
}

variable group_name {
  type        = string
  default     = "nginx"
}

variable group_base_instance_name {
  type        = string
  default     = "vm"
}


variable autoscaler_max_replicas {
  type        = number
  default     = 5
}

variable group_target_size {
  type        = number
  default     = 2
}

variable autoscaler_name {
  type        = string
  default     = "nginx-autoscaler"
}

variable reserved_ip_name {
  type        = string
  default     = "nginx-static-ip"
}

variable forwarding_rule_name {
  type        = string
  default     = "nginx-forwarding-rule"
}

variable http_proxy_name {
  type        = string
  default     = "nginx-target-http-proxy"
}

variable url_map_name {
  type        = string
  default     = "nginx-url-map"
}

variable backend_service_name {
  type        = string
  default     = "nginx-backend-service"
}

variable health_check_name {
  type        = string
  default     = "nginx-hc"
}

variable google_firewall_name {
  type        = string
  default     = "nginx-allow-hc"
}


variable ssh_user {
  type        = string
  default     = ""
}

variable public_key_path {
    default = ""   ##public key with path
}

variable private_key_path{
    default = ""
}