output "name_servers" {
  value       = module.dns.name_servers
  description = "To be added in namecheap config"
}

output "service_accounts" {
  value = module.iam.service_account_emails
}

output "wif_provider" {
  value = module.iam.wif_provider
}

output "github_actions_sa" {
  value = module.iam.github_actions_sa_email
}

output "staging_ip" {
  value = module.dns.ip_address
  description = "Static IP for GKE Gateway"
}