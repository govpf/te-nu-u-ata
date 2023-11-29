variable "rancher_access_key" {
  type        = string
  description = "Rancher access key"
  sensitive   = true
}

variable "rancher_secret_key" {
  type        = string
  description = "Rancher secret key"
  sensitive   = true
}

variable "default_secrets" {
  type      = map(map(string))
  sensitive = true
}

variable "stacks_secrets" {
  type      = map(map(map(string)))
  sensitive = true
}
