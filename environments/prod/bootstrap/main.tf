resource "google_storage_bucket" "tf_state" {
  name          = "${var.project_id}-terraform-state"
  location      = var.state_bucket_location
  force_destroy = false
  project       = var.project_id

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true
}