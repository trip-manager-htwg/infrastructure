# Trip Manager Infrastructure

Terraform infrastructure for the Trip Manager platform on GCP. Manages GKE, networking, IAM, DNS, and supporting services across two independent environments (prod, staging), each in a separate GCP project.

## Structure

```txt
.
├── environments/
│   ├── prod/
│   │   ├── bootstrap/    # One-time setup: GCS state bucket
│   │   └── infra/        # Application infrastructure
│   ├── staging/
│   │   └── bootstrap/    # One-time setup: GCS state bucket
│   └── infra/            # Application infrastructure
└── modules/              # Reusable Terraform modules
```

## First-time Setup

Bootstrap must be run once per environment before the pipeline can manage infrastructure. It creates the GCS bucket used as Terraform remote state.

```bash
cd environments/<prod|staging>/bootstrap
terraform init
terraform apply
```

## Usage

Infrastructure is managed via `workflow_dispatch` in the CI/CD pipeline. Select the target environment and trigger manually.

For local use:

```bash
cd environments/<prod|staging>/infra
terraform init \
  -backend-config="bucket=<project-id>-terraform-state" \
  -backend-config="prefix=terraform/state"
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## Modules

| Module | Description |
|---|---|
| `gke` | GKE Autopilot cluster + VPC |
| `iam` | Service accounts, WIF, GitHub Actions SA |
| `dns` | Cloud DNS, certificates, static IP |
| `storage` | GCS uploads bucket |
| `secrets` | Secret Manager + IAM bindings |
| `pubsub` | Pub/Sub topics + subscriptions |
| `firestore` | Firestore database + indexes |

## Notes

- `terraform.tfvars` is never committed — provide via CI/CD secret `TF_VARS` or locally
- Bootstrap state is local and committed — it only contains the GCS bucket and never changes
- To fully tear down an environment, run the destroy workflow then delete the GCP project