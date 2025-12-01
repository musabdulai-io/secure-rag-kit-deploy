terraform {
  required_version = ">= 1.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }

  backend "gcs" {
    # Set during init:
    # terraform init -backend-config="bucket=PROJECT_ID-tf-state" -backend-config="prefix=terraform/pipeline"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Use the foundation module to set up project-wide resources
module "foundation" {
  source       = "../modules/foundation"
  project_id   = var.project_id
  service_name = var.service_name
  region       = var.region
}

# Wait for APIs to fully enable and service agents to be created
resource "time_sleep" "wait_for_apis" {
  depends_on      = [module.foundation]
  create_duration = "60s"
}

# Backend targets with consistent naming: service-env-component
resource "google_clouddeploy_target" "staging_backend" {
  name     = "${var.service_name}-staging-backend"
  location = var.region
  run {
    location = "projects/${var.project_id}/locations/${var.region}"
  }
  execution_configs {
    usages          = ["RENDER", "DEPLOY", "VERIFY"]
    service_account = module.foundation.clouddeploy_execution_service_account_email
  }
  annotations = {
    environment = "staging"
  }
  require_approval = false
  depends_on       = [time_sleep.wait_for_apis]
}

# COMMENTED: Production not needed for staging-only deployment
# resource "google_clouddeploy_target" "production_backend" {
#   name     = "${var.service_name}-production-backend"
#   location = var.region
#   run {
#     location = "projects/${var.project_id}/locations/${var.region}"
#   }
#   execution_configs {
#     usages          = ["RENDER", "DEPLOY", "VERIFY"]
#     service_account = module.foundation.clouddeploy_execution_service_account_email
#   }
#   annotations = {
#     environment = "production"
#   }
#   require_approval = true
#   depends_on       = [time_sleep.wait_for_apis]
# }

# Frontend targets with consistent naming: service-env-component
resource "google_clouddeploy_target" "staging_frontend" {
  name     = "${var.service_name}-staging-frontend"
  location = var.region
  run {
    location = "projects/${var.project_id}/locations/${var.region}"
  }
  execution_configs {
    usages          = ["RENDER", "DEPLOY", "VERIFY"]
    service_account = module.foundation.clouddeploy_execution_service_account_email
  }
  annotations = {
    environment = "staging"
  }
  require_approval = false
  depends_on       = [time_sleep.wait_for_apis]
}

# COMMENTED: Production not needed for staging-only deployment
# resource "google_clouddeploy_target" "production_frontend" {
#   name     = "${var.service_name}-production-frontend"
#   location = var.region
#   run {
#     location = "projects/${var.project_id}/locations/${var.region}"
#   }
#   execution_configs {
#     usages          = ["RENDER", "DEPLOY", "VERIFY"]
#     service_account = module.foundation.clouddeploy_execution_service_account_email
#   }
#   annotations = {
#     environment = "production"
#   }
#   require_approval = true
#   depends_on       = [time_sleep.wait_for_apis]
# }

# Backend delivery pipeline (staging only)
resource "google_clouddeploy_delivery_pipeline" "backend_pipeline" {
  name        = "${var.service_name}-backend-pipeline"
  location    = var.region
  description = "Backend delivery pipeline for ${var.service_name}"

  serial_pipeline {
    stages {
      profiles  = ["staging-backend"]
      target_id = google_clouddeploy_target.staging_backend.name
      strategy {
        standard {
          verify = true
        }
      }
    }
    # COMMENTED: Production stage not needed for staging-only deployment
    # stages {
    #   profiles  = ["production-backend"]
    #   target_id = google_clouddeploy_target.production_backend.name
    #   strategy {
    #     standard {
    #       verify = true
    #     }
    #   }
    # }
  }

  depends_on = [time_sleep.wait_for_apis]
}

# Frontend delivery pipeline (staging only)
resource "google_clouddeploy_delivery_pipeline" "frontend_pipeline" {
  name        = "${var.service_name}-frontend-pipeline"
  location    = var.region
  description = "Frontend delivery pipeline for ${var.service_name}"

  serial_pipeline {
    stages {
      profiles  = ["staging-frontend"]
      target_id = google_clouddeploy_target.staging_frontend.name
      strategy {
        standard {
          verify = false
        }
      }
    }
    # COMMENTED: Production stage not needed for staging-only deployment
    # stages {
    #   profiles  = ["production-frontend"]
    #   target_id = google_clouddeploy_target.production_frontend.name
    #   deploy_parameters {
    #     values = {
    #       "customTarget/url_map"       = var.frontend_prod_url_map
    #       "customTarget/cdn_host"      = var.frontend_production_cdn_host
    #       "customTarget/project_id"    = var.project_id
    #       "customTarget/service_name"  = var.service_name
    #     }
    #   }
    #   strategy {
    #     standard {
    #       verify = false
    #     }
    #   }
    # }
  }

  depends_on = [time_sleep.wait_for_apis]
}

# Cloud Build trigger - watches PRIVATE deploy repo
resource "google_cloudbuild_trigger" "main_trigger" {
  name            = "${var.service_name}-pipeline-trigger"
  description     = "${var.service_name} pipeline trigger"
  location        = var.region
  service_account = module.foundation.cicd_service_account_id

  github {
    owner = var.github_owner
    name  = var.github_deploy_repo  # PRIVATE repo: "secure-rag-kit-deploy"
    push {
      branch = "^main$"
    }
  }

  filename           = "cloudbuild.yaml"  # Lives directly in private repo
  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"

  substitutions = {
    _SERVICE_NAME = var.service_name
    _REGION       = var.region
    _GITHUB_OWNER = var.github_owner
    _APP_REPO     = var.github_app_repo  # PUBLIC repo name for cloning
  }

  depends_on = [time_sleep.wait_for_apis]
}
