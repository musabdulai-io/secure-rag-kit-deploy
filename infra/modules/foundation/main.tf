# Foundation module - Enables required APIs and creates shared resources

# Enable required APIs
resource "google_project_service" "apis" {
  for_each = toset(var.required_apis)

  project = var.project_id
  service = each.value

  disable_on_destroy = false
}

# Create CI/CD service account
resource "google_service_account" "cicd_sa" {
  account_id   = "${var.service_name}-cicd-sa"
  display_name = "CI/CD Service Account for ${var.service_name}"
  project      = var.project_id
}

# Grant necessary permissions to CI/CD service account
resource "google_project_iam_member" "cicd_sa_roles" {
  for_each = toset([
    "roles/cloudbuild.builds.editor",
    "roles/clouddeploy.releaser",
    "roles/run.admin",
    "roles/artifactregistry.admin",
    "roles/iam.serviceAccountUser",
    "roles/logging.logWriter",
    "roles/storage.admin"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.cicd_sa.email}"
}

# Give CI/CD service account access to the Terraform state bucket
resource "google_storage_bucket_iam_member" "cicd_state_access" {
  bucket = "${var.project_id}-tf-state"
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.cicd_sa.email}"
}

# Allow Cloud Build service agent to impersonate the CI/CD service account
data "google_project" "project" {
  project_id = var.project_id
}

resource "google_service_account_iam_member" "cloudbuild_impersonate_cicd" {
  service_account_id = google_service_account.cicd_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

# Create Cloud Deploy execution service account
resource "google_service_account" "clouddeploy_execution_sa" {
  account_id   = "${var.service_name}-clouddeploy-sa"
  display_name = "Cloud Deploy Execution SA for ${var.service_name}"
  project      = var.project_id
}

# Grant permissions for Cloud Deploy execution (RENDER, DEPLOY, VERIFY operations)
resource "google_project_iam_member" "clouddeploy_execution_roles" {
  for_each = toset([
    "roles/clouddeploy.jobRunner",        # Cloud Deploy infrastructure (logs, artifacts)
    "roles/run.developer",                 # Create/update Cloud Run services
    "roles/iam.serviceAccountUser",        # Act as Cloud Run service accounts
    "roles/artifactregistry.reader",       # Read images from Artifact Registry (validate during deploy)
    "roles/secretmanager.secretAccessor",  # Read secrets (for verify warmup script)
    "roles/clouddeploy.viewer",            # Describe Cloud Deploy targets (for verify warmup script)
    "roles/cloudsql.client",               # Connect to Cloud SQL instances (for migration verify)
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.clouddeploy_execution_sa.email}"
}

# Create Artifact Registry repository
resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.region
  repository_id = "${var.service_name}-repo"
  description   = "Docker repository for ${var.service_name}"
  format        = "DOCKER"

  depends_on = [google_project_service.apis["artifactregistry.googleapis.com"]]
}
