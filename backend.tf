terraform{
    backend "gcs" {
      bucket = "terraform-state-docker"
      prefix  = "terraform_loadbalancer"
    }
}