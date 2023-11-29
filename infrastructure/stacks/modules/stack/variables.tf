variable "name" {
  type        = string
  description = "Stack’s name, usually the client’s name, for instance airliquide"
}

variable "secrets" {
  type        = map(map(string))
  description = "Stack’s secrets"
  sensitive   = true
}
