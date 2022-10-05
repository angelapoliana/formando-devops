#Bloco resource para criar um EC2 na AWS
resource "aws_instance" "web" {
  ami           = "ami-0885b1f6bd170450c"  #AMI expecifica da região us-east-1 
  instance_type = "t2.micro"  #Tamanho da instancia

  tags = {
    Name = "HelloWorld"  #Nome da instância
  }
}
