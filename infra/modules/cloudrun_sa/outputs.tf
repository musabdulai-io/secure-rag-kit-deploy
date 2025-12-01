output "service_account_email" {
  description = "Email of the Cloud Run service account"
  value       = google_service_account.cloudrun_service_account.email
}

output "service_account_id" {
  description = "ID of the Cloud Run service account"
  value       = google_service_account.cloudrun_service_account.id
}
