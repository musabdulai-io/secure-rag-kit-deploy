output "cicd_service_account_email" {
  description = "Email of the CI/CD service account"
  value       = google_service_account.cicd_sa.email
}

output "cicd_service_account_id" {
  description = "Resource ID of the CI/CD service account"
  value       = google_service_account.cicd_sa.id
}

output "clouddeploy_execution_service_account_email" {
  description = "Email of the Cloud Deploy execution service account"
  value       = google_service_account.clouddeploy_execution_sa.email
}

output "docker_repository" {
  description = "Artifact Registry Docker repository"
  value       = google_artifact_registry_repository.docker_repo.name
}

output "docker_repository_location" {
  description = "Location of the Docker repository"
  value       = google_artifact_registry_repository.docker_repo.location
}

output "enabled_apis" {
  description = "List of enabled Google APIs"
  value       = [for api in google_project_service.apis : api.service]
}
