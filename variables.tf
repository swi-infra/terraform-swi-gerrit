## Gerrit

variable "env_prefix" {
  description = "Prefix for resource names"
  default = ""
}

variable "master_vm_size" {
  description = "VM Size"
  default = "Standard_DS2_v2"
}

variable "data_disk_size_gb" {
  description = "Size of the disk containing Gerrit data (instanciated for each VM)"
  default = 512
}

variable "master_nb" {
  description = "Total number of node in the highly-available cluster (so far, only 2 supported)"
  default = 1
}

variable "config_url" {
  description = "Repository URL for this git module"
  default = "https://github.com/swi-infra/terraform-swi-gerrit.git"
}

variable "is_public" {
  description = "If true, load balancer is public, otherwise it is private"
  default = true
}

## Azure

variable "resource_group" {
  description = "The name of the resource group in which to create the virtual network."
  default     = "gerrit-dev"
}

variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
  default     = "westus"
}

variable "virtual_network_name" {
  description = "The name for the virtual network."
  default     = "gerrit-network"
}

variable "subnet" {
  description = "The subnet used to host Gerrit servers"
  default = "gerrit-subnet"
}

variable "subnet_id" {
  description = "The subnet ID used to host Gerrit servers"
  default = "/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Network/virtualNetworks/xxx/subnets/gerrit-subnet"
}

## VMs OS

variable "image_publisher" {
  description = "name of the publisher of the image (az vm image list)"
  default     = "CoreOS"
}

variable "image_offer" {
  description = "the name of the offer (az vm image list)"
  default     = "CoreOS"
}

variable "image_sku" {
  description = "image sku to apply (az vm image list)"
  default     = "Stable"
}

variable "image_version" {
  description = "version of the image to apply (az vm image list)"
  default     = "latest"
}

variable "admin_username" {
  description = "administrator user name"
  default     = "core"
}

variable "admin_ssh_key" {
  description = "administrator ssh key"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAy4b4mjWHuN8Ckb9RL7/JQloGSwo5AQQTi2XgLJb1SOZSYggTro4GJbLi42+sUieCxNBWanpuUTuSdde7bcreSSp/S1m3ldtYeA/L+wfQErKsbJwhMtCWU2oU9WZKPUXkYVCPhe9dLnAbGc792RwFrsJTtWudqNC9dLqNuSAvZWiYuMzurWit1uyvFcR6eyNNSRa73riA5c//LHOA9PmRZup3QZUDfDJ8+buLzXfXfG9dzB0s9KAhNBZFYJb4UvpF2Vb2ArIZ2la9XNKIcMrSviLJCKn3tJh7CUyg4WwwdSZWMuBuYAcYbJDsmBskHfO22CATjqCfprm/LnceIzK6bw=="
}

