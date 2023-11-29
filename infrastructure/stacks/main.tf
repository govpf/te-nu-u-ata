module "stack" {
  source = "./modules/stack"

  for_each = local.stacks
  name     = each.value["name"]
  secrets  = each.value["secrets"]
}

locals {
  stacks = {
    "staging" = {
      name    = "staging"
      secrets = merge(var.default_secrets, var.stacks_secrets["staging"])
    }
  }
}
