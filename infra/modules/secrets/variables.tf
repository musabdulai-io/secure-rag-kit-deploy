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

variable "db_connection" {
  description = "Database connection string"
  type        = string
  sensitive   = true
}

variable "backend_env_vars" {
  description = "Map of backend environment variable names to values"
  type        = map(string)
  sensitive   = false # false to allow for_each
  default     = {}
}

variable "frontend_env_vars" {
  description = "Map of frontend environment variable names to values"
  type        = map(string)
  sensitive   = false # false to allow for_each
  default     = {}
}
