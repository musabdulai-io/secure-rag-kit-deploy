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

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "github_deploy_repo" {
  description = "GitHub PRIVATE deploy repository name (contains CI/CD and infra)"
  type        = string
  default     = "secure-rag-kit-deploy"
}

variable "github_app_repo" {
  description = "GitHub PUBLIC app repository name (contains app code)"
  type        = string
  default     = "secure-rag-kit"
}

# COMMENTED: Production CDN not needed for staging-only deployment
# variable "frontend_prod_url_map" {
#   description = "URL map name for production frontend Cloud CDN"
#   type        = string
# }

# variable "frontend_production_cdn_host" {
#   description = "CDN hostname for production frontend (e.g., example.com)"
#   type        = string
# }
