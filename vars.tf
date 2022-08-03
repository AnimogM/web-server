variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "maryam"
}

variable "packer_resource_group_name" {
   description = "Name of the resource group in which the Packer image will be created"
   default     = "maryam-rg"
}

variable "packer_image_name" {
   description = "Name of the Packer image"
   default     = "myVmImage"
}


variable "resource_group_name" {
   description = "Name of the resource group in which the resources will be created"
   default     = "resourceGroups"
}

variable "location" {
   default = "eastus"
   description = "Location where resources will be created"
}

variable "tags" {
   description = "Map of the tags to use for the resources that are deployed"
   type        = map(string)
   default = {
      project = "vm"
   }
}

variable "application_port" {
   description = "Port that you want to expose to the external load balancer"
   default     = 80
}

variable "username" {
   description = "User name to use as the admin account on the VMs that will be part of the VM scale set"
   default     = "azureuser"
}

variable "password" {
   description = "Default password for admin account"
   default = "Password123456"
}


variable "counter" {
  description = "Specify the number of virtual machine to be created"
  default = 3
}