resource "google_compute_global_address" "primary" {
  name    = "trip-manager-${var.environment}-ip"
  project = var.project_id
}

resource "google_dns_managed_zone" "primary" {
  name        = "trip-manager-zone"
  dns_name    = "${var.domain}."
  description = "Trip Manager DNS Zone"
  project     = var.project_id
}

resource "google_dns_record_set" "root" {
  name         = "${var.domain}."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.primary.name
  project      = var.project_id
  rrdatas      = [google_compute_global_address.primary.address]
}

resource "google_dns_record_set" "api" {
  name         = "api.${var.domain}."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.primary.name
  project      = var.project_id
  rrdatas      = [google_compute_global_address.primary.address]
}

resource "google_dns_record_set" "www" {
  name         = "www.${var.domain}."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.primary.name
  project      = var.project_id
  rrdatas      = [google_compute_global_address.primary.address]
}

resource "google_certificate_manager_certificate" "primary" {
  name    = "trip-manager-${var.environment}-cert"
  project = var.project_id

  managed {
    domains = [
      var.domain,
      "api.${var.domain}",
      "www.${var.domain}"
    ]
  }
}

resource "google_certificate_manager_certificate_map" "primary" {
  name    = "trip-manager-${var.environment}-cert-map"
  project = var.project_id
}

resource "google_certificate_manager_certificate_map_entry" "root" {
  name         = "trip-manager-${var.environment}-cert-map-entry"
  project      = var.project_id
  map          = google_certificate_manager_certificate_map.primary.name
  certificates = [google_certificate_manager_certificate.primary.id]
  hostname     = var.domain
}

resource "google_certificate_manager_certificate_map_entry" "www" {
  name         = "trip-manager-${var.environment}-cert-map-entry-www"
  project      = var.project_id
  map          = google_certificate_manager_certificate_map.primary.name
  certificates = [google_certificate_manager_certificate.primary.id]
  hostname     = "www.${var.domain}"
}

resource "google_certificate_manager_certificate_map_entry" "api" {
  name         = "trip-manager-${var.environment}-cert-map-entry-api"
  project      = var.project_id
  map          = google_certificate_manager_certificate_map.primary.name
  certificates = [google_certificate_manager_certificate.primary.id]
  hostname     = "api.${var.domain}"
}
