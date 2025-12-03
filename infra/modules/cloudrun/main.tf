# Backend service
resource "google_cloud_run_v2_service" "backend" {
  name                = "${var.service_name}-${var.environment}-backend"
  location            = var.region
  project             = var.project_id
  deletion_protection = var.deletion_protection

  template {
    annotations = {
      "run.googleapis.com/cloudsql-instances" = var.cloudsql_connection_name
    }
    service_account = var.service_account_email

    # CloudSQL volume for services
    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [var.cloudsql_connection_name]
      }
    }

    containers {
      # image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.service_name}-repo/${var.service_name}-backend:latest"
      image = "gcr.io/google-samples/hello-app:1.0" # Placeholder image

      # Explicit port to match backend PORT=8000
      ports {
        container_port = 8000
      }

      # Environment variables from Secret Manager
      dynamic "env" {
        for_each = var.backend_env_vars
        content {
          name = env.key
          value_source {
            secret_key_ref {
              secret  = "${var.service_name}-${var.environment}-${env.key}"
              version = "latest"
            }
          }
        }
      }

      # Add DATABASE_URL specifically
      env {
        name = "DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = "${var.service_name}-${var.environment}-DATABASE_URL"
            version = "latest"
          }
        }
      }

      # Mount CloudSQL volume
      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }

      resources {
        cpu_idle = true
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
      }

      startup_probe {
        failure_threshold     = 5
        initial_delay_seconds = 30
        timeout_seconds       = 5
        period_seconds        = 10

        http_get {
          path = "/healthcheck"
        }
      }

      liveness_probe {
        failure_threshold     = 3
        initial_delay_seconds = 0
        timeout_seconds       = 3
        period_seconds        = 30

        http_get {
          path = "/healthcheck"
        }
      }
    }

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }
  }

  # Allow Cloud Deploy to update the image and manage traffic
  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
      template[0].labels,
      template[0].annotations["run.googleapis.com/client-name"],
      template[0].annotations["run.googleapis.com/client-version"],
      template[0].annotations["run.googleapis.com/cloudsql-instances"],
      traffic,
    ]
  }
}

# Frontend service
resource "google_cloud_run_v2_service" "frontend" {
  name                = "${var.service_name}-${var.environment}-frontend"
  location            = var.region
  project             = var.project_id
  deletion_protection = var.deletion_protection

  template {
    service_account = var.service_account_email

    containers {
      # image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.service_name}-repo/${var.service_name}-frontend:latest"
      image = "gcr.io/google-samples/hello-app:1.0" # Placeholder image

      # Explicit port to match frontend PORT=3000
      ports {
        container_port = 3000
      }

      # Environment variables from Secret Manager
      dynamic "env" {
        for_each = var.frontend_env_vars
        content {
          name = env.key
          value_source {
            secret_key_ref {
              secret  = "${var.service_name}-${var.environment}-${env.key}"
              version = "latest"
            }
          }
        }
      }

      resources {
        cpu_idle = true
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
      }

      startup_probe {
        failure_threshold     = 3
        initial_delay_seconds = 10
        timeout_seconds       = 3
        period_seconds        = 5

        http_get {
          path = "/"
        }
      }

      liveness_probe {
        failure_threshold     = 3
        initial_delay_seconds = 0
        timeout_seconds       = 3
        period_seconds        = 30

        http_get {
          path = "/"
        }
      }
    }

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }
  }

  # Allow Cloud Deploy to update the image and manage traffic
  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
      template[0].labels,
      template[0].annotations["run.googleapis.com/client-name"],
      template[0].annotations["run.googleapis.com/client-version"],
      template[0].annotations["run.googleapis.com/cloudsql-instances"],
      traffic,
    ]
  }
}

# IAM: Allow public access to both services
resource "google_cloud_run_v2_service_iam_member" "backend_public" {
  name     = google_cloud_run_v2_service.backend.name
  location = google_cloud_run_v2_service.backend.location
  project  = var.project_id
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_v2_service_iam_member" "frontend_public" {
  name     = google_cloud_run_v2_service.frontend.name
  location = google_cloud_run_v2_service.frontend.location
  project  = var.project_id
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# COMMENTED: Stripe setup not needed for this demo
# resource "google_cloud_run_v2_job" "stripe_setup" {
#   name                = "${var.service_name}-${var.environment}-stripe-setup"
#   location            = var.region
#   project             = var.project_id
#   deletion_protection = var.deletion_protection
#
#   template {
#     template {
#       execution_environment = "EXECUTION_ENVIRONMENT_GEN2"
#       service_account       = var.service_account_email
#
#       volumes {
#         name = "cloudsql"
#         cloud_sql_instance {
#           instances = [var.cloudsql_connection_name]
#         }
#       }
#
#       containers {
#         image = "gcr.io/google-samples/hello-app:1.0"
#
#         volume_mounts {
#           name       = "cloudsql"
#           mount_path = "/cloudsql"
#         }
#
#         command = ["/bin/sh"]
#         args    = ["-c", "echo 'Stripe setup placeholder'"]
#
#         dynamic "env" {
#           for_each = var.backend_env_vars
#           content {
#             name = env.key
#             value_source {
#               secret_key_ref {
#                 secret  = "${var.service_name}-${var.environment}-${env.key}"
#                 version = "latest"
#               }
#             }
#           }
#         }
#
#         resources {
#           limits = {
#             cpu    = var.cpu
#             memory = var.memory
#           }
#         }
#       }
#
#       max_retries = 1
#       timeout     = "900s"
#     }
#   }
#
#   lifecycle {
#     ignore_changes = [
#       template[0].template[0].containers[0].image,
#     ]
#   }
# }

# COMMENTED: Stripe workflow service account not needed
# resource "google_service_account" "stripe_setup_sa" {
#   account_id   = "${var.service_name}-${var.environment}-str-sa"
#   display_name = "Service Account for Stripe setup"
#   project      = var.project_id
# }

# COMMENTED: Stripe setup workflow not needed
# resource "google_workflows_workflow" "stripe_setup_workflow" { ... }

# COMMENTED: Stripe workflow IAM roles not needed
# resource "google_project_iam_member" "stripe_run_invoker" { ... }
# resource "google_project_iam_member" "stripe_workflows_invoker" { ... }
# resource "google_project_iam_member" "stripe_run_developer" { ... }
# resource "google_project_iam_member" "stripe_service_account_user" { ... }
# resource "google_project_iam_member" "stripe_logwriter" { ... }
# resource "google_project_iam_member" "stripe_artifact_registry_reader" { ... }
