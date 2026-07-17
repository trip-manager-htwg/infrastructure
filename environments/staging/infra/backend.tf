terraform {
  backend "gcs" {
    bucket = "staging-demo-502317-terraform-state"
    prefix = "terraform/state"
  }
}