variable "resource_group_name" {
  type    = string
  default = "r-grp"
}

variable "location" {
  type    = string
  default = "japaneast"
}

variable "vnet_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_prefix" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "ssh_key_name" {
  description = "Your SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "node_count" {
  description = "Number of nodes in the node pool"
  type        = number
  default     = 3
}

