# Preparação Inicial<br>
1 - Aws-cli instalado no equipamento.
![prep01](Imagens/Preparacao_Ambiante/Imagem_1.png)

Criação do Usuário Administrator. 
![prep02](Imagens/Preparacao_Ambiante/Imagem_2.png)

Foi atachada a police AdministradorAccess dando full access ao usuário para os serviços da AWS.<br>
O usuário Administrator foi adcionado ao grupo Administrators.
![prep03](Imagens/Preparacao_Ambiante/Imagem_3.png)

![prep04](Imagens/Preparacao_Ambiante/Imagem_4.png)

2 - AccessKey e SecretKey do seu usuário e configure o aws cli:
![prep05](Imagens/Preparacao_Ambiante/Imagem_5.png)

![cria06](Imagens/Criancao_Ambiente/Imagem_6.png)

# Criação do Ambiente de Controle<br>
![cria07](Imagens/Criancao_Ambiente/Imagem_7.png)

![cria08](Imagens/Criancao_Ambiente/Imagem_8.png)

![cria09](Imagens/Criancao_Ambiente/Imagem_9.png)

# Desafio AWS

**1 - Setup de ambiente**<br>
![setup10](Imagens/1_Setup_Ambiente/Imagem_10.png)

**2 - Networking**<br>
No Security Group (stack-controle-WebServerSecurityGroup-17XYSAGXM3BNH) o port range não englobava a porta 80 que é a porta http.<br>
![netw11](Imagens/2_Networking/Imagem_11.png)

Fiz a alteração para liberar a porta 80.<br>
![netw12](Imagens/2_Networking/Imagem_12.png)

A página web voltou a ser exibida corretamente.<br>
![netw13](Imagens/2_Networking/Imagem_13.png)

**3 - EC2 Access**<br>
No security grupo fiz a liberação da porta 22 para ter acesso via SSH. 
![ec2Ace14](Imagens/3_EC2_Access/Imagem_14.png)

Criei uma IAM role permitindo a instância EC2 acessar o Systems Manager.<br>
O AWS Systems Manager fornece um shell interativo baseado em navegador e CLI para gerenciar instâncias EC2 do Windows e do Linux, sem a necessidade de abrir portas de entrada, gerenciar chaves SSH ou usar hosts de bastiões
![ec2Ace15](Imagens/3_EC2_Access/Imagem_15.png)

Anexei a role na instância.<br>
![ec2Ace16](Imagens/3_EC2_Access/Imagem_16.png)

Criação da chave SSH para adicionar na instância.<br>
![ec2Ace17](Imagens/3_EC2_Access/Imagem_17.png)

Conectei na instância através do Session Manager.<br> 
![ec2Ace18](Imagens/3_EC2_Access/Imagem_18.png)

Adicionei a chave publica no arquivo authorized_keys.<br>
![ec2Ace19](Imagens/3_EC2_Access/Imagem_19.png)

![ec2Ace20](Imagens/3_EC2_Access/Imagem_20.png)





