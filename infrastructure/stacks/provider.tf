terraform {
  # we didn’t use 1.6+ due to this breaking change for now
  # https://github.com/hashicorp/terraform/issues/33981
  required_version = "~> 1.5.7"

  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "~> 3.2"
    }
  }

  backend "s3" {
    bucket                      = "pf.idt.demarches-simplifiees.infrastructure"
    key                         = "stacks.tfstate"
    region                      = "bhs"
    endpoint                    = "https://s3.bhs.io.cloud.ovh.net"
    skip_credentials_validation = true
    skip_region_validation      = true
  }
}

provider "rancher2" {
  api_url    = "https://rancher.mes-demarches.ovh/v3"
  access_key = var.rancher_access_key
  secret_key = var.rancher_secret_key
}
