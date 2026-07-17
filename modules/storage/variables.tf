variable "gcs_bucket" {
  type    = string
}

variable "region" {
  type    = string
}

variable "cors_origins" {
  type    = list(string)
}
