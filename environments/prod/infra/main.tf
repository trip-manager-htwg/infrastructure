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

# Resend DNS Records (prod only)
resource "google_dns_record_set" "resend_dkim" {
  name         = "resend._domainkey.${var.domain}."
  type         = "TXT"
  ttl          = 300
  managed_zone = module.dns.managed_zone_name
  project      = var.project_id
  rrdatas      = ["\"v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCdhAAXtqNesK3awbDhBarUs3xTzVOP9iP2fjv+KsfMV/E8Jkz+YIDo6+xXVEJg+rMeU4ERNj29GyH9cQ0HzkuLQ3mc8NbIaNDo02FjWZI2n1LGsVLkhmOmwgqJCzVY/kBkmlfi1K2yFstT+29BPaCB07LhWqz3m7bmL7rKWUBWiQIDAQAB\""]
}

resource "google_dns_record_set" "resend_mx" {
  name         = "send.${var.domain}."
  type         = "MX"
  ttl          = 300
  managed_zone = module.dns.managed_zone_name
  project      = var.project_id
  rrdatas      = ["10 feedback-smtp.eu-west-1.amazonses.com."]
}

resource "google_dns_record_set" "resend_spf" {
  name         = "send.${var.domain}."
  type         = "TXT"
  ttl          = 300
  managed_zone = module.dns.managed_zone_name
  project      = var.project_id
  rrdatas      = ["\"v=spf1 include:amazonses.com ~all\""]
}

resource "google_dns_record_set" "resend_dmarc" {
  name         = "_dmarc.${var.domain}."
  type         = "TXT"
  ttl          = 300
  managed_zone = module.dns.managed_zone_name
  project      = var.project_id
  rrdatas      = ["\"v=DMARC1; p=none;\""]
}