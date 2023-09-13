data "vsphere_datacenter" "datacenter" {
  name = var.datacenter
}

data "vsphere_datastore" "datastore_1" {
  name          = var.datastore_1
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datastore" "datastore_2" {
  name          = var.datastore_2
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Data source for vCenter Content Library
data "vsphere_content_library" "ovh_library" {
  name = "OVHcloud content library"
}

# Data source for vCenter Content Library Item
data "vsphere_content_library_item" "debian_12" {
  name       = var.debian_12
  type       = "ovf"
  library_id = data.vsphere_content_library.ovh_library.id
}

data "vsphere_content_library_item" "debian_11" {
  name       = var.debian_11
  type       = "ovf"
  library_id = data.vsphere_content_library.ovh_library.id
}

resource "vsphere_virtual_machine" "rancher" {
  # iterate on something like this { name: object }
  for_each = { for index, vm in var.vms_rancher : vm.name => vm }
  name     = each.value.name

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  # alternate datastore
  datastore_id = each.value.index % 2 == 0 ? data.vsphere_datastore.datastore_1.id : data.vsphere_datastore.datastore_2.id

  num_cpus             = each.value.num_cpus
  num_cores_per_socket = each.value.num_cores_per_socket
  memory               = each.value.memory

  clone {
    template_uuid = data.vsphere_content_library_item.debian_12.id
  }

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label           = "disk0"
    size            = each.value.disk_size
    controller_type = "scsi"
  }

  vapp {
    properties = merge(var.vm_default_properties, each.value.properties)
  }
}

resource "vsphere_virtual_machine" "bastion" {
  # iterate on something like this { name: object }
  for_each = { for index, vm in var.vms_rancher : vm.name => vm }
  name     = each.value.name

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  # alternate datastore
  datastore_id = each.value.index % 2 == 0 ? data.vsphere_datastore.datastore_1.id : data.vsphere_datastore.datastore_2.id

  num_cpus             = each.value.num_cpus
  num_cores_per_socket = each.value.num_cores_per_socket
  memory               = each.value.memory

  clone {
    template_uuid = data.vsphere_content_library_item.debian_12.id
  }

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label           = "disk0"
    size            = each.value.disk_size
    controller_type = "scsi"
  }

  vapp {
    properties = merge(var.vm_default_properties, each.value.properties)
  }
}

resource "vsphere_virtual_machine" "database" {
  # iterate on something like this { name: object }
  for_each = { for index, vm in var.vms_database : vm.name => vm }
  name     = each.value.name

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  # alternate datastore
  datastore_id = each.value.index % 2 == 0 ? data.vsphere_datastore.datastore_1.id : data.vsphere_datastore.datastore_2.id

  num_cpus             = each.value.num_cpus
  num_cores_per_socket = each.value.num_cores_per_socket
  memory               = each.value.memory

  clone {
    template_uuid = data.vsphere_content_library_item.debian_11.id
  }

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label           = "disk0"
    size            = each.value.disk_size
    controller_type = "scsi"
  }

  vapp {
    properties = merge(var.vm_default_properties, each.value.properties)
  }
}
