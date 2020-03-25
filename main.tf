locals {
  addrs_by_idx = cidrsubnets(var.base_cidr_block, var.networks[*].new_bits...)

  addrs_by_service_role_az_index = {
    for k, v in var.networks : join(
      var.separator_char, [
        v.service != null ? v.service : "null",
        v.role != null ? v.role : "null",
        v.availability_zone != null ? v.availability_zone : "null",
        k,
  ]) => local.addrs_by_idx[k] if(v.service != null && v.role != null && v.availability_zone != null) }

  network_objs = [
    for k, v in var.networks : {
      availability_zone       = v.availability_zone
      cidr_block              = (v.service != null && v.role != null && v.availability_zone != null) ? local.addrs_by_idx[k] : tostring(null)
      new_bits                = v.new_bits
      map_public_ip_on_launch = v.map_public_ip_on_launch
      role                    = v.role
      service                 = v.service
    }
  ]

  network_objs_map = {
    for k, v in var.networks : join(
      var.separator_char, [
        format("%010d", k),
        v.service != null ? v.service : "null",
        v.role != null ? v.role : "null",
        v.availability_zone != null ? v.availability_zone : "null",
      ]) => {
      availability_zone       = v.availability_zone
      cidr_block              = (v.service != null && v.role != null && v.availability_zone != null) ? local.addrs_by_idx[k] : tostring(null)
      map_public_ip_on_launch = v.map_public_ip_on_launch == null ? false : v.map_public_ip_on_launch
      new_bits                = v.new_bits
      role                    = v.role
      service                 = v.service
    }
  }

  network_objs_map_2 = {
    for k, v in local.network_objs_map : join(
      var.separator_char, [
        k,
        split(var.separator_char, k)[0],
        split(var.separator_char, k)[1],
        split(var.separator_char, k)[2],
      ]) => {
      join(
        var.separator_char, [
          split(var.separator_char, k)[0],
          split(var.separator_char, k)[1],
          split(var.separator_char, k)[2]
        ]
      ) : v
    }
  }

  network_objs_map_3 = [
    for k, v in local.network_objs_map_2 : {
      join(
        var.separator_char, [
          split(var.separator_char, k)[1],
          split(var.separator_char, k)[2]
        ]) : lookup(
        v,
        "${split(var.separator_char, k)[0]}${var.separator_char}${split(var.separator_char, k)[1]}${var.separator_char}${split(var.separator_char, k)[2]}",
        {}
      )
    }
  ]

  service_role = distinct(flatten([for k, v in local.network_objs_map_3 : keys(v)]))

  networks_service_role_list = {
    for k, v in local.service_role : v => [
      for i, j in local.network_objs_map_3 : merge(lookup(j, v, null), { "index" : i }) if v == try(flatten(keys(j))[0], null)
    ]
  }

  networks_service_role_map = {
    for k, v in local.networks_service_role_list : k => {
      for i, j in v : i => j
    }
  }

  network_objs_complex_map = {
    for k, v in local.network_objs_map : k => {
      split(var.separator_char, k)[0] = {
        split(var.separator_char, k)[1] = {
          split(var.separator_char, k)[2] = {
            availability_zone       = v.availability_zone
            cidr_block              = v.cidr_block
            map_public_ip_on_launch = v.map_public_ip_on_launch
            new_bits                = v.new_bits
            role                    = v.role
            service                 = v.service
          }
        }
      }
    }
  }

  groups = {
    network_cidr_blocks        = tomap(local.addrs_by_service_role_az_index)
    networks                   = tolist(local.network_objs)
    networks_map               = tomap(local.network_objs_map)
    networks_service_role_list = local.networks_service_role_list
    networks_complex_map       = tomap(local.network_objs_complex_map)
    networks_service_role_map  = local.networks_service_role_map
  }
}
