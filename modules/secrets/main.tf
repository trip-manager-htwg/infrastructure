resource "google_secret_manager_secret" "secrets" {
  for_each  = toset(var.secret_names) # ← nicht sensitiv
  project   = var.project_id
  secret_id = each.key

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "versions" {
  for_each    = toset(var.secret_names)
  secret      = google_secret_manager_secret.secrets[each.key].id
  secret_data = var.secret_values[each.key]
}

resource "google_secret_manager_secret_iam_member" "accessor" {
  for_each  = toset(var.secret_names)
  project   = var.project_id
  secret_id = google_secret_manager_secret.secrets[each.key].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.iam_sa_email}"
}