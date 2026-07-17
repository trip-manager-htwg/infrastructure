resource "google_service_account" "services" {
  for_each = toset(var.services)

  account_id   = "${each.value}-sa"
  display_name = "${each.value} Service Account"
  project      = var.project_id
}

# Firestore + Firebase Related Roles
resource "google_project_iam_member" "auth_firebase" {
  member  = "serviceAccount:${google_service_account.services["auth"].email}"
  project = var.project_id
  role    = "roles/firebase.sdkAdminServiceAgent"
}

# GCS Related Roles
resource "google_project_iam_member" "social_firestore" {
  member  = "serviceAccount:${google_service_account.services["social"].email}"
  project = var.project_id
  role    = "roles/datastore.user"
}

resource "google_project_iam_member" "social_storage" {
  member  = "serviceAccount:${google_service_account.services["social"].email}"
  project = var.project_id
  role    = "roles/storage.objectAdmin"
}

resource "google_project_iam_member" "social_token_creator" {
  member  = "serviceAccount:${google_service_account.services["social"].email}"
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
}

resource "google_project_iam_member" "locations_storage" {
  member  = "serviceAccount:${google_service_account.services["trips"].email}"
  project = var.project_id
  role    = "roles/storage.objectAdmin"
}

resource "google_project_iam_member" "locations_token_creator" {
  member  = "serviceAccount:${google_service_account.services["trips"].email}"
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
}

# General Roles + Infrastructure
resource "google_service_account_iam_member" "workload_identity" {
  for_each = toset(var.workload_identity_services)

  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.namespace}/${each.value}]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.services[each.value].name
}

resource "google_service_account_iam_member" "external_secrets_workload_identity" {
  member             = "serviceAccount:${var.project_id}.svc.id.goog[external-secrets/external-secrets]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.services["external-secrets"].name
}

# WIF Pool (GitHub)
resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Workload Identity Pool"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Actions Provider"
  description                        = "Workload Identity Provider for GitHub Actions"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  attribute_condition = "assertion.repository == '${var.github_repo}'"
}


resource "google_service_account" "github_actions" {
  account_id   = "github-actions-sa"
  display_name = "GitHub Actions Service Account"
  project      = var.project_id
}

resource "google_project_iam_member" "github_actions_roles" {
  for_each = toset([
    "roles/container.developer",
    "roles/iam.serviceAccountTokenCreator",
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_service_account_iam_member" "github_wif" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repo}"
}


resource "google_project_iam_member" "trips_pubsub" {
  project = var.project_id
  role    = "roles/pubsub.editor"
  member  = "serviceAccount:${google_service_account.services["trips"].email}"
}

resource "google_project_iam_member" "newsletter_pubsub" {
  project = var.project_id
  role    = "roles/pubsub.editor"
  member  = "serviceAccount:${google_service_account.services["newsletter"].email}"
}


resource "google_project_iam_member" "feed_pub_sub" {
  project = var.project_id
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.services["feed"].email}"
}

resource "google_project_iam_member" "users_firebase" {
  member  = "serviceAccount:${google_service_account.services["users"].email}"
  project = var.project_id
  role    = "roles/firebase.sdkAdminServiceAgent"
}

resource "google_project_iam_member" "otel_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.services["otel-collector"].email}"
}

resource "google_project_iam_member" "otel_trace" {
  project = var.project_id
  role    = "roles/cloudtrace.agent"
  member  = "serviceAccount:${google_service_account.services["otel-collector"].email}"
}

resource "google_project_iam_member" "users_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.services["users"].email}"
}

resource "google_project_iam_member" "users_secret_admin" {
  project = var.project_id
  role    = "roles/secretmanager.admin"
  member  = "serviceAccount:${google_service_account.services["users"].email}"
}