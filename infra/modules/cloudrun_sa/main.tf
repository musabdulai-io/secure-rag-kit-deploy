resource "google_service_account" "cloudrun_service_account" {
  account_id   = "${var.service_name}-${var.environment}-sa"
  display_name = "Service Account for ${var.service_name} ${var.environment}"
  project      = var.project_id
}

# Grant basic Cloud Run roles
resource "google_project_iam_member" "cloudrun_sa_roles" {
  for_each = toset([
    "roles/run.invoker",
    "roles/logging.logWriter",
    "roles/secretmanager.secretAccessor",
    "roles/iam.serviceAccountTokenCreator",
    "roles/storage.objectAdmin",
    "roles/cloudsql.client",
    # REMOVED: Firebase and Cloud Tasks roles not needed for this demo
    # "roles/cloudtasks.enqueuer",
    # "roles/firebaseauth.admin"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.cloudrun_service_account.email}"
}
