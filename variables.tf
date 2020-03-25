variable "networks" {
  default     = []
  description = "A list of objects describing requested subnetwork prefixes."
  type = list(object({
    availability_zone       = string
    map_public_ip_on_launch = bool
    new_bits                = number
    role                    = string
    service                 = string
  }))
}

variable "base_cidr_block" {
  description = "A network address prefix in CIDR notation that all of the requested subnetwork prefixes will be allocated within."
  type        = string
}

variable "separator_char" {
  default     = ":"
  description = "Separator character to join elements in order to build a single key on maps."
  type        = string
}

variable "json_maps" {
  default     = false
  description = "Write the subnet maps to JSON files"
  type        = bool
}
