# Terraform CIDR Subnets Module

This is a simple Terraform module for calculating subnet addresses under a particular CIDR prefix.

Based on [Hashicorp Terraform CIDR Subnets Module](https://github.com/hashicorp/terraform-cidr-subnets) but with the improvements like adding extra fields and producing complex outputs so it can be used with `for_each` to create resources

It also includes an output to files for better understanding what is changing and also can be used for documentation purposes (e.g. [JSON to Markdown Table](https://kdelmonte.github.io/json-to-markdown-table/))

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| base\_cidr\_block | A network address prefix in CIDR notation that all of the requested subnetwork prefixes will be allocated within. | `string` | n/a | yes |
| json\_maps | Write the subnet maps to JSON files | `bool` | `false` | no |
| networks | A list of objects describing requested subnetwork prefixes. | <pre>list(object({<br>    availability_zone       = string<br>    map_public_ip_on_launch = bool<br>    new_bits                = number<br>    role                    = string<br>    service                 = string<br>  }))</pre> | `[]` | no |
| separator\_char | Separator character to join elements in order to build a single key on maps. | `string` | `":"` | no |

## Outputs

| Name | Description |
|------|-------------|
| network\_cidr\_blocks | Map of networks |
| networks | List of maps |
| networks\_complex\_map | Complex maps of the networks |
| networks\_map | Networks maps |
| networks\_service\_role\_list | Maps of lists per service/role pair |
| networks\_service\_role\_map | Maps of maps per service/role pair |

## Usage

Below if can find the usage of this module with some example.

To "remove" (mark as free) a subnet from the list do not delete from it, if so it will cause an move of all subnets CIDR's. To simply mark as free to use, replace one of the values of the files `service`, `role` or `availability_zone` with `null` value.


### Module instantiation
```
module "subnet_addrs" {
  source = "marceloalmeida/subnets/cidr"

  base_cidr_block = "10.0.0.0/16"

  networks = [
    {
      service                 = "base"
      role                    = "general"
      new_bits                = 10
      map_public_ip_on_launch = false
      availability_zone       = "us-east-1a"
    },
    {
      service                 = "base"
      role                    = "general"
      new_bits                = 10
      map_public_ip_on_launch = true
      availability_zone       = "us-east-1b"
    },
    {
      service                 = "base"
      role                    = "general"
      new_bits                = 10
      map_public_ip_on_launch = false
      availability_zone       = "us-east-1b"
    },
    {
      service                 = null
      role                    = "general"
      new_bits                = 10
      map_public_ip_on_launch = true
      availability_zone       = "us-east-1a"
    },
    {
      service                 = "rds"
      role                    = "general"
      new_bits                = 10
      map_public_ip_on_launch = true
      availability_zone       = "us-east-1b"
    },
  ]
}
```

### AWS subnet creation
```
resource "aws_subnet" "base_general" {
  for_each = lookup(module.subnets.networks_service_role_map, "base:general")

  vpc_id     = var.vpc_id
  cidr_block = each.value.cidr_block

  tags = each.value
}
```
