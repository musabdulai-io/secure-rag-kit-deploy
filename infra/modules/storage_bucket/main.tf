resource "google_storage_bucket" "main" {
  name     = var.bucket_name
  project  = var.project_id
  location = var.region

  uniform_bucket_level_access = true
  force_destroy               = !var.deletion_protection

  versioning {
    enabled = var.versioning_enabled
  }
}