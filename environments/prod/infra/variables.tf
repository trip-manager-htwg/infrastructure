variable "project_id" {
  description = "Project ID of the GCP project"
  type        = string
  default     = "ornate-reef-501614-a1"
}

variable "region" {
  description = "Region to deploy resources in"
  type        = string
  default     = "europe-west1"
}

variable "domain" {
  description = "Domain name for the application"
  type        = string
  default     = "neatnode.xyz"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "namespace" {
  description = "Kubernetes namespace for workload identity binding"
  type        = string
  default     = "trip-manager-prod"
}

variable "github_repo" {
  description = "GitHub repository in format owner/repo"
  type        = string
  default     = "trip-manager-htwg/application"
}

variable "services" {
  description = "List of services to create service accounts for"
  type        = list(string)
  default     = ["auth", "social", "users", "trips", "external-secrets", "frontend", "travel-info", "feed", "newsletter", "otel-collector"]
}

variable "workload_identity_services" {
  description = "List of services to configure workload identity for"
  type        = list(string)
  default     = ["auth", "social", "users", "trips", "newsletter", "otel-collector", "feed"]
}

variable "gcs_bucket" {
  description = "Name of the GCS bucket"
  type        = string
  default     = "ornate-reef-501614-a1-trip-manager-bucket"
}

variable "cors_origins" {
  description = "Allowed CORS origins"
  type        = list(string)
  default     = ["https://neatnode.xyz", "https://www.neatnode.xyz"]
}

variable "secrets" {
  description = "Map of secret names to their values"
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "secret_names" {
  description = "List of secret names"
  type        = list(string)
  default = [
    "project-id",
    "users-database-password",
    "trips-database-password",
    "newsletter-database-password",

    "redis-password",
    "redis-url",

    "neo4j-password",
    "neo4j-url",
    "neo4j-username",

    "trips-app-database-password",
    "users-app-database-password",
    "newsletter-app-database-password",

    "users-migration-url",
    "trips-migration-url",
    "newsletter-migration-url",
    "newsletter-database-url",
    "trips-database-url",
    "users-database-url",

    "resend-api-key",
    "github-token",
    "internal-secret",

    "github-pat-packages"
  ]
}
