variable "datacenter" {
  description = "vSphere Datacenter"
  type        = string
  default     = "pcc-51-210-115-216_datacenter1445"
}

variable "datastore_1" {
  description = "vSphere Datastore 1"
  type        = string
  default     = "ssd-003171"
}

variable "datastore_2" {
  description = "vSphere Datastore 2"
  type        = string
  default     = "ssd-003172"
}

variable "cluster" {
  description = "vSphere Cluster name"
  type        = string
  default     = "Cluster1"
}

variable "network" {
  description = "Network used by VM"
  type        = string
  default     = "VM Network"
}

variable "vms_rancher" {
  description = "Object representing Rancher VMS"
  type = set(object({
    name                 = string,
    index                = number,
    num_cpus             = number,
    num_cores_per_socket = number,
    memory               = number,
    disk_size            = number,
    properties           = map(string)
  }))
}

variable "vms_database" {
  description = "Object representing Rancher VMS"
  type = set(object({
    name                 = string,
    index                = number,
    num_cpus             = number,
    num_cores_per_socket = number,
    memory               = number,
    disk_size            = number,
    properties           = map(string)
  }))
}

variable "vms_bastion" {
  description = "Object representing Rancher VMS"
  type = set(object({
    name                 = string,
    index                = number,
    num_cpus             = number,
    num_cores_per_socket = number,
    memory               = number,
    disk_size            = number,
    properties           = map(string)
  }))
}

variable "vm_default_properties" {
  description = "VM default properties"
  type        = map(string)
  default = {
    "guestinfo.dns"              = "213.186.33.99"
    "guestinfo.gateway"          = "51.255.159.46"
    "guestinfo.netmask"          = "255.255.255.240"
    "guestinfo.password_crypted" = "False"
    "guestinfo.ssh_enable"       = "True"
    "guestinfo.ssh_key"          = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP4UDnBjxttaDWUNVGNVjPqwn5+q/fAcGOQ5pAvzHNe/ mcatty@synbioz.com"
    "guestinfo.ssh_port"         = "22"
    "guestinfo.user"             = "idt"
  }
}
