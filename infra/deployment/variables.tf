variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "project_number" {
  description = "Google Cloud Project Number (for generating URLs)"
  type        = string
}

variable "service_name" {
  description = "Base name for all resources"
  type        = string
  default     = "secure-rag-kit"
}

variable "region" {
  description = "Google Cloud region"
  type        = string
  default     = "us-central1"
}

variable "staging_env_vars" {
  description = <<-EOT
    Staging environment variables grouped by service.

    Notes:
    - Backend map contains API keys, configuration, etc.
    - Frontend map should contain client-only overrides and NEXT_PUBLIC_* flags.
    - QDRANT_URL is auto-injected by deployment_stack module.
    - Use backend_custom_domain/frontend_custom_domain for custom URLs (optional).
  EOT
  type = object({
    backend                = map(string)
    frontend               = map(string)
    backend_custom_domain  = optional(string, "")
    frontend_custom_domain = optional(string, "")
  })
  nullable = false
}

# variable "production_env_vars" {
#   description = <<-EOT
#     Production environment variables grouped by service.
#   EOT
#   type = object({
#     backend                = map(string)
#     frontend               = map(string)
#     backend_custom_domain  = optional(string, "")
#     frontend_custom_domain = optional(string, "")
#   })
#   nullable = false
# }
