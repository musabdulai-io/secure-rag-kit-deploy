resource "google_sql_database_instance" "main" {
  name             = var.instance_name
  database_version = "POSTGRES_13"
  region           = var.region

  settings {
    tier            = var.instance_tier
    disk_type       = var.disk_type
    disk_autoresize = var.disk_autoresize

    backup_configuration {
      enabled            = var.enable_backups
      start_time         = "02:00" # 2 AM UTC
      binary_log_enabled = false
    }

    ip_configuration {
      ipv4_enabled = true

      authorized_networks {
        name  = "allow-all"
        value = "0.0.0.0/0"
      }
    }

    maintenance_window {
      day          = 6 # Saturday
      hour         = 2 # 2 AM UTC
      update_track = "stable"
    }
  }

  deletion_protection = var.deletion_protection
}

resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.main.name
}

resource "random_password" "db_password" {
  length  = 16
  special = false
}

resource "google_sql_user" "user" {
  name     = var.db_user
  instance = google_sql_database_instance.main.name
  password = random_password.db_password.result
}
