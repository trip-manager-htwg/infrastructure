variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "namespace" {
  description = "Kubernetes namespace for workload identity binding"
  type        = string
}

variable "services" {
  description = "List of services to create service accounts for"
  type        = list(string)
}

variable "workload_identity_services" {
  description = "List of services to configure workload identity for"
  type        = list(string)
}