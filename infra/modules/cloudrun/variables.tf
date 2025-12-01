variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "service_name" {
  description = "Service name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (staging or production)"
  type        = string
}

variable "region" {
  description = "Region for Cloud Run services"
  type        = string
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 10
}

variable "cpu" {
  description = "CPU allocation for Cloud Run services"
  type        = string
  default     = "1"
}

variable "memory" {
  description = "Memory allocation for Cloud Run services"
  type        = string
  default     = "512Mi"
}

variable "cloudsql_connection_name" {
  type        = string
  description = "Cloud SQL instance connection name (PROJECT:REGION:INSTANCE) to mount into Cloud Run"
}

variable "service_account_email" {
  description = "Email of service account to use for Cloud Run services"
  type        = string
}


variable "deletion_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
  default     = true
}

variable "backend_env_vars" {
  description = "Map of backend environment variables"
  type        = map(string)
  default     = {}
}

variable "frontend_env_vars" {
  description = "Map of frontend environment variables"
  type        = map(string)
  default     = {}
}
