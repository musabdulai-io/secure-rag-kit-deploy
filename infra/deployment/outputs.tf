# Staging environment outputs
output "staging_backend_url" {
  description = "URL of the staging backend service"
  value       = local.staging_backend_url
}

output "staging_frontend_url" {
  description = "URL of the staging frontend service"
  value       = local.staging_frontend_url
}

output "staging_database_instance" {
  description = "Staging database instance name"
  value       = module.staging_deployment.database_instance
}

output "staging_qdrant_url" {
  description = "URL of the staging Qdrant service (auto-injected to backend)"
  value       = module.staging_deployment.qdrant_url
}

# COMMENTED: Production not needed for staging-only deployment
# output "production_backend_url" {
#   description = "URL of the production backend service"
#   value       = local.production_backend_url
# }

# output "production_frontend_url" {
#   description = "URL of the production frontend service"
#   value       = local.production_frontend_url
# }

# output "production_database_instance" {
#   description = "Production database instance name"
#   value       = module.production_deployment.database_instance
# }

# output "production_qdrant_url" {
#   description = "URL of the production Qdrant service"
#   value       = module.production_deployment.qdrant_url
# }

output "deployment_summary" {
  description = "Summary of deployed environments"
  value = {
    staging = {
      backend_url  = local.staging_backend_url
      frontend_url = local.staging_frontend_url
      database     = module.staging_deployment.database_instance
      qdrant_url   = module.staging_deployment.qdrant_url
    }
    # COMMENTED: Production not needed
    # production = {
    #   backend_url  = local.production_backend_url
    #   frontend_url = local.production_frontend_url
    #   database     = module.production_deployment.database_instance
    #   qdrant_url   = module.production_deployment.qdrant_url
    # }
  }
}
