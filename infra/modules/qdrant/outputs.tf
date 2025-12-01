output "qdrant_url" {
  description = "Qdrant service URL (Cloud Run endpoint)"
  value       = google_cloud_run_service.qdrant.status[0].url
}

output "qdrant_service_name" {
  description = "Qdrant Cloud Run service name"
  value       = google_cloud_run_service.qdrant.name
}

output "qdrant_service_account_email" {
  description = "Service account email for Qdrant"
  value       = google_service_account.qdrant_sa.email
}
