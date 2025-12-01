
output "database_instance" {
  description = "Database instance name"
  value       = module.database.instance_name
}

output "backend_service_account_email" {
  description = "Backend service account email"
  value       = module.cloudrun_sa.service_account_email
}

output "qdrant_url" {
  description = "Qdrant service URL (auto-injected to backend)"
  value       = module.qdrant.qdrant_url
}

output "qdrant_service_name" {
  description = "Qdrant Cloud Run service name"
  value       = module.qdrant.qdrant_service_name
}
