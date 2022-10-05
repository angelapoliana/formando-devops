module "servers"  {
  source              = "./servers"
  cluster_name        = "angela"
  kubernetes_version  = "kindest/node:v1.18.4"
  servers = 1
}

output "api_endpoint" {
  value = module.servers.api_endpoint
}

output "kubeconfig" {
  value = module.servers.kubeconfig
}

output "client_certificate" {
  value = module.servers.client_certificate
}

output "client_key" {
  value = module.servers.client_key
}

output "cluster_ca_certificate" {
  value = module.servers.cluster_ca_certificate
}