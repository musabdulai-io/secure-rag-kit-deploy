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
