1) Kernel e Boot loader 

Primeiro reiniciei a máquna, quando chegou no GRUB apertei ```ESC``` para interromper o processo de boot.<br> 
Pressionei ```e``` para entrar no modo de edição.<br>
No menu de edição, localizei o parâmetro do kernel ```ro``` e alterei para ```rw``` e adicionei o parametro ```init=/sysroot/bin/sh```<br> 
Pressionei ```Ctrl + X``` para entrar no modo single-user, em seguida executei o comando ```chroot /sysroot``` para coverter root file system em modo de leitura e escrita.<br>  
Após isso foi possível trocar a senha do root.<br> 
Executei os comandos abaixo:
```
:/# passwd root
:/# touch /.autorelabel
:/# exit
:/# reboot
```

Adicionei o usuario vagrant no grupo wheel para dar permissao de sudo para o usuario 
```
[root@centos8 vagrant]# usermod -aG wheel vagrant
[root@centos8 vagrant]# gpasswd -a vagrant wheel
Adding user to the group wheel
```

2) Usuários

2.1 Criação de usuários

Criação do grupo getup

```[root@centos8 vagrant]# groupadd -g2222 getup```

Criação do usuário

```[root@centos8 vagrant]# adduser -u1111 -g2222 getup```

```
[root@centos8 vagrant]# gpasswd -a getup bin
Adding user getup to group bin
[root@centos8 vagrant]# visudo
getup ALL=(ALL) NOPASSWD: ALL 
```

3) SSH

3.1 Autenticação confiável

Para alterar a autenticação por senha, precisa ir no arquivo de configuração do servidor ssh e por ```no``` na parte de permitir senha.
```
[root@centos8 /]# vim /etc/ssh/sshd_config
PasswordAuthentication no 
```

Reiniciar o serviço ssh

```[root@centos8 /]# systemctl restart sshd```

Chave gerada para o usuário vagrant
```
angela@angela:~$ ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/home/angela/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/angela/.ssh/id_rsa
Your public key has been saved in /home/angela/.ssh/id_rsa.pub
```

Comando para pegar a chave pública
```
angela@angela:~$ cat ~/.ssh/id_rsa.pub
```

Adicionar a chave pública ao arquivo authorized do usuário vagrant
```
[root@centos8 /]# vim /home/vagrant/.ssh/authorized_keys 
```

Para obter o endereço IP público da VM
```
[root@centos8 /]# ip addr show dev eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:43:2b:e6 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.116/24 brd 192.168.0.255 scope global dynamic noprefixroute eth1
       valid_lft 1678sec preferred_lft 1678sec
```

Para acessar o servidor via ssh
```
angela@angela:~$ ssh vagrant@192.168.0.116
```
3.2 Criação de chaves

Criação da chave do tipo ECDSA
```
angela@angela:~$ ssh-keygen -t ecdsa -b 521
Generating public/private ecdsa key pair.
Enter file in which to save the key (/home/angela/.ssh/id_ecdsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/angela/.ssh/id_ecdsa
Your public key has been saved in /home/angela/.ssh/id_ecdsa.pub
The key fingerprint is:
SHA256:Ye1+1cesQwNDaHdVvPr00rYyPGef3K+1/Z6rKE+3h0c angela@angela
The key's randomart image is:
+---[ECDSA 521]---+
|           ..  o+|
|         .o.. . .|
|        o...o.  .|
|       . o   o = |
|        S .   = =|
|         .   + E.|
|          ..o.B.o|
|         ...o*+OX|
|          oo o@%&|
+----[SHA256]-----+
```
Comando para pegar a chave pública
```
angela@angela:~$ cat ~/.ssh/id_ecdsa.pub
```
Adicionar a chave pública ao arquivo authorized do usuário vagrant
```
[root@centos8 /]# vim /home/vagrant/.ssh/authorized_keys 
```

Para acessar o servidor via ssh
```
angela@angela:~$ ssh vagrant@192.168.0.116
```

3.3 Análise de logs e configurações ssh

Decodificou o base64 do arquivo rsa
```
angela@angela:~/formando-devops/desafio-linux$ cat id_rsa-desafio-linux-devel.gz.b64 | base64 --decode > id_rsa-desafio-linux-devel.gz
```
Comando para descompactar o arquivo
```
angela@angela:~/formando-devops/desafio-linux$ gunzip -d id_rsa-desafio-linux-devel.gz
```
Para exibir caracteres não printáveis e observei que no fim da linha tem ```^M$``` que é a quebra de linha do windows
```
angela@angela:~/formando-devops/desafio-linux$ cat -vet id_rsa-desafio-linux-devel
```
Para remover a quebra de linha ```^M$```
```
angela@angela:~/formando-devops/desafio-linux$ dos2unix id_rsa-desafio-linux-devel
```
Para checar se a quebra de linha tinha sido removida
```
angela@angela:~/formando-devops/desafio-linux$ cat -vet id_rsa-desafio-linux-devel
```
Conexão da máquina no servidor utilizando a chave.
```
angela@angela:~/formando-devops/desafio-linux$ ssh -i id_rsa-desafio-linux-devel devel@192.168.0.116
```
4. Systemd

Para inicializar o serviço
```[root@centos8 .ssh]# systemctl start nginx```

Para iniciar o processo de checagem de erro, foi checado o status do servico nginx. 
```
[root@centos8 .ssh]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Mon 2022-09-05 15:52:04 UTC; 4s ago
  Process: 2802 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=1/FAILURE)
  Process: 2800 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
Sep 05 15:52:04 centos8.localdomain systemd[1]: Starting The nginx HTTP and reverse proxy server...
Sep 05 15:52:04 centos8.localdomain nginx[2802]: nginx: [emerg] invalid number of arguments in "root" directive in /etc/nginx/nginx.conf:45
Sep 05 15:52:04 centos8.localdomain nginx[2802]: nginx: configuration file /etc/nginx/nginx.conf test failed
Sep 05 15:52:04 centos8.localdomain systemd[1]: nginx.service: Control process exited, code=exited status=1
Sep 05 15:52:04 centos8.localdomain systemd[1]: nginx.service: Failed with result 'exit-code'.
Sep 05 15:52:04 centos8.localdomain systemd[1]: Failed to start The nginx HTTP and reverse proxy server.
```

Os primeiros erros identificados foram a falta do “ ; “ na linha anterior a linha 45 e porta que estava 90 e o serviço http roda na porta 80)

Correção dos erros relatados acima
```
[root@centos8 /]# vim /etc/nginx/nginx.conf
```
Após a correção tentei reiniciar o serviço novamente e retornou o seguinte erro:

```[root@centos8 nginx]# systemctl start nginx
Job for nginx.service failed because the control process exited with error code.
See "systemctl status nginx.service" and "journalctl -xe" for details.
```
Novamente cheguei o status do nginx.

```
[root@centos8 nginx]# systemctl status nginx.service
Output
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Mon 2022-09-05 17:40:47 UTC; 13s ago
  Process: 4010 ExecStart=/usr/sbin/nginx -BROKEN (code=exited, status=1/FAILURE)
  Process: 4007 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 4006 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)

Sep 05 17:40:47 centos8.localdomain systemd[1]: Starting The nginx HTTP and reverse proxy server...
Sep 05 17:40:47 centos8.localdomain nginx[4007]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Sep 05 17:40:47 centos8.localdomain nginx[4007]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Sep 05 17:40:47 centos8.localdomain nginx[4010]: nginx: invalid option: "B"
Sep 05 17:40:47 centos8.localdomain systemd[1]: nginx.service: Control process exited, code=exited status=1
Sep 05 17:40:47 centos8.localdomain systemd[1]: nginx.service: Failed with result 'exit-code'.
Sep 05 17:40:47 centos8.localdomain systemd[1]: Failed to start The nginx HTTP and reverse proxy server.
```

Acessei esse arquivo porque é nele que estão as opções de inicialização do do serviço e na linha do ```ExecStart=/usr/sbin/nginx``` tinha um ```-BROKEN``` e após conferir no manual pude checar que essa opção não existe para iniciar o nginx.
```
[root@centos8 nginx]# vim /usr/lib/systemd/system/nginx.service
```

Como o arquivo  nginx.service foi alterado é necessário rodar este comando para atualizar o daemon
```
[root@centos8 nginx]# systemctl daemon-reload
```

Tentei iniciar novamente o serviço do nginx.

```
[root@centos8 nginx]# systemctl start nginx
```

E cheguei que o serviço estava rodando normalmente.

```
[root@centos8 nginx]# systemctl status nginx.service 
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Mon 2022-09-05 17:45:28 UTC; 3s ago
  Process: 4116 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 4113 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 4112 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 4117 (nginx)
    Tasks: 3 (limit: 11402)
   Memory: 4.9M
   CGroup: /system.slice/nginx.service
           ├─4117 nginx: master process /usr/sbin/nginx
           ├─4118 nginx: worker process
           └─4119 nginx: worker process

Sep 05 17:45:28 centos8.localdomain systemd[1]: Starting The nginx HTTP and reverse proxy server...
Sep 05 17:45:28 centos8.localdomain nginx[4113]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Sep 05 17:45:28 centos8.localdomain nginx[4113]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Sep 05 17:45:28 centos8.localdomain systemd[1]: Started The nginx HTTP and reverse proxy server.
```

```
[root@centos8 nginx]# curl http://127.0.0.1
Duas palavrinhas pra você: para, béns!
```

5. SSL

5.1 Criação de certificados

Adicionou uma entrada de DNS ao arquivo hosts 127.0.0.1 www.desafio.local desafio.local 
```
[root@centos8 vagrant]# vim /etc/hosts
```

Ping para checar estava respondendo
```
[root@centos8 vagrant]# ping desafio.local
64 bytes from localhost (127.0.0.1): icmp_seq=1 ttl=64 time=0.037 ms
64 bytes from localhost (127.0.0.1): icmp_seq=2 ttl=64 time=0.050 ms
```

Utilizei o Easy-RSA para criar a autoridade certificadora.
Primeiramente tentei instalar os pacotes epel-release e easy-rsa e sempre retornava o erro: Warning: failed loading '/etc/yum.repos.d/CentOS-Linux-Extras.repo', skipping.

Então conclui que havia um erro neste repositório e abrir esse repositório para verificar qual era o erro. 
```
[vagrant@centos8 ~]$ sudo vim /etc/yum.repos.d/CentOS-Linux-Extras.repo
```
Comparando com outro repositório percebi que uma linha que deveria estar comentada estava descomentada, comentei essa linha e executei novamente os comandos. 

Para atualizar o repositório
```
[vagrant@centos8 ~]$ sudo dnf update
```
Como o erro  do repositório corrigido instalei os pacotes epel-release e easy-rsa
```
[vagrant@centos8 ~]$ sudo dnf install epel-release
[vagrant@centos8 ~]$ sudo dnf install easy-rsa
```
Criação de uma pasta no diretório home do usuário vagrant para criação dos certificados
```
[vagrant@centos8 ~]$ mkdir ~/easy-rsa
```
Criação de links simbólicos apontando para os arquivos do easy-rsa
```
[vagrant@centos8 ~]$ ln -s /usr/share/easy-rsa/3/* ~/easy-rsa/
```
Restringe o acesso ao diretório, de modo que apenas o proprietário possa acessá-lo
```
[vagrant@centos8 ~]$ chmod 700 /home/vagrant/easy-rsa
```
Inicialização das chaves
```
[vagrant@centos8 ~]$ cd ~/easy-rsa
[vagrant@centos8 easy-rsa]$ ./easyrsa init-pki
init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /home/vagrant/easy-rsa/pki
```

Após esses passos, teremos um diretório com todos os arquivos necessários para criar uma autoridade de certificação. 
```
[vagrant@centos8 easy-rsa]$ vim vars
```
E adicionei as linhas abaixo:
```
set_var EASYRSA_REQ_COUNTRY    "UK"
set_var EASYRSA_REQ_PROVINCE   "GREAT MANCHESTER"
set_var EASYRSA_REQ_CITY       "Stockport"
set_var EASYRSA_REQ_ORG        "Angela"
set_var EASYRSA_REQ_EMAIL      "admin@example.com"
set_var EASYRSA_REQ_OU         "Community"
```

Criação do par de chaves raiz público-privada para a autoridade de certificação, o comando ```nopass``` foi utilizado para nao ser solicitado a colocar uma senha sempre que interagir com a ```CA```
```
[vagrant@centos8 easy-rsa]$ ./easyrsa build-ca nopass
Using SSL: openssl OpenSSL 1.1.1k  FIPS 25 Mar 2021
Generating RSA private key, 2048 bit long modulus (2 primes)
...............+++++
..................................................+++++
e is 65537 (0x010001)
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:desafio, desafio.local, www.desafio.local

CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/home/vagrant/easy-rsa/pki/ca.crt
```

5.2 Uso de certificados

A pasta cert foi criada no diretório home do vagrant para juntar os arquivos ```ca.crt``` e ```ca.key```
```
[vagrant@centos8 ~]$ mkdir cert
[vagrant@centos8 ~]$ cp easy-rsa/pki/ca.crt cert/desafio.local.crt
[vagrant@centos8 ~]$ cp easy-rsa/pki/private/ca.key cert/desafio.local.key
[vagrant@centos8 cert]$ sudo vim /etc/nginx/nginx.conf

server {
        listen       443 ssl default_server; (Mudança da porta para 443 / https - Adicionei o tipo de certificado ssl)
        listen       [::]:443 ssl default_server; (Mudança da porta para 443 / https - Adicionei o tipo de certificado ssl)
        server_name  desafio.local; (Para responder para o desafio.local)
        root         /usr/share/nginx/html;
        #As linhas abaixo sao para especificar o caminho dos certificados)
        ssl_certificate /home/vagrant/cert/desafio.local.crt;
        ssl_certificate_key /home/vagrant/cert/desafio.local.key;
```        
Reiniciar o serviço do nginx e atualizar as alterações realizadas
```
[vagrant@centos8 cert]$ sudo systemctl restart nginx
[vagrant@centos8 cert]$ systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Tue 2022-09-06 16:59:04 UTC; 2s ago
  Process: 6619 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 6616 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 6615 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 6620 (nginx)
    Tasks: 3 (limit: 11402)
   Memory: 5.0M
   CGroup: /system.slice/nginx.service
           ├─6620 nginx: master process /usr/sbin/nginx
           ├─6621 nginx: worker process
           └─6622 nginx: worker process

Sep 06 16:59:04 centos8.localdomain systemd[1]: Starting The nginx HTTP and reverse proxy server...
Sep 06 16:59:04 centos8.localdomain nginx[6616]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Sep 06 16:59:04 centos8.localdomain nginx[6616]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Sep 06 16:59:04 centos8.localdomain systemd[1]: Started The nginx HTTP and reverse proxy server.
```

Executei o curl com a opcao -k para não checar o certificado.
```
[vagrant@centos8 cert]$ curl -k https://www.desafio.local
Duas palavrinhas pra você: para, béns!
```

6. Rede

6.1 Firewall
```
[vagrant@centos8 ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=63 time=18.1 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=63 time=14.6 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=63 time=14.3 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=63 time=16.8 ms
64 bytes from 8.8.8.8: icmp_seq=5 ttl=63 time=18.2 ms
64 bytes from 8.8.8.8: icmp_seq=6 ttl=63 time=13.5 ms
```

6.2 HTTP
```
[vagrant@centos8 ~]$ curl -i  https://httpbin.org/response-headers?hello=world
HTTP/2 200 
date: Tue, 06 Sep 2022 18:55:38 GMT
content-type: application/json
content-length: 89
server: gunicorn/19.9.0
hello: world
access-control-allow-origin: *
access-control-allow-credentials: true

{
  "Content-Length": "89", 
  "Content-Type": "application/json", 
  "hello": "world"
}
```
6.3 Logs
```
[vagrant@centos8 ~]$ sudo vim /etc/logrotate.d/nginx

/var/log/nginx/* {
    weekly
    rotate 3
    size 10M
    compress
    delaycompress
}

[vagrant@centos8 ~]$ sudo logrotate -d /etc/logrotate.d/nginx
WARNING: logrotate in debug mode does nothing except printing debug messages!  Consider using verbose mode (-v) instead if this is not what you want.

reading config file /etc/logrotate.d/nginx
Reading state from file: /var/lib/logrotate/logrotate.status
Allocating hash table for state file, size 64 entries
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state

Handling 1 logs

rotating pattern: /var/log/nginx/*  10485760 bytes (3 rotations)
empty log files are rotated, old logs are removed
considering log /var/log/nginx/access.log
Creating new state
  Now: 2022-09-06 19:22
  Last rotated at 2022-09-06 19:00
  log does not need rotating (log size is below the 'size' threshold)
considering log /var/log/nginx/error.log
Creating new state
  Now: 2022-09-06 19:22
  Last rotated at 2022-09-06 19:00
  log does not need rotating (log size is below the 'size' threshold)
```

7. Filesystem

7.1 Expandir partição LVM
```
[vagrant@centos8 ~]$ sudo pvresize --setphysicalvolumesize 5G /dev/sdb1
  WARNING: /dev/sdb1: Overriding real size 1.00 GiB. You could lose data.
/dev/sdb1: Requested size 5.00 GiB exceeds real size 1.00 GiB. Proceed?  [y/n]: y
  WARNING: /dev/sdb1: Pretending size is 10485760 not 2097152 sectors.
  Physical volume "/dev/sdb1" changed
  1 physical volume(s) resized or updated / 0 physical volume(s) not resized

[vagrant@centos8 ~]$ sudo pvdisplay 
WARNING: Device /dev/sdb1 has size of 2097152 sectors which is smaller than corresponding PV size of 10483712 sectors. Was device resized?
  WARNING: One or more devices used as PVs in VG data_vg have changed sizes.
  --- Physical volume ---
  PV Name               /dev/sdb1
  VG Name               data_vg
  PV Size               <5.00 GiB / not usable 3.00 MiB
  Allocatable           yes 
  PE Size               4.00 MiB
  Total PE              1279
  Free PE               1024
  Allocated PE          255
  PV UUID               XTxaEN-Cze7-7EWl-vWWE-7keb-p2Mq-mqJpiH

[vagrant@centos8 ~]$ sudo lvextend -l 100%FREE /dev/data_vg/data_lv
WARNING: Device /dev/sdb1 has size of 2097152 sectors which is smaller than corresponding PV size of 10483712 sectors. Was device resized?
  WARNING: One or more devices used as PVs in VG data_vg have changed sizes.
  Size of logical volume data_vg/data_lv changed from 1020.00 MiB (255 extents) to 4.00 GiB (1024 extents).
  device-mapper: resume ioctl on  (253:2) failed: Invalid argument
  Unable to resume data_vg-data_lv (253:2).
  Problem reactivating logical volume data_vg/data_lv.
  Releasing activation in critical section.
  libdevmapper exiting with 1 device(s) still suspended.

[vagrant@centos8 ~]$ lvdisplay 
WARNING: Device /dev/sdb1 has size of 2097152 sectors which is smaller than corresponding PV size of 10483712 sectors. Was device resized?
  WARNING: One or more devices used as PVs in VG data_vg have changed sizes.
  --- Logical volume ---
  LV Path                /dev/data_vg/data_lv
  LV Name                data_lv
  VG Name                data_vg
  LV UUID                sKjwY1-FbUA-D80u-U2sa-xCgU-1HZl-KYMmWO
  LV Write Access        read/write
  LV Creation host, time centos8.localdomain, 2022-09-02 18:01:23 +0000
  LV Status              suspended
  # open                 0
  LV Size                4.00 GiB
  Current LE             1024
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:2
```

7.2 Criar partição LVM
```
[vagrant@centos8 ~]$ sudo fdisk /dev/sdb

Welcome to fdisk (util-linux 2.32.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): 

Using default response p.
Partition number (2-4, default 2): 
First sector (2099200-20971519, default 2099200): 
Last sector, +sectors or +size{K,M,G,T,P} (2099200-20971519, default 20971519): +5G  

Created a new partition 2 of type 'Linux' and of size 5 GiB.

Command (m for help): t
Partition number (1,2, default 2): 
Hex code (type L to list all codes): 8e

Changed type of partition 'Linux' to 'Linux LVM'

[vagrant@centos8 ~]$ sudo vgcreate vgdesafio1 /dev/sdb2
Output:
Volume group "vgdesafio1" successfully created

[vagrant@centos8 ~]$ sudo vgdisplay vgdesafio1
 --- Volume group ---
  VG Name               		vgdesafio1
  System ID             
  Format                    		lvm2
  Metadata Areas        	        1
  Metadata Sequence No  	        1
  VG Access             		read/write
  VG Status             		resizable
  MAX LV                		0
  Cur LV                		0
  Open LV               		0
  Max PV                		0
  Cur PV                		1
  Act PV                		1
  VG Size               		<5.00 GiB
  PE Size               		4.00 MiB
  Total PE              		1279
  Alloc PE / Size       		0 / 0   
  Free  PE / Size       		1279 / <5.00 GiB
  VG UUID               		fJOjRg-ZT91-ZbVo-P1k7-qo5B-TLtf-QyJTQh

[vagrant@centos8 ~]$ sudo lvcreate -L 5G -n lvdesafio1 vgdesafio1
Volume group "vgdesafio1" has insufficient free space (1279 extents): 1280 required.

[vagrant@centos8 ~]$ sudo lvcreate -l 100%FREE -n lvdesafio1 vgdesafio1
Logical volume "lvdesafio1" created.

[vagrant@centos8 ~]$ sudo lvdisplay 
  --- Logical volume ---
  LV Path                		/dev/vgdesafio1/lvdesafio1
  LV Name                		lvdesafio1
  VG Name                		vgdesafio1
  LV UUID               		5yqok8-zkRj-upmB-Wo7u-zmd6-ynH3-KGAIY1
  LV Write Access        	        read/write
  LV Creation host, time 	        centos8.localdomain, 2022-09-06 22:24:37 +0000
  LV Status              		available
  # open                 		0
  LV Size               	 	<5.00 GiB
  Current LE             		1279
  Segments               		1
  Allocation             		inherit
  Read ahead sectors     	        auto
  - currently set to     		256
  Block device           		253:2
```

7.3 Criar partição XFS
```
[vagrant@centos8 ~]$ sudo fdisk /dev/sdc 

Welcome to fdisk (util-linux 2.32.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0xa779c782.

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p 
Partition number (1-4, default 1): 1
First sector (2048-20971519, default 2048): 
Last sector, +sectors or +size{K,M,G,T,P} (2048-20971519, default 20971519): 

Created a new partition 1 of type 'Linux' and of size 10 GiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

[vagrant@centos8 ~]$ sudo fdisk -l /dev/sdc
Output:
Disk /dev/sdc: 10 GiB, 10737418240 bytes, 20971520 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xa779c782

Device     Boot Start      End  Sectors Size Id Type
/dev/sdc1        2048 20971519 20969472  10G 83 Linux

[vagrant@centos8 ~]$ sudo mkfs.xfs /dev/sdc1
Output:
meta-data=/dev/sdc1                          isize=512    	agcount=4, agsize=655296 blks
        		=                    sectsz=512         attr=2, projid32bit=1
         		=                    crc=1        	finobt=1, sparse=1, rmapbt=0
         		=                    reflink=1
data     	        =                    bsize=4096         blocks=2621184, imaxpct=25
         		=                    sunit=0      	swidth=0 blks
naming   	        =version 2           bsize=4096         ascii-ci=0, ftype=1
log      		=internal log	     bsize=4096         blocks=2560, version=2
         		=                    sectsz=512         sunit=0 blks, lazy-count=1
realtime 	        =none                extsz=4096         blocks=0, rtextents=0

[vagrant@centos8 ~]$ sudo mount /dev/sdc1 /mnt
[vagrant@centos8 ~]$ df -h
Filesystem                  			Size  	Used 	    Avail     Use%  	Mounted on
devtmpfs                     		        891M    0  	    891M      0%      	/dev
tmpfs                        			909M    0  	    909M      0% 	/dev/shm
tmpfs                        			909M    17M  	    893M      2% 	/run
tmpfs                        			909M    0  	    909M      0% 	/sys/fs/cgroup
/dev/mapper/cl_centos8-root  	                125G  	2.7G  	    123G      3% 	/
tmpfs                        			182M    0  	    182M      0% 	/run/user/1000
tmpfs                        			182M    0  	    182M      0% 	/run/user/0
/dev/sdc1                     		        10G     104M  	    9.9G      2% 	/mnt
```
