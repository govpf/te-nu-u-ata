
terraform {
  required_version = "~> 1.5.2"

  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.4"
    }
  }

  backend "s3" {
    bucket                      = "pf.idt.demarches-simplifiees.infrastructure"
    key                         = "terraform.tfstate"
    region                      = "bhs"
    endpoint                    = "https://s3.bhs.io.cloud.ovh.net"
    skip_credentials_validation = true
    skip_region_validation      = true
  }
}

provider "vsphere" {
  user           = "admin"
  password       = "A82DknizGQO7vxgF"
  vsphere_server = "pcc-51-210-115-216.ovh.com"
}
