
variable "cluster_name" {
  description = "The kind name that is given to the created cluster." 
  type        = string  
  default     = "demo-local"
}

variable "kubernetes_version" {
  description  = "The node_image that kind will use."
  type         = string
  default      = "kindest/node:v1.16.1"
  
  validation {
    condition     = length(var.kubernetes_version) > 8 && substr(var.kubernetes_version, 0, 8) == "kindest/"
    error_message = "The node_image value must be a valid kubernetes version, starting with \"kindest/\"."
  }
}

variable "servers"{
}
