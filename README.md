# secure-rag-kit-deploy

Terraform + Cloud Build deployment infrastructure for [`secure-rag-kit`](https://github.com/musabdulai-io/secure-rag-kit). Deploys to Google Cloud Run.

**Live deployment**: [rag.musabdulai.com](https://rag.musabdulai.com)

## Layout

- `infra/deployment/` — Runtime: Cloud Run services (backend + frontend), Secret Manager, IAM bindings, Cloud Storage.
- `infra/pipeline/` — Cloud Build trigger that builds + deploys on push to `main` of [`secure-rag-kit`](https://github.com/musabdulai-io/secure-rag-kit).
- `infra/modules/` — Reusable Terraform modules (secrets, cloud-run service, IAM).
- `cloudbuild.yaml` — Build pipeline definition executed by Cloud Build.
- `skaffold-backend.yaml`, `skaffold-frontend.yaml` — Local Skaffold workflows for iterating on the deployment manifests.
- `bootstrap.sh` — One-time GCP project setup (enables APIs, creates initial service accounts).

## Prerequisites

- Google Cloud SDK (`gcloud`) installed and authenticated
- Terraform >= 1.0
- GCP project with billing enabled
- IAM permissions to create Cloud Run services, secrets, and Cloud Build triggers

## Quick start

1. Run `./bootstrap.sh` to enable the required GCP APIs on a fresh project.
2. Copy `infra/deployment/terraform.example.tfvars` to `infra/deployment/terraform.tfvars` and fill in your GCP project ID + runtime environment variables (OpenAI API key, etc. — these get pushed to Secret Manager).
3. `cd infra/pipeline && terraform init && terraform apply` — creates the Cloud Build trigger linked to the [`secure-rag-kit`](https://github.com/musabdulai-io/secure-rag-kit) repo.
4. `cd infra/deployment && terraform init && terraform apply` — creates the runtime infrastructure.
5. Push to the `main` branch of `secure-rag-kit` → Cloud Build builds and deploys automatically.

## Secrets

`terraform.tfvars` is gitignored. Real secrets live there locally (or in a CI secret store); the example file shows the expected shape with placeholder values.

## Related

- [`secure-rag-kit`](https://github.com/musabdulai-io/secure-rag-kit) — the application code this deploys
- [Cloud Controls Evidence Kit](https://musabdulai.com/evidence-kit) — free MIT-licensed templates for the engineering evidence customer security reviews ask for

## License

[MIT](./LICENSE).
