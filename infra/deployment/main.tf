terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }
  backend "gcs" {}
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Reference pipeline resources
data "terraform_remote_state" "pipeline" {
  backend = "gcs"
  config = {
    bucket = "${var.project_id}-tf-state"
    prefix = "terraform/pipeline"
  }
}

# Calculate URLs for staging environment
locals {
  staging_backend_url  = "https://${var.service_name}-staging-backend-${var.project_number}.${var.region}.run.app"
  staging_frontend_url = "https://${var.service_name}-staging-frontend-${var.project_number}.${var.region}.run.app"

  # COMMENTED: Production URLs not needed for staging-only deployment
  # production_backend_url  = "https://${var.service_name}-production-backend-${var.project_number}.${var.region}.run.app"
  # production_frontend_url = "https://${var.service_name}-production-frontend-${var.project_number}.${var.region}.run.app"

  # Calculate resource names (to avoid circular dependencies)
  staging_storage_bucket_name = "${var.service_name}-staging-storage"
  # REMOVED: Cloud Tasks not needed for this demo
  # staging_cloud_tasks_queue_name = "${var.service_name}-staging-queue"

  # COMMENTED: Production resource names not needed
  # production_storage_bucket_name    = "${var.service_name}-production-storage"
  # production_cloud_tasks_queue_name = "${var.service_name}-production-queue"

  # Common base values
  base_backend_common = {
    "SERVICE_NAME"   = var.service_name
    "GCP_PROJECT_ID" = var.project_id
    "DEBUG"          = "False"
    "ENVIRONMENT"    = "staging"
  }

  # REMOVED: Firebase-related frontend vars not needed
  base_frontend_common = {
    "NEXT_PUBLIC_SERVICE_NAME" = var.service_name
  }

  staging_frontend_env_vars = merge(
    local.base_frontend_common,
    var.staging_env_vars.frontend,
    {
      "NEXT_PUBLIC_API_URL" = local.staging_backend_url
    }
  )
}

# Staging deployment
module "staging_deployment" {
  source = "../modules/deployment_stack"

  project_id   = var.project_id
  service_name = var.service_name
  environment  = "staging"
  region       = var.region

  # Cloud Deploy service account for Qdrant IAM
  clouddeploy_service_account_email = data.terraform_remote_state.pipeline.outputs.clouddeploy_execution_service_account_email

  # Staging-specific infrastructure settings
  db_instance_tier    = "db-f1-micro"
  db_disk_type        = "PD_HDD"
  db_disk_autoresize  = false
  enable_backups      = false
  deletion_protection = false
  min_instances       = 0
  max_instances       = 1
  cpu                 = "1"
  memory              = "512Mi"

  # Resource names
  storage_bucket_name = local.staging_storage_bucket_name
  # REMOVED: Cloud Tasks not needed
  # cloud_tasks_queue_name = local.staging_cloud_tasks_queue_name

  backend_env_vars = merge(
    local.base_backend_common,
    var.staging_env_vars.backend,
    {
      "ALLOWED_ORIGINS" = join(",", compact([local.staging_frontend_url, lookup(var.staging_env_vars.backend, "ALLOWED_ORIGINS", "")]))
      "FRONTEND_URL"    = local.staging_frontend_url
      "API_BASE_URL"    = local.staging_backend_url
      "STORAGE_BUCKET"  = local.staging_storage_bucket_name
      # REMOVED: Cloud Tasks not needed
      # "CLOUD_TASKS_LOCATION"   = var.region
      # "CLOUD_TASKS_QUEUE_NAME" = local.staging_cloud_tasks_queue_name
      # NOTE: QDRANT_URL is AUTO-INJECTED by deployment_stack module - no manual step needed!
    }
  )

  frontend_env_vars = local.staging_frontend_env_vars
}

# COMMENTED: Production deployment not needed for staging-only deployment
# module "production_deployment" {
#   source = "../modules/deployment_stack"
#
#   project_id   = var.project_id
#   service_name = var.service_name
#   environment  = "production"
#   region       = var.region
#
#   clouddeploy_service_account_email = data.terraform_remote_state.pipeline.outputs.clouddeploy_execution_service_account_email
#
#   db_instance_tier    = "db-f1-micro"
#   enable_backups      = true
#   deletion_protection = true
#   min_instances       = 0
#   max_instances       = 2
#   cpu                 = "1"
#   memory              = "512Mi"
#
#   storage_bucket_name = local.production_storage_bucket_name
#
#   backend_env_vars = merge(
#     local.base_backend_common,
#     var.production_env_vars.backend,
#     {
#       "ALLOWED_ORIGINS" = join(",", compact([local.production_frontend_url, lookup(var.production_env_vars.backend, "ALLOWED_ORIGINS", "")]))
#       "FRONTEND_URL"    = local.production_frontend_url
#       "API_BASE_URL"    = local.production_backend_url
#       "STORAGE_BUCKET"  = local.production_storage_bucket_name
#     }
#   )
#
#   frontend_env_vars = local.production_frontend_env_vars
# }
