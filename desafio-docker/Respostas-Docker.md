## DESAFIO DOCKER<br>

1 -
```
angela@angela:~$  sudo docker run alpine hostname
a3a378117df8
```
```
angela@angela:~$ sudo docker container ls -a
CONTAINER ID   IMAGE                  COMMAND                  CREATED         STATUS                     PORTS                                      NAMES
a3a378117df8   alpine                 "hostname"               8 seconds ago   Exited (0) 7 seconds ago                                              sad_mayer
595a4b83bc6d   nginx:1.22             "/docker-entrypoint.…"   2 hours ago     Up 2 hours                 0.0.0.0:8080->80/tcp, :::8080->80/tcp      charming_hawking
77c966f03d9b   kindest/node:v1.25.2   "/usr/local/bin/entr…"   10 days ago     Up 3 days                  0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   meuk8s-worker2
5de479d3e49a   kindest/node:v1.25.2   "/usr/local/bin/entr…"   10 days ago     Up 3 days                  127.0.0.1:41897->6443/tcp                  meuk8s-control-plane
7383678db489   kindest/node:v1.25.2   "/usr/local/bin/entr…"   10 days ago     Up 3 days                                                             meuk8s-worker
```
```
angela@angela:~$ sudo docker container prune -f
Deleted Containers:
a3a378117df8072b9ffab24e0a30a451beab0f0b64949290eab88c5e656e3f49

Total reclaimed space: 0B
```
```
angela@angela:~$ sudo docker container ls -a
CONTAINER ID   IMAGE                  COMMAND                  CREATED       STATUS       PORTS                                      NAMES
595a4b83bc6d   nginx:1.22             "/docker-entrypoint.…"   2 hours ago   Up 2 hours   0.0.0.0:8080->80/tcp, :::8080->80/tcp      charming_hawking
77c966f03d9b   kindest/node:v1.25.2   "/usr/local/bin/entr…"   10 days ago   Up 3 days    0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   meuk8s-worker2
5de479d3e49a   kindest/node:v1.25.2   "/usr/local/bin/entr…"   10 days ago   Up 3 days    127.0.0.1:41897->6443/tcp                  meuk8s-control-plane
7383678db489   kindest/node:v1.25.2   "/usr/local/bin/entr…"   10 days ago   Up 3 days                                               meuk8s-worker
```
2 -
```
angela@angela:~$ sudo docker container run -d -p 8080:80 nginx:1.22
Unable to find image 'nginx:1.22' locally
1.22: Pulling from library/nginx
e9995326b091: Pull complete 
6cc239fad459: Pull complete 
55bbc49cb4de: Pull complete 
a3949c6b4890: Pull complete 
b9e696b15b8a: Pull complete 
a8acafbf647e: Pull complete 
Digest: sha256:c5dcbba623c5313452a0a359a97782f6bde8fdce4fd45fd75bd0463ac9150ae3
Status: Downloaded newer image for nginx:1.22
31b7f91d4d569bfa30ef0868899ce08f8ac642c2ae5cbfa4bb87ed7ab89378d3
```
```
angela@angela:~$ sudo docker ps
CONTAINER ID   IMAGE                  COMMAND                  CREATED         STATUS         PORTS                                      NAMES
31b7f91d4d56   nginx:1.22             "/docker-entrypoint.…"   4 minutes ago   Up 4 minutes   0.0.0.0:8080->80/tcp, :::8080->80/tcp      pensive_shamir
77c966f03d9b   kindest/node:v1.25.2   "/usr/local/bin/entr…"   10 days ago     Up 3 days      0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   meuk8s-worker2
5de479d3e49a   kindest/node:v1.25.2   "/usr/local/bin/entr…"   10 days ago     Up 3 days      127.0.0.1:41897->6443/tcp                  meuk8s-control-plane
7383678db489   kindest/node:v1.25.2   "/usr/local/bin/entr…"   10 days ago     Up 3 days                                                 meuk8s-worker
```
```
angela@angela:~$ curl localhost:8080
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
3 -
```
angela@angela:~/nginx$ sudo docker cp 595a4b83bc6d:/etc/nginx/conf.d/default.conf .
```
```
angela@angela:~/nginx$ ls
default.conf
```
```
angela@angela:~/nginx$ sudo docker container run -d -p 8081:90 --mount type=bind,src=$(pwd)/default.conf,dst=/etc/nginx/conf.d/default.conf,ro nginx:1.22
e2129c09b98ca0c1c547958b65336a4be8ff4888560e8537c82c42ee67b8dd00
```
```
angela@angela:~/nginx$ sudo docker ps
CONTAINER ID   IMAGE                  COMMAND                  CREATED          STATUS          PORTS                                           NAMES
e2129c09b98c   nginx:1.22             "/docker-entrypoint.…"   36 seconds ago   Up 34 seconds   80/tcp, 0.0.0.0:8081->90/tcp, :::8081->90/tcp   xenodochial_buck
d37e46ab75f8   nginx                  "/docker-entrypoint.…"   31 minutes ago   Up 31 minutes   80/tcp                                          wonderful_black
595a4b83bc6d   nginx:1.22             "/docker-entrypoint.…"   5 hours ago      Up 5 hours      0.0.0.0:8080->80/tcp, :::8080->80/tcp           charming_hawking
77c966f03d9b   kindest/node:v1.25.2   "/usr/local/bin/entr…"   10 days ago      Up 3 days       0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp        meuk8s-worker2
5de479d3e49a   kindest/node:v1.25.2   "/usr/local/bin/entr…"   10 days ago      Up 3 days       127.0.0.1:41897->6443/tcp                       meuk8s-control-plane
7383678db489   kindest/node:v1.25.2   "/usr/local/bin/entr…"   10 days ago      Up 3 days                                                       meuk8s-worker
```
```
angela@angela:~/nginx$ sudo docker exec e2129c09b98c sh -c "cat /etc/nginx/conf.d/default.conf | grep listen" 
    listen       90;
    listen  [::]:90;
    # proxy the PHP scripts to Apache listening on 127.0.0.1:80
    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
```
4 -
```
angela@angela:~/python$ ls
Dockerfile  main.py
```
```
angela@angela:~/python$ cat main.py 
def main():
   print('Hello World in Python!')

if __name__ == '__main__':
  main()

```
```
angela@angela:~/python$ cat Dockerfile 
FROM python:latest
ADD main.py /
CMD [ "python", "./main.py"]
```
```
angela@angela:~/python$ sudo docker build -t desafio-docker .
Sending build context to Docker daemon  3.072kB
Step 1/3 : FROM python:latest
 ---> 00cd1fb8bdcc
Step 2/3 : ADD main.py /
 ---> e666412cf550
Step 3/3 : CMD [ "python", "./main.py"]
 ---> Running in 7a1b10aef353
Removing intermediate container 7a1b10aef353
 ---> 94bf293faf5d
Successfully built 94bf293faf5d
Successfully tagged desafio-docker:latest
```
```
angela@angela:~/python$ sudo docker image ls 
REPOSITORY            TAG       IMAGE ID       CREATED         SIZE
desafio-docker        latest    94bf293faf5d   5 minutes ago   932MB
python                latest    00cd1fb8bdcc   5 days ago      932MB
nginx                 1.22      0ccb2559380c   6 days ago      142MB
nginx                 latest    76c69feac34e   6 days ago      142MB
hashicorp/terraform   light     e15959079c8f   4 weeks ago     87.3MB
kindest/node          <none>    434e3cca4019   5 weeks ago     910MB
```
```
angela@angela:~/python$ sudo  docker run desafio-docker 
Hello World in Python!
```

5 -
```
angela@angela:~$ sudo  docker container run -d --cpus 0.5 -m 128m nginx
d37e46ab75f8927916f588a9816488260faed578e2ca46d499844eaa1c2f971a
```
```
angela@angela:~$ sudo docker container ls -a
CONTAINER ID   IMAGE                  COMMAND                  CREATED              STATUS              PORTS                                      NAMES
d37e46ab75f8   nginx                  "/docker-entrypoint.…"   About a minute ago   Up About a minute   80/tcp                                     wonderful_black
595a4b83bc6d   nginx:1.22             "/docker-entrypoint.…"   5 hours ago          Up 5 hours          0.0.0.0:8080->80/tcp, :::8080->80/tcp      charming_hawking
77c966f03d9b   kindest/node:v1.25.2   "/usr/local/bin/entr…"   10 days ago          Up 3 days           0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   meuk8s-worker2
5de479d3e49a   kindest/node:v1.25.2   "/usr/local/bin/entr…"   10 days ago          Up 3 days           127.0.0.1:41897->6443/tcp                  meuk8s-control-plane
7383678db489   kindest/node:v1.25.2   "/usr/local/bin/entr…"   10 days ago          Up 3 days                                                      meuk8s-worker
```
```
angela@angela:~$ sudo docker container inspect d37e46ab75f8 | egrep "\"Memory\"|NanoCpus"
            "Memory": 134217728,
            "NanoCpus": 500000000,
```
6 -
```
angela@angela:~$ sudo docker system prune
WARNING! This will remove:
  - all stopped containers
  - all networks not used by at least one container
  - all dangling images
  - all dangling build cache

Are you sure you want to continue? [y/N] 
```

7 -
```
 $ docker image inspect <IMAGE ID>
```
```
$ sudo docker image history <IMAGE ID>
```