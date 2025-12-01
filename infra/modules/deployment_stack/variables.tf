variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "service_name" {
  description = "Base name for all resources"
  type        = string

  validation {
    condition     = length(var.service_name) <= 35
    error_message = "The service_name must be 35 characters or less to ensure valid Cloud Run URLs don't exceed the 63 character limit."
  }
}

variable "environment" {
  description = "Environment name (staging or production)"
  type        = string

  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "The environment must be either 'staging' or 'production'."
  }
}

variable "region" {
  description = "Google Cloud region"
  type        = string
}

variable "db_instance_tier" {
  description = "Cloud SQL machine tier"
  type        = string
}

variable "db_disk_type" {
  description = "Cloud SQL disk type"
  type        = string
  default     = "PD_SSD"
}

variable "db_disk_autoresize" {
  description = "Whether Cloud SQL disk autoresize is enabled"
  type        = bool
  default     = true
}

variable "enable_backups" {
  description = "Whether to enable database backups"
  type        = bool
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
}


variable "min_instances" {
  description = "Minimum number of Cloud Run instances"
  type        = number
}

variable "max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
}

variable "cpu" {
  description = "CPU allocation for Cloud Run services"
  type        = string
}

variable "memory" {
  description = "Memory allocation for Cloud Run services"
  type        = string
}

variable "backend_env_vars" {
  description = "Map of backend environment variable names to values (QDRANT_URL is auto-injected)"
  type        = map(string)
  default     = {}
}

variable "frontend_env_vars" {
  description = "Map of frontend environment variable names to values"
  type        = map(string)
  default     = {}
}

variable "storage_bucket_name" {
  description = "Name of the storage bucket"
  type        = string
}

# REMOVED: Cloud Tasks not needed for this demo
# variable "cloud_tasks_queue_name" {
#   description = "Name of the Cloud Tasks queue"
#   type        = string
# }

variable "clouddeploy_service_account_email" {
  description = "Email of the Cloud Deploy service account for Qdrant IAM permissions"
  type        = string
}
