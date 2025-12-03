project_id     = "YOUR_PROJECT_ID"
project_number = "YOUR_PROJECT_NUMBER"
service_name   = "secure-rag-kit"
region         = "us-central1"

staging_env_vars = {
  backend = {
    # OpenAI Configuration (required)
    "OPENAI_API_KEY"             = "sk-YOUR_OPENAI_API_KEY"
    "OPENAI_EMBEDDING_MODEL"     = "text-embedding-3-small"
    "OPENAI_EMBEDDING_DIMENSION" = "1536"

    # RAG Configuration
    "CHUNK_MIN_SIZE"         = "800"
    "CHUNK_MAX_SIZE"         = "2000"
    "CHUNK_OVERLAP"          = "200"
    "SEARCH_TOP_K"           = "10"
    "SEARCH_SCORE_THRESHOLD" = "0.5"

    # Rate Limiting
    "RATE_LIMIT_REQUESTS" = "100"
    "RATE_LIMIT_WINDOW"   = "60"

    # Security
    "MAX_INPUT_LENGTH" = "10000"
    "MAX_FILE_SIZE"    = "10485760"

    # Storage
    "STORAGE_BACKEND" = "gcs"
    # GCS_BUCKET_NAME auto-populated from storage_bucket_name

    # Qdrant - QDRANT_URL is AUTO-INJECTED by deployment_stack module
    # No need to specify it here!
    "QDRANT_COLLECTION" = "documents"

    # Additional allowed origins (auto-joined with frontend URL)
    "ALLOWED_ORIGINS" = ""
  }

  frontend = {
    # Minimal frontend env vars for this demo
    # NEXT_PUBLIC_API_URL is auto-populated
  }

  # Custom domains (optional, uses Cloud Run URL if not set)
  # backend_custom_domain  = "api.yourdomain.com"
  # frontend_custom_domain = "yourdomain.com"
}

# COMMENTED: Production not needed for staging-only deployment
# production_env_vars = {
#   backend = {
#     ...
#   }
#   frontend = {
#     ...
#   }
# }
