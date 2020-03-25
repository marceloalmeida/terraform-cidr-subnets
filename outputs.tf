output "network_cidr_blocks" {
  description = "Map of networks"
  value       = local.groups.network_cidr_blocks
}

output "networks" {
  description = "List of maps"
  value       = local.groups.networks
}

output "networks_map" {
  description = "Networks maps"
  value       = local.groups.networks_map
}

output "networks_complex_map" {
  description = "Complex maps of the networks"
  value       = local.groups.networks_complex_map
}

output "networks_service_role_list" {
  description = "Maps of lists per service/role pair"
  value       = local.groups.networks_service_role_list
}

output "networks_service_role_map" {
  description = "Maps of maps per service/role pair"
  value       = local.groups.networks_service_role_map
}
