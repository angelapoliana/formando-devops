resource "null_resource" "metricserver" {
  triggers = {
    key = uuid()
  }

  provisioner "local-exec" {
    command = <<EOF
      kubectl apply -f ${path.module}/components.yaml
    EOF
  }

  depends_on = [kind_cluster.default]
} 