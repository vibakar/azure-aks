variable "auth" {
  type    = map(string)
  default = {}
}

variable "resource_group" {
  type = map(string)
  default = {
    name     = "kubernetes-resources",
    location = "UK South"
  }
}

variable "ssh_public_key" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}
