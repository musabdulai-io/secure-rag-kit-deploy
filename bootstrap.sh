#!/usr/bin/env bash
# bootstrap.sh - Creates Terraform state bucket only

set -euo pipefail

# Default values
PROJECT_ID=""
REGION="us-central1"
BUCKET_SUFFIX="tf-state"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  # Handle both --key=value and --key value formats
  if [[ $key == *"="* ]]; then
    # Format: --key=value
    value=${key#*=}
    key=${key%%=*}

    case $key in
      --project-id)
        PROJECT_ID="$value"
        ;;
      --region)
        REGION="$value"
        ;;
      --bucket-suffix)
        BUCKET_SUFFIX="$value"
        ;;
      *)
        echo "Unknown option: $key"
        exit 1
        ;;
    esac
    shift 1
  else
    # Format: --key value
    case $key in
      --project-id)
        PROJECT_ID="$2"
        shift 2
        ;;
      --region)
        REGION="$2"
        shift 2
        ;;
      --bucket-suffix)
        BUCKET_SUFFIX="$2"
        shift 2
        ;;
      *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
  fi
done

# Validate required parameters
if [[ -z "$PROJECT_ID" ]]; then
  echo "Error: --project-id is required"
  echo "Usage: ./bootstrap.sh --project-id=my-project [--region=us-central1] [--bucket-suffix=tf-state]"
  exit 1
fi

BUCKET_NAME="${PROJECT_ID}-${BUCKET_SUFFIX}"

echo "Creating Terraform state bucket: $BUCKET_NAME in $REGION"

# Check if bucket already exists
if gsutil ls -p $PROJECT_ID gs://$BUCKET_NAME &>/dev/null; then
  echo "Bucket $BUCKET_NAME already exists"
else
  # Create bucket with explicit project and region
  gsutil mb -p $PROJECT_ID -l $REGION gs://$BUCKET_NAME

  # Enable versioning for state protection
  gsutil versioning set on gs://$BUCKET_NAME

  echo "Bucket $BUCKET_NAME created successfully"
fi

echo "Bootstrap complete! Your Terraform backend configuration should be:"
echo "terraform {"
echo "  backend \"gcs\" {"
echo "    bucket = \"$BUCKET_NAME\""
echo "    prefix = \"terraform/environments/[environment]\""
echo "  }"
echo "}"
