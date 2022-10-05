terraform {
  required_providers {
    kind = {
      source = "kyma-incubator/kind"
      version = "0.0.11"
    }
  
  }
}

# Create a cluster with kind of the name "test-cluster" with kubernetes version v1.16.1
resource "kind_cluster" "default" {
    name            = var.cluster_name
    node_image      = var.kubernetes_version
    #count           = var.servers
    kind_config  {
        kind        = "Cluster"
        api_version = "kind.x-k8s.io/v1alpha4"              

        node {
            role = "control-plane"
        }
        node {
            role = "infra"
        }           
        node {
            role = "app"
        }      
    }
}
