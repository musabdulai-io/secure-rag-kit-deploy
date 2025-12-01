output "cicd_service_account_email" {
  description = "Email of the CI/CD service account"
  value       = module.foundation.cicd_service_account_email
}

output "clouddeploy_execution_service_account_email" {
  description = "Email of the Cloud Deploy execution service account"
  value       = module.foundation.clouddeploy_execution_service_account_email
}

output "cicd_service_account_id" {
  description = "Resource ID of the CI/CD service account"
  value       = module.foundation.cicd_service_account_id
}

output "docker_repository" {
  description = "Artifact Registry Docker repository"
  value       = module.foundation.docker_repository
}

output "docker_repository_location" {
  description = "Location of the Docker repository"
  value       = module.foundation.docker_repository_location
}

# Backend pipeline outputs
output "backend_pipeline_id" {
  description = "Backend Cloud Deploy pipeline ID"
  value       = google_clouddeploy_delivery_pipeline.backend_pipeline.id
}

output "backend_pipeline_name" {
  description = "Backend Cloud Deploy pipeline name"
  value       = google_clouddeploy_delivery_pipeline.backend_pipeline.name
}

# Frontend pipeline outputs
output "frontend_pipeline_id" {
  description = "Frontend Cloud Deploy pipeline ID"
  value       = google_clouddeploy_delivery_pipeline.frontend_pipeline.id
}

output "frontend_pipeline_name" {
  description = "Frontend Cloud Deploy pipeline name"
  value       = google_clouddeploy_delivery_pipeline.frontend_pipeline.name
}

# Backend deployment targets (staging only)
output "staging_backend_target_id" {
  description = "Staging backend target ID"
  value       = google_clouddeploy_target.staging_backend.id
}

output "staging_backend_target_name" {
  description = "Staging backend target name"
  value       = google_clouddeploy_target.staging_backend.name
}

# COMMENTED: Production not needed for staging-only deployment
# output "production_backend_target_id" {
#   description = "Production backend target ID"
#   value       = google_clouddeploy_target.production_backend.id
# }

# output "production_backend_target_name" {
#   description = "Production backend target name"
#   value       = google_clouddeploy_target.production_backend.name
# }

# Frontend deployment targets (staging only)
output "staging_frontend_target_id" {
  description = "Staging frontend target ID"
  value       = google_clouddeploy_target.staging_frontend.id
}

output "staging_frontend_target_name" {
  description = "Staging frontend target name"
  value       = google_clouddeploy_target.staging_frontend.name
}

# COMMENTED: Production not needed for staging-only deployment
# output "production_frontend_target_id" {
#   description = "Production frontend target ID"
#   value       = google_clouddeploy_target.production_frontend.id
# }

# output "production_frontend_target_name" {
#   description = "Production frontend target name"
#   value       = google_clouddeploy_target.production_frontend.name
# }
