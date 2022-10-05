#Configuração do AWS Provider
provider "aws" {
  region  = "us-east-1"
}

#Backend S3 para state remoto
terraform {
  backend "s3" {
    #Configuração de como ele vai encontrar o bucket S3 na AWS
    bucket = "angela-poliana-terraform" 
    key    = "terraform-test.tfstate"  #Arquivo de estado que vai ser criado dentro do bucket
    region = "us-east-1"               #Região da AWS que ele vai procurar o bucket
  }
}