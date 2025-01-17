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
No Security Group ```stack-controle-WebServerSecurityGroup-17XYSAGXM3BNH``` o port range não englobava a porta 80 (HTTP).<br>
![netw11](Imagens/2_Networking/Imagem_11.png)

Fiz a alteração para liberar a porta 80.
![netw12](Imagens/2_Networking/Imagem_12.png)

A página web voltou a ser exibida corretamente.
![netw13](Imagens/2_Networking/Imagem_13.png)

**3 - EC2 Access**<br>
No security grupo fiz a liberação da porta 22 para ter acesso via SSH. 
![ec2Ace14](Imagens/3_EC2_Access/Imagem_14.png)

Criei uma IAM Role permitindo a instância EC2 acessar o Systems Manager.<br>
O AWS Systems Manager fornece um shell interativo baseado em navegador e CLI para gerenciar instâncias EC2 do Windows e do Linux, sem a necessidade de abrir portas de entrada, gerenciar chaves SSH ou usar hosts de bastiões
![ec2Ace15](Imagens/3_EC2_Access/Imagem_15.png)

Anexei a role na instância.
![ec2Ace16](Imagens/3_EC2_Access/Imagem_16.png)

Criação da chave SSH para adicionar na instância.
![ec2Ace17](Imagens/3_EC2_Access/Imagem_17.png)

Conectei na instância através do Session Manager.
![ec2Ace18](Imagens/3_EC2_Access/Imagem_18.png)

Adicionei a chave publica no arquivo authorized_keys.
![ec2Ace19](Imagens/3_EC2_Access/Imagem_19.png)

![ec2Ace20](Imagens/3_EC2_Access/Imagem_20.png)

Realizei a conexão da instância via SSH.
![ec2Ace21](Imagens/3_EC2_Access/Imagem_21.png)

2 - Alteração do texto da página web exibida, colocando meu nome no início do texto do arquivo.
![ec2Ace22](Imagens/3_EC2_Access/Imagem_22.png)

![ec2Ace23](Imagens/3_EC2_Access/Imagem_23.png)

**4 - EC2 troubleshooting**<br>
Apos reiniciar a instância verifiquei que o serviço não iniciou automaticamente.<br>
Chequei o status do apache e confirmei que o serviço estava desabilitado.
![ec2Trou24](Imagens/4_EC2_Troubleshooting/Imagem_24.png)

Coloquei o serviço do apache enable e chequei novamente para ter certeza se o status tinha alterado.
![ec2Trou25](Imagens/4_EC2_Troubleshooting/Imagem_25.png)

**5 - Balanceamento**<br>
Primeiramente fiz o Snapshot da Instância.
![Balan27](Imagens/5_Balanceamento/Imagem_27.png)

Com o Snapshot fiz a Image e o Launch da instância. 
![Balan28](Imagens/5_Balanceamento/Imagem_28.png)

Primeira Instância.
![Balan29](Imagens/5_Balanceamento/Imagem_29.png)

Serviço web da primeira instância funcionando.
![Balan30](Imagens/5_Balanceamento/Imagem_30.png)

Cópia idêntica da EC2
![Balan31](Imagens/5_Balanceamento/Imagem_31.png)

Serviço web da segunda instância funcionando.
![Balan32](Imagens/5_Balanceamento/Imagem_32.png)

Para criar o Load Balancer primeiro fiz a criação do Target Group.
![Balan34](Imagens/5_Balanceamento/Imagem_34.png)

Instâncias associadas ao Target Group. 
![Balan35](Imagens/5_Balanceamento/Imagem_35.png)

Criação do Load Balancer.
![Balan36](Imagens/5_Balanceamento/Imagem_36.png)
![Balan37](Imagens/5_Balanceamento/Imagem_37.png)

Serviço web respondendo ao endereço de DNS do Load Balancer.
![Balan38](Imagens/5_Balanceamento/Imagem_38.png)
![Balan39](Imagens/5_Balanceamento/Imagem_39.png)

Pausei uma das instâncias para verificar se ainda seria possível acessar a página web.
![Balan40](Imagens/5_Balanceamento/Imagem_40.png)

Pagina web respondendo apenas a instância que não foi pausada.
![Balan41](Imagens/5_Balanceamento/Imagem_41.png)

# **6 - Segurança**

Primeiro criei outro Security Group ```sg-0c3f3af0d9447482b - SG-LoadBalancer``` com a porta 80 (HTTP) aberta. 
![Sec42](Imagens/6_Seguranca/Imagem_42.png)

Criei um novo Load Balancer e adicionei o security group ```sg-0c3f3af0d9447482b - SG-LoadBalancer```. 
![Sec43](Imagens/6_Seguranca/Imagem_43.png)

No Security Group das instâncias ```sg-03ec9f95661f06ed2``` removi a porta 80 (HTTP) que estava aberta para todos e adicionei a porta 80 (HTTP) para o Security Group ```sg-0c3f3af0d9447482b - SG-LoadBalancer```.
![Sec44](Imagens/6_Seguranca/Imagem_44.png)

A página web não estava mais respondendo quando tentava acessar diretamente pelo ip das instâncias.
![Sec45](Imagens/6_Seguranca/Imagem_45.png)
![Sec46](Imagens/6_Seguranca/Imagem_46.png)

A página web só aceita chamadas pelo endereço de DNS do Load Balancer.
![Sec47](Imagens/6_Seguranca/Imagem_47.png)
![Sec48](Imagens/6_Seguranca/Imagem_48.png)
