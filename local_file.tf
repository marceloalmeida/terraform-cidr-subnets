resource "local_file" "this" {
  for_each = {
    for k, v in local.groups : k => v if var.json_maps == true
  }

  content         = jsonencode(each.value)
  filename        = var.json_maps == true ? "${path.module}/results/${each.key}.json" : "/dev/null"
  file_permission = 644
}
