variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "service_name" {
  description = "Name of the service/application"
  type        = string
}

variable "region" {
  description = "Google Cloud region"
  type        = string
  default     = "us-central1"
}

variable "required_apis" {
  description = "List of GCP APIs to enable"
  type        = list(string)
  default = [
    "cloudresourcemanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
    "clouddeploy.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "logging.googleapis.com",
    # REMOVED: Firebase APIs not needed for this demo
    # "firebase.googleapis.com",
    # "identitytoolkit.googleapis.com"
    # REMOVED: Cloud Tasks, Workflows, Eventarc not needed
    # "cloudtasks.googleapis.com",
    # "workflows.googleapis.com",
    # "eventarc.googleapis.com",
    # "workflowexecutions.googleapis.com",
    # "pubsub.googleapis.com",
  ]
}
