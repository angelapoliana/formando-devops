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



