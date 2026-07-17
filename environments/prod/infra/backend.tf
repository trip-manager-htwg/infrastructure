terraform {
  backend "gcs" {
    bucket = "ornate-reef-501614-a1-terraform-state"
    prefix = "terraform/state"
  }
}
