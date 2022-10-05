variable "install_pkgs" {
  type         = list
  description  = "Lista os pacotes a serem instalados, com versão" 
  default      = ["nginx"]
}

variable "uninstall_pkgs" {
  type         = list
  description  = "Lista de pacotes a serem desinstalados." 
  default      = []
}



