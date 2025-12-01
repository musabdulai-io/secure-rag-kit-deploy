variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "service_name" {
  description = "Service name (e.g., 'clianto')"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., 'staging', 'production')"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "backend_service_account_email" {
  description = "Email of the backend service account that needs to invoke Qdrant"
  type        = string
}

variable "clouddeploy_service_account_email" {
  description = "Email of the Cloud Deploy service account for deployments"
  type        = string
}
