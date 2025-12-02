# Qdrant Vector Database Module
# Deploys Qdrant as a Cloud Run service with ephemeral storage
# Note: For a demo, ephemeral storage is acceptable. Documents are stored in PostgreSQL
# and can be re-indexed on startup. For production, consider GCE VM with persistent disk.

# Cloud Run service for Qdrant
resource "google_cloud_run_service" "qdrant" {
  name     = "${var.service_name}-${var.environment}-qdrant"
  location = var.region
  project  = var.project_id

  template {
    spec {
      containers {
        image = "qdrant/qdrant:latest"

        ports {
          name           = "http1"
          container_port = 6333
        }

        resources {
          limits = {
            cpu    = "2"
            memory = "4Gi"
          }
        }

        # Environment variables for Qdrant configuration
        env {
          name  = "QDRANT__SERVICE__GRPC_PORT"
          value = "6334"
        }

        env {
          name  = "QDRANT__STORAGE__STORAGE_PATH"
          value = "/qdrant/storage"
        }

        # Ephemeral storage - acceptable for demo since documents are in PostgreSQL
        # Can be re-indexed on startup if needed
      }

      # Service account for Qdrant
      service_account_name = google_service_account.qdrant_sa.email

      # Container concurrency and scaling
      container_concurrency = 80
      timeout_seconds       = 300
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"         = "1"                                         # Keep 1 instance always running
        "autoscaling.knative.dev/maxScale"         = var.environment == "production" ? "3" : "1" # Scale up in production
        "run.googleapis.com/cpu-throttling"        = "false"                                     # Disable CPU throttling (always-on)
        "run.googleapis.com/startup-cpu-boost"     = "true"                                      # Boost CPU during startup
        "run.googleapis.com/execution-environment" = "gen2"                                      # Use second generation execution environment
      }
    }
  }

  metadata {
    annotations = {
      # Changed from "internal" to "all" - Cloud Run without VPC egress can't reach internal services
      # Security is maintained via IAM: only backend SA has roles/run.invoker on Qdrant
      "run.googleapis.com/ingress" = "all"
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true
}

# Service account for Qdrant Cloud Run service
resource "google_service_account" "qdrant_sa" {
  account_id   = "${var.service_name}-${var.environment}-qdrant"
  display_name = "Qdrant service account for ${var.service_name} ${var.environment}"
  project      = var.project_id
}

# IAM policy to allow backend service to invoke Qdrant
resource "google_cloud_run_service_iam_member" "backend_qdrant_invoker" {
  service  = google_cloud_run_service.qdrant.name
  location = google_cloud_run_service.qdrant.location
  role     = "roles/run.invoker"
  member   = "serviceAccount:${var.backend_service_account_email}"
}

# Allow Cloud Build to deploy Qdrant service (for updates)
resource "google_cloud_run_service_iam_member" "clouddeploy_qdrant_developer" {
  service  = google_cloud_run_service.qdrant.name
  location = google_cloud_run_service.qdrant.location
  role     = "roles/run.developer"
  member   = "serviceAccount:${var.clouddeploy_service_account_email}"
}
