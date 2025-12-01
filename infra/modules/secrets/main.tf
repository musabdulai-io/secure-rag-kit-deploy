# Backend environment variables
resource "google_secret_manager_secret" "backend_env_vars" {
  for_each = var.backend_env_vars

  secret_id = "${var.service_name}-${var.environment}-${each.key}"
  project   = var.project_id

  replication {
    auto {}
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_secret_manager_secret_version" "backend_env_vars" {
  for_each = var.backend_env_vars

  secret      = google_secret_manager_secret.backend_env_vars[each.key].id
  secret_data = each.value
}

# Frontend environment variables
resource "google_secret_manager_secret" "frontend_env_vars" {
  for_each = var.frontend_env_vars

  secret_id = "${var.service_name}-${var.environment}-${each.key}"
  project   = var.project_id

  replication {
    auto {}
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_secret_manager_secret_version" "frontend_env_vars" {
  for_each = var.frontend_env_vars

  secret      = google_secret_manager_secret.frontend_env_vars[each.key].id
  secret_data = each.value
}

# Database connection string (special handling)
resource "google_secret_manager_secret" "db_connection" {
  secret_id = "${var.service_name}-${var.environment}-DATABASE_URL"
  project   = var.project_id

  replication {
    auto {}
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_secret_manager_secret_version" "db_connection" {
  secret      = google_secret_manager_secret.db_connection.id
  secret_data = var.db_connection
}
