output "backend_secret_ids" {
  description = "Map of backend environment variable names to secret IDs"
  value = {
    for k, v in google_secret_manager_secret.backend_env_vars : k => v.id
  }
}

output "frontend_secret_ids" {
  description = "Map of frontend environment variable names to secret IDs"
  value = {
    for k, v in google_secret_manager_secret.frontend_env_vars : k => v.id
  }
}

output "db_connection_secret_id" {
  description = "Secret ID for database connection string"
  value       = google_secret_manager_secret.db_connection.id
}
