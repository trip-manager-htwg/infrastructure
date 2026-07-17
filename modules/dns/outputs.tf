output "name_servers" {
  value = google_dns_managed_zone.primary.name_servers
  description = "List of name servers which are to be added in namecheap config"
}

output "managed_zone_name" {
  value       = google_dns_managed_zone.primary.name
  description = "Name of the managed DNS zone"
}

output "ip_address" {
  value       = google_compute_global_address.primary.address
  description = "Static IP for GKE Gateway"
}