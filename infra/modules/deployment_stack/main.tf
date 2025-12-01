# Auto-inject QDRANT_URL into backend env vars
# This eliminates the manual step of getting Qdrant URL and adding it to tfvars
locals {
  backend_env_vars_with_qdrant = merge(
    var.backend_env_vars,
    {
      "QDRANT_URL" = module.qdrant.qdrant_url
    }
  )
}

# Database
module "database" {
  source = "../database"

  project_id    = var.project_id
  instance_name = "${var.service_name}-${var.environment}"
  region        = var.region

  # Environment-specific settings
  instance_tier       = var.db_instance_tier
  disk_type           = var.db_disk_type
  disk_autoresize     = var.db_disk_autoresize
  enable_backups      = var.enable_backups
  deletion_protection = var.deletion_protection
}

# CloudRun service account
module "cloudrun_sa" {
  source = "../cloudrun_sa"

  project_id   = var.project_id
  service_name = var.service_name
  environment  = var.environment

  depends_on = [module.database]
}

# Qdrant vector database
module "qdrant" {
  source = "../qdrant"

  project_id                        = var.project_id
  service_name                      = var.service_name
  environment                       = var.environment
  region                            = var.region
  backend_service_account_email     = module.cloudrun_sa.service_account_email
  clouddeploy_service_account_email = var.clouddeploy_service_account_email

  depends_on = [module.cloudrun_sa]
}

# Secrets management - use env vars with auto-injected QDRANT_URL
module "secrets" {
  source = "../secrets"

  project_id   = var.project_id
  service_name = var.service_name
  environment  = var.environment

  # Database connection from database module
  db_connection = module.database.connection_string

  # Application environment variables - with auto-injected QDRANT_URL
  backend_env_vars  = local.backend_env_vars_with_qdrant
  frontend_env_vars = var.frontend_env_vars

  depends_on = [module.cloudrun_sa, module.database, module.qdrant]
}

# Cloud Run services - use env vars with auto-injected QDRANT_URL
module "cloudrun" {
  source = "../cloudrun"

  project_id   = var.project_id
  service_name = var.service_name
  environment  = var.environment
  region       = var.region

  # Pass Cloud SQL connection name
  cloudsql_connection_name = module.database.connection_name

  # Pass service account email
  service_account_email = module.cloudrun_sa.service_account_email

  # Pass environment variable maps - with auto-injected QDRANT_URL
  backend_env_vars  = local.backend_env_vars_with_qdrant
  frontend_env_vars = var.frontend_env_vars

  # Environment-specific settings
  min_instances       = var.min_instances
  max_instances       = var.max_instances
  cpu                 = var.cpu
  memory              = var.memory
  deletion_protection = var.deletion_protection

  # REMOVED: Cloud Tasks dependency not needed
  depends_on = [module.secrets, module.storage_bucket]
}

# Storage bucket
module "storage_bucket" {
  source = "../storage_bucket"

  project_id          = var.project_id
  region              = var.region
  bucket_name         = var.storage_bucket_name
  deletion_protection = var.deletion_protection
}

# REMOVED: Cloud Tasks not needed for this demo
# module "cloud_tasks_queue" {
#   source = "../cloud_tasks_queue"
#
#   project_id = var.project_id
#   region     = var.region
#   queue_name = var.cloud_tasks_queue_name
# }
