resource "local_file" "alo_mundo" {
  content     = templatefile("${path.module}/alo_mundo.txt.tpl", {"nome" = local.nome, "data" = local.data, "div" = local.div, "result_div" = local.result_div})
  filename    = "${path.module}/alo_mundo_${terraform.workspace}.txt"
}



