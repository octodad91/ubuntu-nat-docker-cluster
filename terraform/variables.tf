variable "vm" {
  type = map(object({
    vcpu   = number
    memory = number
  }))
  default = {
    "docker_plus_vm1" = { vcpu = 2, memory = 2048 }
    "docker_plus_vm2" = { vcpu = 2, memory = 2048 }
    "docker_plus_vm3" = { vcpu = 2, memory = 2048 }
  }
}
