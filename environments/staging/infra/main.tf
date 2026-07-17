resource "google_project_service" "apis" {
  for_each = toset([
    "monitoring.googleapis.com",
    "cloudtrace.googleapis.com",
    "logging.googleapis.com",
    "container.googleapis.com",
    "secretmanager.googleapis.com",
    "dns.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "certificatemanager.googleapis.com",
    "pubsub.googleapis.com",
    "firestore.googleapis.com",
  ])
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# Comment out to save costs
module "gke" {
  source      = "../../../modules/gke"
  project_id  = var.project_id
  region      = var.region
  environment = var.environment
  depends_on  = [google_project_service.apis]
}

module "iam" {
  source                     = "../../../modules/iam"
  project_id                 = var.project_id
  region                     = var.region
  github_repo                = var.github_repo
  namespace                  = var.namespace
  services                   = var.services
  workload_identity_services = var.workload_identity_services
  depends_on                 = [module.gke, google_project_service.apis]
}

module "storage" {
  source       = "../../../modules/storage"
  region       = var.region
  gcs_bucket   = var.gcs_bucket
  cors_origins = var.cors_origins
}

module "dns" {
  source      = "../../../modules/dns"
  project_id  = var.project_id
  domain      = var.domain
  environment = var.environment
  depends_on  = [google_project_service.apis]
}

module "secrets" {
  source        = "../../../modules/secrets"
  project_id    = var.project_id
  iam_sa_email  = module.iam.external_secrets_sa_email
  secret_names  = var.secret_names
  secret_values = var.secrets
  depends_on    = [google_project_service.apis]
}

module "pubsub" {
  source     = "../../../modules/pubsub"
  project_id = var.project_id
  depends_on = [google_project_service.apis]
}

module "firestore" {
  source     = "../../../modules/firestore"
  project_id = var.project_id
  region     = var.region
  depends_on = [google_project_service.apis]
}