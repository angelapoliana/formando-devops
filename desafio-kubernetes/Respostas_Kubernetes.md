# DESAFIO KUBERNETES<br>

1 - Criação do namespace ```meusite```:
```
angela@angela:~$ sudo kubectl create namespace meusite
```
```
angela@angela:~$ sudo kubectl get namespaces
NAME                 STATUS   AGE
default              Active   3d7h
kube-node-lease      Active   3d7h
kube-public          Active   3d7h
kube-system          Active   3d7h
local-path-storage   Active   3d7h
meusite              Active   111m
```
Criação do template do pod:
```
angela@angela:~$ sudo kubectl run serverweb --image nginx --dry-run=client -o yaml > pod_serverweb.yaml
```

```
angela@angela:~$ cat pod_serverweb.yaml 
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels: 
    app: ovo 
    run: serverweb
  name: serverweb
  namespace: meusite
spec:
  containers:
  - image: nginx
    name: serverweb
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

```
sudo kubectl create -f pod_serverweb.yaml
```

```
angela@angela:~$ sudo kubectl --namespace meusite logs -l app=ovo --all-containers | grep erro
```
2 - Visualizando as labels taints do node ```meuk8s-control-plane```:
```
angela@angela:~$ sudo kubectl describe node meuk8s-control-plane | grep -i taint
Taints: node-role.kubernetes.io/control-plane:NoSchedule
```
Visualizando as labels taints do node meuk8s-worker:
```
angela@angela:~$ sudo kubectl describe node meuk8s-worker | grep -i taint
Taints: <none>
```
Visualizando as labels taints do node meuk8s-worker2:
```
angela@angela:~$ sudo kubectl describe node meuk8s-worker2 | grep -i taint
Taints: <none>
```
Criação do manifesto do recurso para ser executado em todos os nós do cluster, expecificando uma tolerancia:
```
kubectl create deployment --dry-run=client -o yaml --image=nginx:latest meu-spread > nginx-deployment-template.yaml
```
```
angela@angela:~$ cat nginx-deployment-template.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: meu-spread
  name: meu-spread
spec:
  replicas: 1
  selector:
    matchLabels:
      app: meu-spread
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: meu-spread
    spec:
      containers:
      - image: nginx:latest
        name: nginx
        resources: {}
      tolerations:
      - key: "key1"
        operator: "Exists"
        effect: "NoSchedule"
status: {}
```
```
angela@angela:~$ sudo kubectl create -f nginx-deployment-template.yaml
deployment.apps/meu-spread created
```
Visualizando o deployment:
```
angela@angela:~$ sudo kubectl get deployments.apps
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
meu-spread   1/1     1            1           2m36s
```
Escalando o deployment do nginx para 5 réplicas:
```
angela@angela:~$ sudo kubectl scale deployment meu-spread --replicas=5
deployment.apps/meu-spread scaled
angela@angela:~$ sudo kubectl get deployments.apps
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
meu-spread   5/5     5            5           4m3s
```
Visualizando os detalhes dos pods e podendo observar que o recurso foi executado em todos os nós do cluster:
```
angela@angela:~$ sudo kubectl get pods -o wide
NAME                          READY   STATUS    RESTARTS   AGE    IP            NODE                   NOMINATED NODE   READINESS GATES
meu-spread-5d85874cf4-6v6jj   1/1     Running   0          83s    10.244.2.26   meuk8s-worker2         <none>           <none>
meu-spread-5d85874cf4-8cp2r   1/1     Running   0          83s    10.244.2.27   meuk8s-worker2         <none>           <none>
meu-spread-5d85874cf4-9dpxk   1/1     Running   0          83s    10.244.1.75   meuk8s-worker          <none>           <none>
meu-spread-5d85874cf4-gtp8w   1/1     Running   0          83s    10.244.0.10   meuk8s-control-plane   <none>           <none>
meu-spread-5d85874cf4-vt2hw   1/1     Running   0          5m8s   10.244.1.74   meuk8s-worker          <none>           <none>
```
3 - 
```
angela@angela:~$ cat web-server-init.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: meu-webserver
  name: meu-webserver
spec:
  replicas: 1
  selector:
    matchLabels:
      app: meu-webserver
  template:
    metadata:
      labels:
        app: meu-webserver
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
        volumeMounts:
        - name: workdir
          mountPath: /usr/share/nginx/html
      initContainers:
      - name: index
        image: alpine
        command: ['sh', '-c','touch /app/index.html && echo "HelloGetup" > /app/index.html']
        volumeMounts:
        - name: workdir
          mountPath: "/app"
      dnsPolicy: Default
      volumes:
      - name: workdir
        emptyDir: {}
```
```
angela@angela:~$ sudo kubectl get pods 
NAME                             READY   STATUS    RESTARTS   AGE
meu-webserver-779cdcd8dc-gvg4p   1/1     Running   0          20m
pombo-8587cc96bb-46nh5           1/1     Running   0          99m
pombo-8587cc96bb-5jc4p           1/1     Running   0          99m
pombo-8587cc96bb-66btz           1/1     Running   0          99m
pombo-8587cc96bb-vd982           1/1     Running   0          99m
```
```
angela@angela:~$ sudo kubectl get deployments
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
meu-webserver   1/1     1            1           21m
pombo           4/4     4            4           108m
```
```
angela@angela:~$ sudo kubectl describe pod meu-webserver-779cdcd8dc-gvg4p
Name:             meu-webserver-779cdcd8dc-gvg4p
Namespace:        default
Priority:         0
Service Account:  default
Node:             meuk8s-worker2/172.18.0.4
Start Time:       Fri, 28 Oct 2022 15:10:01 +0100
Labels:           app=meu-webserver
                  pod-template-hash=779cdcd8dc
Annotations:      <none>
Status:           Running
IP:               10.244.2.11
IPs:
  IP:           10.244.2.11
Controlled By:  ReplicaSet/meu-webserver-779cdcd8dc
Init Containers:
  index:
    Container ID:  containerd://e87e8af2200ba23def906ac3e59dd77a2187c62f7f4da78c154beb33107d3152
    Image:         alpine
    Image ID:      docker.io/library/alpine@sha256:bc41182d7ef5ffc53a40b044e725193bc10142a1243f395ee852a8d9730fc2ad
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      touch /app/index.html && echo "HelloGetup" > /app/index.html
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Fri, 28 Oct 2022 15:10:05 +0100
      Finished:     Fri, 28 Oct 2022 15:10:05 +0100
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /app from workdir (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-7zqkx (ro)
Containers:
  nginx:
    Container ID:   containerd://be15242e096b284ce2228cff22510cb0ba1a5ad501c30a28d59b41f0428da92b
    Image:          nginx
    Image ID:       docker.io/library/nginx@sha256:47a8d86548c232e44625d813b45fd92e81d07c639092cd1f9a49d98e1fb5f737
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Fri, 28 Oct 2022 15:10:07 +0100
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /usr/share/nginx/html from workdir (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-7zqkx (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  workdir:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:     
    SizeLimit:  <unset>
  kube-api-access-7zqkx:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  16m   default-scheduler  Successfully assigned default/meu-webserver-779cdcd8dc-gvg4p to meuk8s-worker2
  Normal  Pulling    16m   kubelet            Pulling image "alpine"
  Normal  Pulled     16m   kubelet            Successfully pulled image "alpine" in 2.755970142s
  Normal  Created    16m   kubelet            Created container index
  Normal  Started    16m   kubelet            Started container index
  Normal  Pulling    16m   kubelet            Pulling image "nginx"
  Normal  Pulled     16m   kubelet            Successfully pulled image "nginx" in 1.101104919s
  Normal  Created    16m   kubelet            Created container nginx
  Normal  Started    16m   kubelet            Started container nginx
```
```
angela@angela:~$ sudo kubectl exec -ti meu-webserver-779cdcd8dc-gvg4p  -- cat /usr/share/nginx/html/index.html
Defaulted container "nginx" out of: nginx, index (init)
HelloGetup
```
4- Criação do deploy ```meuweb``` com a imagem ```nginx:1.16```. Com o ```nodeName``` foi feita a seleção de que o deploy seria executado exclusivamente no node ```meuk8s-control-plane```.

```
angela@angela:~$ kubectl create deployment --dry-run=client -o yaml --image=nginx:1.16 meuweb > nginx-deployment-template.yaml
```
```
angela@angela:~$ cat nginx-deployment-template.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: meuweb
  name: meuweb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: meuweb
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: meuweb
    spec:
      containers:
      - image: nginx:1.16
        name: nginx
        resources: {}
      tolerations:
      - key: "key1"
        operator: "Exists"
        effect: "NoSchedule"
      nodeName: meuk8s-control-plane
status: {}
```
```
angela@angela:~$ sudo kubectl create -f nginx-deployment-template.yaml
deployment.apps/meuweb created
```
Visualizando o deployment:
```
angela@angela:~$ sudo kubectl get deployments.apps
NAME     READY   UP-TO-DATE   AVAILABLE   AGE
meuweb   1/1     1            1           67s
```
Visualizando os detalhes do pod e que ele foi executado no node ```meuk8s-control-plane```:
```
angela@angela:~$ sudo kubectl get pods -o wide
NAME                      READY   STATUS    RESTARTS   AGE     IP            NODE                   NOMINATED NODE   READINESS GATES
meuweb-6b775dffbf-8h8nl   1/1     Running   0          2m15s   10.244.0.14   meuk8s-control-plane   <none>           <none>
```
5 - Alteração da imagem do pod: 
```
angela@angela:~$ sudo kubectl set image deployment/meuweb nginx=nginx:1.19
deployment.apps/meuweb image updated
```
```
angela@angela:~$ sudo kubectl describe pod meuweb 
Name:             meuweb-67d9b8547b-vtxhb
Namespace:        default
Priority:         0
Service Account:  default
Node:             meuk8s-control-plane/172.18.0.2
Start Time:       Tue, 25 Oct 2022 15:57:23 +0100
Labels:           app=meuweb
                  pod-template-hash=67d9b8547b
Annotations:      <none>
Status:           Running
IP:               10.244.0.17
IPs:
  IP:           10.244.0.17
Controlled By:  ReplicaSet/meuweb-67d9b8547b
Containers:
  nginx:
    Container ID:   containerd://035dd32834a05a37bb2d757fac0f3881d2f81c6a5cc4ff214401829bd9d2cc12
    Image:          nginx:1.19
    Image ID:       docker.io/library/nginx@sha256:df13abe416e37eb3db4722840dd479b00ba193ac6606e7902331dcea50f4f1f2
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Tue, 25 Oct 2022 15:57:24 +0100
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-bs9v9 (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-bs9v9:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 key1:NoSchedule op=Exists
                             node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason   Age   From     Message
  ----    ------   ----  ----     -------
  Normal  Pulled   95s   kubelet  Container image "nginx:1.19" already present on machine
  Normal  Created  95s   kubelet  Created container nginx
  Normal  Started  95s   kubelet  Started container nginx
```
6 - 
```
angela@angela:~$ sudo kubectl create namespace ingress-nginx-2
namespace/ingress-nginx-2 created
```
```
angela@angela:~$ sudo helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
"ingress-nginx" already exists with the same configuration, skipping
```
```
angela@angela:~$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "ingress-nginx" chart repository
Update Complete. ⎈Happy Helming!⎈
```
```
angela@angela:~$ helm search repo ingress-nginx
NAME                       	CHART VERSION	APP VERSION	DESCRIPTION                                       
ingress-nginx/ingress-nginx	4.3.0        	1.4.0      	Ingress controller for Kubernetes using NGINX a...
```
```
angela@angela:~$ sudo helm upgrade ingress-nginx-2 ingress-nginx/ingress-nginx \
--namespace ingress-nginx-2 \
--set controller.hostPort.enabled=true \
--set controller.service.type=NodePort \
--set controller.updateStrategy.type=Recreate
Release "ingress-nginx-2" has been upgraded. Happy Helming!
NAME: ingress-nginx-2
LAST DEPLOYED: Thu Oct 27 22:03:01 2022
NAMESPACE: ingress-nginx-2
STATUS: deployed
REVISION: 2
TEST SUITE: None
NOTES:
The ingress-nginx controller has been installed.
Get the application URL by running these commands:
  export HTTP_NODE_PORT=$(kubectl --namespace ingress-nginx-2 get services -o jsonpath="{.spec.ports[0].nodePort}" ingress-nginx-2-controller)
  export HTTPS_NODE_PORT=$(kubectl --namespace ingress-nginx-2 get services -o jsonpath="{.spec.ports[1].nodePort}" ingress-nginx-2-controller)
  export NODE_IP=$(kubectl --namespace ingress-nginx-2 get nodes -o jsonpath="{.items[0].status.addresses[1].address}")

  echo "Visit http://$NODE_IP:$HTTP_NODE_PORT to access your application via HTTP."
  echo "Visit https://$NODE_IP:$HTTPS_NODE_PORT to access your application via HTTPS."

An example Ingress that makes use of the controller:
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: example
    namespace: foo
  spec:
    ingressClassName: nginx
    rules:
      - host: www.example.com
        http:
          paths:
            - pathType: Prefix
              backend:
                service:
                  name: exampleService
                  port:
                    number: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
      - hosts:
        - www.example.com
        secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls
```
```
angela@angela:~$  sudo kubectl --namespace ingress-nginx-2 get services -o wide -w ingress-nginx-2-controller
NAME                         TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)                      AGE     SELECTOR
ingress-nginx-2-controller   NodePort   10.96.50.50   <none>        80:31750/TCP,443:30838/TCP   3m48s   app.kubernetes.io/component=controller,app.kubernetes.io/instance=ingress-nginx-2,app.kubernetes.io/name=ingress-nginx
```
7 -
```
angela@angela:~$ sudo kubectl create deployment pombo --image nginx:1.11.9-alpine --replicas=4
[sudo] password for angela: 
deployment.apps/pombo created
```
```
angela@angela:~$ sudo kubectl describe deployment pombo
Name:                   pombo
Namespace:              default
CreationTimestamp:      Fri, 28 Oct 2022 13:43:12 +0100
Labels:                 app=pombo
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=pombo
Replicas:               4 desired | 4 updated | 4 total | 4 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=pombo
  Containers:
   nginx:
    Image:        nginx:1.11.9-alpine
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   pombo-8587cc96bb (4/4 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  16s   deployment-controller  Scaled up replica set pombo-8587cc96bb to 4
```
```
angela@angela:~$ sudo kubectl set image deployment pombo nginx=nginx:1.16 --record
[sudo] password for angela: 
Flag --record has been deprecated, --record will be removed in the future
deployment.apps/pombo image updated
```
```
angela@angela:~$ sudo kubectl describe deployment pombo
Name:                   pombo
Namespace:              default
CreationTimestamp:      Fri, 28 Oct 2022 13:43:12 +0100
Labels:                 app=pombo
Annotations:            deployment.kubernetes.io/revision: 2
                        kubernetes.io/change-cause: kubectl set image deployment pombo nginx=nginx:1.16 --record=true
Selector:               app=pombo
Replicas:               4 desired | 4 updated | 4 total | 4 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=pombo
  Containers:
   nginx:
    Image:        nginx:1.16
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   pombo-ffc8f6748 (4/4 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  3m27s  deployment-controller  Scaled up replica set pombo-8587cc96bb to 4
  Normal  ScalingReplicaSet  15s    deployment-controller  Scaled up replica set pombo-ffc8f6748 to 1
  Normal  ScalingReplicaSet  15s    deployment-controller  Scaled down replica set pombo-8587cc96bb to 3 from 4
  Normal  ScalingReplicaSet  15s    deployment-controller  Scaled up replica set pombo-ffc8f6748 to 2 from 1
  Normal  ScalingReplicaSet  14s    deployment-controller  Scaled down replica set pombo-8587cc96bb to 2 from 3
  Normal  ScalingReplicaSet  14s    deployment-controller  Scaled up replica set pombo-ffc8f6748 to 3 from 2
  Normal  ScalingReplicaSet  14s    deployment-controller  Scaled down replica set pombo-8587cc96bb to 1 from 2
  Normal  ScalingReplicaSet  14s    deployment-controller  Scaled up replica set pombo-ffc8f6748 to 4 from 3
  Normal  ScalingReplicaSet  13s    deployment-controller  Scaled down replica set pombo-8587cc96bb to 0 from 1
```
```
angela@angela:~$ sudo kubectl set image deployment pombo nginx=nginx:1.19 --record
Flag --record has been deprecated, --record will be removed in the future
deployment.apps/pombo image updated
```
```
angela@angela:~$ sudo kubectl describe deployment pombo
Name:                   pombo
Namespace:              default
CreationTimestamp:      Fri, 28 Oct 2022 13:43:12 +0100
Labels:                 app=pombo
Annotations:            deployment.kubernetes.io/revision: 3
                        kubernetes.io/change-cause: kubectl set image deployment pombo nginx=nginx:1.19 --record=true
Selector:               app=pombo
Replicas:               4 desired | 2 updated | 5 total | 3 available | 2 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=pombo
  Containers:
   nginx:
    Image:        nginx:1.19
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    ReplicaSetUpdated
OldReplicaSets:  pombo-ffc8f6748 (3/3 replicas created)
NewReplicaSet:   pombo-5f4dbbfcc9 (2/2 replicas created)
Events:
  Type    Reason             Age              From                   Message
  ----    ------             ----             ----                   -------
  Normal  ScalingReplicaSet  5m8s             deployment-controller  Scaled up replica set pombo-8587cc96bb to 4
  Normal  ScalingReplicaSet  116s             deployment-controller  Scaled up replica set pombo-ffc8f6748 to 1
  Normal  ScalingReplicaSet  116s             deployment-controller  Scaled down replica set pombo-8587cc96bb to 3 from 4
  Normal  ScalingReplicaSet  116s             deployment-controller  Scaled up replica set pombo-ffc8f6748 to 2 from 1
  Normal  ScalingReplicaSet  115s             deployment-controller  Scaled down replica set pombo-8587cc96bb to 2 from 3
  Normal  ScalingReplicaSet  115s             deployment-controller  Scaled up replica set pombo-ffc8f6748 to 3 from 2
  Normal  ScalingReplicaSet  115s             deployment-controller  Scaled down replica set pombo-8587cc96bb to 1 from 2
  Normal  ScalingReplicaSet  115s             deployment-controller  Scaled up replica set pombo-ffc8f6748 to 4 from 3
  Normal  ScalingReplicaSet  114s             deployment-controller  Scaled down replica set pombo-8587cc96bb to 0 from 1
  Normal  ScalingReplicaSet  3s (x3 over 3s)  deployment-controller  (combined from similar events): Scaled up replica set pombo-5f4dbbfcc9 to 2 from 1
```
```
angela@angela:~$ sudo kubectl rollout history deployment pombo
deployment.apps/pombo 
REVISION  CHANGE-CAUSE
1         <none>
2         kubectl set image deployment pombo nginx=nginx:1.16 --record=true
3         kubectl set image deployment pombo nginx=nginx:1.19 --record=true

```
```
angela@angela:~$ sudo kubectl rollout undo deployment pombo --to-revision=1
deployment.apps/pombo rolled back
```
```
angela@angela:~$ sudo kubectl describe deployment pombo
Name:                   pombo
Namespace:              default
CreationTimestamp:      Fri, 28 Oct 2022 13:43:12 +0100
Labels:                 app=pombo
Annotations:            deployment.kubernetes.io/revision: 4
Selector:               app=pombo
Replicas:               4 desired | 4 updated | 4 total | 4 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=pombo
  Containers:
   nginx:
    Image:        nginx:1.11.9-alpine
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   pombo-8587cc96bb (4/4 replicas created)
Events:
  Type    Reason             Age                  From                   Message
  ----    ------             ----                 ----                   -------
  Normal  ScalingReplicaSet  7m58s                deployment-controller  Scaled up replica set pombo-8587cc96bb to 4
  Normal  ScalingReplicaSet  4m46s                deployment-controller  Scaled up replica set pombo-ffc8f6748 to 1
  Normal  ScalingReplicaSet  4m46s                deployment-controller  Scaled down replica set pombo-8587cc96bb to 3 from 4
  Normal  ScalingReplicaSet  4m46s                deployment-controller  Scaled up replica set pombo-ffc8f6748 to 2 from 1
  Normal  ScalingReplicaSet  4m45s                deployment-controller  Scaled down replica set pombo-8587cc96bb to 2 from 3
  Normal  ScalingReplicaSet  4m45s                deployment-controller  Scaled up replica set pombo-ffc8f6748 to 3 from 2
  Normal  ScalingReplicaSet  4m45s                deployment-controller  Scaled down replica set pombo-8587cc96bb to 1 from 2
  Normal  ScalingReplicaSet  4m45s                deployment-controller  Scaled up replica set pombo-ffc8f6748 to 4 from 3
  Normal  ScalingReplicaSet  4m44s                deployment-controller  Scaled down replica set pombo-8587cc96bb to 0 from 1
  Normal  ScalingReplicaSet  4s (x16 over 2m53s)  deployment-controller  (combined from similar events): Scaled down replica set pombo-5f4dbbfcc9 to 0 from 1
```

##### FAZER INGRESS

8 -
```
angela@angela:~$ sudo kubectl create deployment guardaroupa --image=redis --port=6379
deployment.apps/guardaroupa created
```
```
angela@angela:~$ sudo kubectl expose deployment guardaroupa --type=ClusterIP --port=6379
service/guardaroupa exposed
```
```
angela@angela:~$ sudo kubectl get svc
NAME                 TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
balaclava-svc        LoadBalancer   10.96.208.171   <pending>     6379:32246/TCP   24h
guardaroupa          ClusterIP      10.96.70.14     <none>        6379/TCP         19s
kubernetes           ClusterIP      10.96.0.1       <none>        443/TCP          5d12h
nginx                ClusterIP      10.96.205.70    <none>        80/TCP           2d8h
nginx-loadbalancer   LoadBalancer   10.96.245.209   <pending>     80:31222/TCP     24h
```
9 - Manifesto para criação do StatefulSet:
```angela@angela:~$ cat statefulsts.yaml 
apiVersion: v1
kind: Service
metadata:
  name: nginx
  namespace: backend
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: meusiteset
  namespace: backend
spec:
  selector:
    matchLabels:
      app: nginx 
  serviceName: "nginx"
  replicas: 3 
  minReadySeconds: 0
  template:
    metadata:
      labels:
        app: nginx
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: volume-data
          mountPath: /data
  volumeClaimTemplates:
  - metadata:
      name: volume-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
```
```
angela@angela:~$ sudo kubectl create -f statefulsts.yaml 
service/nginx created
statefulset.apps/meusiteset created
```
```
angela@angela:~$ sudo kubectl describe statefulset meusiteset -n backend
Name:               meusiteset
Namespace:          backend
CreationTimestamp:  Thu, 27 Oct 2022 21:16:53 +0100
Selector:           app=nginx
Labels:             <none>
Annotations:        <none>
Replicas:           3 desired | 3 total
Update Strategy:    RollingUpdate
  Partition:        0
Pods Status:        3 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:        nginx
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:
      /data from volume-data (rw)
  Volumes:  <none>
Volume Claims:
  Name:          volume-data
  StorageClass:  
  Labels:        <none>
  Annotations:   <none>
  Capacity:      1Gi
  Access Modes:  [ReadWriteOnce]
Events:
  Type    Reason            Age   From                    Message
  ----    ------            ----  ----                    -------
  Normal  SuccessfulCreate  52s   statefulset-controller  create Claim volume-data-meusiteset-0 Pod meusiteset-0 in StatefulSet meusiteset success
  Normal  SuccessfulCreate  52s   statefulset-controller  create Pod meusiteset-0 in StatefulSet meusiteset successful
  Normal  SuccessfulCreate  45s   statefulset-controller  create Claim volume-data-meusiteset-1 Pod meusiteset-1 in StatefulSet meusiteset success
  Normal  SuccessfulCreate  45s   statefulset-controller  create Pod meusiteset-1 in StatefulSet meusiteset successful
  Normal  SuccessfulCreate  39s   statefulset-controller  create Claim volume-data-meusiteset-2 Pod meusiteset-2 in StatefulSet meusiteset success
  Normal  SuccessfulCreate  39s   statefulset-controller  create Pod meusiteset-2 in StatefulSet meusiteset successful
```
10 - Criação do namespace ```backend```:
```
angela@angela:~$ sudo kubectl create namespace backend 
namespace/backend created

angela@angela:~$ sudo kubectl get namespaces
NAME                 STATUS   AGE
backend              Active   4s
default              Active   4d9h
kube-node-lease      Active   4d9h
kube-public          Active   4d9h
kube-system          Active   4d9h
local-path-storage   Active   4d9h
```
Manifesto para criação do deployment:
```
angela@angela:~$ kubectl create deployment --dry-run=client -o yaml --image=redis balaclava > redis-deployment-template.yaml
```
```
angela@angela:~$ cat redis-deployment-template.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    backend: balaclava
    minhachave: semvalor
  name: balaclava
  namespace: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      backend: balaclava
      minhachave: semvalor
  strategy: {}
  template:
    metadata:
      labels:
        backend: balaclava
        minhachave: semvalor
    spec:
      containers:
      - image: redis
        name: redis
        ports:
        - containerPort: 6379
        resources: {}
status: {}
```
Criação do deployment a partir do manifesto:
```
angela@angela:~$ sudo kubectl create -f redis-deployment-template.yaml 
deployment.apps/balaclava created
```
Deployment criado:
```
angela@angela:~$ sudo kubectl get deployments -n backend
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
balaclava   2/2     2            2           32s
```
ReplicaSet criado pelo deployment:
```
angela@angela:~$ sudo kubectl get rs -n backend
NAME                   DESIRED   CURRENT   READY   AGE
balaclava-546c9548c6   2         2         2       68s
```
Labels de cada pod:
```
angela@angela:~$ sudo kubectl get pods --show-labels -n backend
NAME                         READY   STATUS    RESTARTS   AGE    LABELS
balaclava-546c9548c6-2bncx   1/1     Running   0          110s   backend=balaclava,minhachave=semvalor,pod-template-hash=546c9548c6
balaclava-546c9548c6-cswwt   1/1     Running   0          110s   backend=balaclava,minhachave=semvalor,pod-template-hash=546c9548c6
```
Labels do ReplicaSet:
```
angela@angela:~$ sudo kubectl get rs --show-labels -n backend
NAME                   DESIRED   CURRENT   READY   AGE     LABELS
balaclava-546c9548c6   2         2         2       2m12s   backend=balaclava,minhachave=semvalor,pod-template-hash=546c9548c6
```
Labels do Deployment:
```
angela@angela:~$ sudo kubectl get deployments --show-labels -n backend
NAME        READY   UP-TO-DATE   AVAILABLE   AGE     LABELS
balaclava   2/2     2            2           2m31s   backend=balaclava,minhachave=semvalor
```
11 - 
```
angela@angela:~$ cat redis-deployment-template.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    backend: balaclava
    minhachave: semvalor
  name: balaclava
  namespace: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      backend: balaclava
      minhachave: semvalor
  strategy: {}
  template:
    metadata:
      labels:
        backend: balaclava
        minhachave: semvalor
    spec:
      containers:
      - image: redis
        name: redis
        ports:
        - containerPort: 6379
        resources: {}
---
apiVersion: v1
kind: Service
metadata:
  name: balaclava-svc
  labels:
    backend: balaclava
    minhachave: semvalor
  namespace: backend    
  annotations:
    oci.oraclecloud.com/load-balancer-type: "lb"
spec:
  type: LoadBalancer
  ports:
  - port: 6379
  selector:
    backend: balaclava
    minhachave: semvalor
```
```
angela@angela:~$ sudo kubectl create -f redis-deployment-template.yaml 
deployment.apps/balaclava created
service/balaclava-svc created
```
```
angela@angela:~$ sudo kubectl get all -n backend
NAME                             READY   STATUS    RESTARTS   AGE
pod/balaclava-546c9548c6-lbdg5   1/1     Running   0          42s
pod/balaclava-546c9548c6-tl2pz   1/1     Running   0          42s

NAME                    TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
service/balaclava-svc   LoadBalancer   10.96.38.209   <pending>     6379:31320/TCP   42s

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/balaclava   2/2     2            2           42s

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/balaclava-546c9548c6   2         2         2       42s
```
```
angela@angela:~$ sudo kubectl describe service balaclava-svc
Name:                     balaclava-svc
Namespace:                default
Labels:                   backend=balaclava
                          minhachave=semvalor
Annotations:              oci.oraclecloud.com/load-balancer-type: lb
Selector:                 backend=balaclava,minhachave=semvalor
Type:                     LoadBalancer
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.96.208.171
IPs:                      10.96.208.171
Port:                     <unset>  6379/TCP
TargetPort:               6379/TCP
NodePort:                 <unset>  32246/TCP
Endpoints:                <none>
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```
12 - Criação do namespace ```segredosdesucesso```:
```
angela@angela:~$ sudo kubectl create namespace segredosdesucesso
namespace/segredosdesucesso created

angela@angela:~$ sudo kubectl get namespace 
NAME                 STATUS   AGE
default              Active   5d3h
kube-node-lease      Active   5d3h
kube-public          Active   5d3h
kube-system          Active   5d3h
local-path-storage   Active   5d3h
segredosdesucesso    Active   14s
```
Criação do arquivo ```chave-secreta.txt``` para armazenar o conteudo da chave:
```
angela@angela:~$ echo -n "aW5ncmVzcy1uZ2lueCAgIGluZ3Jlc3MtbmdpbngtY29udHJvbGxlciAgICAgICAgICAgICAgICAg
     ICAgICAgICAgICAgTG9hZEJhbGFuY2VyICAgMTAuMjMzLjE3Ljg0ICAgIDE5Mi4xNjguMS4zNSAg
     IDgwOjMxOTE2L1RDUCw0NDM6MzE3OTQvVENQICAgICAyM2ggICBhcHAua3ViZXJuZXRlcy5pby9j
     b21wb25lbnQ9Y29udHJvbGxlcixhcHAua3ViZXJuZXRlcy5pby9pbnN0YW5jZT1pbmdyZXNzLW5n
     aW54LGFwcC5rdWJlcm5ldGVzLmlvL25hbWU9aW5ncmVzcy1uZ" > chave-secreta.txt
```
Criação do objeto secret:
```
angela@angela:~$ sudo kubectl create secret generic meusegredo --from-literal=segredo=azul --from-file=chave-secreta.txt --namespace=segredosdesucesso
secret/meusegredo created
```
Detalhes do objeto:
```
angela@angela:~$ sudo kubectl describe secret meusegredo -n segredosdesucesso
Name:         meusegredo
Namespace:    segredosdesucesso
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
chave-secreta.txt:  377 bytes
segredo:            4 bytes
```
Manifesto da secret ```meusegredo```:
```
angela@angela:~$ sudo kubectl get secret meusegredo -o yaml -n segredosdesucesso
apiVersion: v1
data:
  chave-secreta.txt: YVc1bmNtVnpjeTF1WjJsdWVDQWdJR2x1WjNKbGMzTXRibWRwYm5ndFkyOXVkSEp2Ykd4bGNpQWdJQ0FnSUNBZ0lDQWdJQ0FnSUNBZwogICAgIElDQWdJQ0FnSUNBZ0lDQWdURzloWkVKaGJHRnVZMlZ5SUNBZ01UQXVNak16TGpFM0xqZzBJQ0FnSURFNU1pNHhOamd1TVM0ek5TQWcKICAgICBJRGd3T2pNeE9URTJMMVJEVUN3ME5ETTZNekUzT1RRdlZFTlFJQ0FnSUNBeU0yZ2dJQ0JoY0hBdWEzVmlaWEp1WlhSbGN5NXBieTlqCiAgICAgYjIxd2IyNWxiblE5WTI5dWRISnZiR3hsY2l4aGNIQXVhM1ZpWlhKdVpYUmxjeTVwYnk5cGJuTjBZVzVqWlQxcGJtZHlaWE56TFc1bgogICAgIGFXNTRMR0Z3Y0M1cmRXSmxjbTVsZEdWekxtbHZMMjVoYldVOWFXNW5jbVZ6Y3kxdVo=
  segredo: YXp1bA==
kind: Secret
metadata:
  creationTimestamp: "2022-10-26T12:53:49Z"
  name: meusegredo
  namespace: segredosdesucesso
  resourceVersion: "629408"
  uid: 58e9998f-8ccb-446d-ae80-87ba047d8030
type: Opaque
```
13 -
```
angela@angela:~$ sudo echo "Angela de Jesus" > index.html && sudo kubectl create namespace site && sudo kubectl create configmap configsite --from-file=index.html --namespace=site
namespace/site created
configmap/configsite created
```
```
angela@angela:~$ sudo kubectl get configmap -n site
NAME               DATA   AGE
configsite         1      67s
kube-root-ca.crt   1      67s
```
14 - Manifesto e criação do recurso ```meudeploy```:
```
angela@angela:~$ cat nginx-deployment-template.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: meudeploy
  name: meudeploy
  namespace: segredosdesucesso
spec:
  replicas: 1
  selector:
    matchLabels:
      app: meudeploy
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: meudeploy
    spec:
      containers:
      - image: nginx:latest
        name: nginx
        volumeMounts:
        - name: volume-segredo
          mountPath: /app
      volumes:
      - name: volume-segredo
        secret:
           secretName: meusegredo
status: {}
```
```
angela@angela:~$ sudo kubectl create -f nginx-deployment-template.yaml 
deployment.apps/meudeploy created
```
```
angela@angela:~$ sudo kubectl describe deployment meudeploy -n segredosdesucesso
Name:                   meudeploy
Namespace:              segredosdesucesso
CreationTimestamp:      Wed, 26 Oct 2022 17:03:24 +0100
Labels:                 app=meudeploy
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=meudeploy
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=meudeploy
  Containers:
   nginx:
    Image:        nginx:latest
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:
      /app from volume-segredo (rw)
  Volumes:
   volume-segredo:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  meusegredo
    Optional:    false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   meudeploy-cbb6cc68b (1/1 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  74s   deployment-controller  Scaled up replica set meudeploy-cbb6cc68b to 1
```
```
angela@angela:~$ sudo kubectl describe pod meudeploy -n segredosdesucesso
Name:             meudeploy-cbb6cc68b-qv699
Namespace:        segredosdesucesso
Priority:         0
Service Account:  default
Node:             meuk8s-worker/172.18.0.3
Start Time:       Wed, 26 Oct 2022 17:03:24 +0100
Labels:           app=meudeploy
                  pod-template-hash=cbb6cc68b
Annotations:      <none>
Status:           Running
IP:               10.244.1.97
IPs:
  IP:           10.244.1.97
Controlled By:  ReplicaSet/meudeploy-cbb6cc68b
Containers:
  nginx:
    Container ID:   containerd://66102eb0de1e661227b7e884072fe93192dc837f6af50b8fa5bc9d06e0f8c8d8
    Image:          nginx:latest
    Image ID:       docker.io/library/nginx@sha256:47a8d86548c232e44625d813b45fd92e81d07c639092cd1f9a49d98e1fb5f737
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Wed, 26 Oct 2022 17:03:26 +0100
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /app from volume-segredo (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-qbsn2 (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  volume-segredo:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  meusegredo
    Optional:    false
  kube-api-access-qbsn2:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  83s   default-scheduler  Successfully assigned segredosdesucesso/meudeploy-cbb6cc68b-qv699 to meuk8s-worker
  Normal  Pulling    82s   kubelet            Pulling image "nginx:latest"
  Normal  Pulled     81s   kubelet            Successfully pulled image "nginx:latest" in 1.093889802s
  Normal  Created    81s   kubelet            Created container nginx
  Normal  Started    81s   kubelet            Started container nginx
```
Verificando se o ```secret``` foi criado corretamente:
```
angela@angela:~$ sudo kubectl exec -ti meudeploy-cbb6cc68b-qv699 -n segredosdesucesso -- ls /app
chave-secreta.txt  segredo
```
```
angela@angela:~$ sudo kubectl exec -ti meudeploy-cbb6cc68b-qv699 -n segredosdesucesso -- cat /app/segredo
azul
```
```
angela@angela:~$ sudo kubectl exec -ti meudeploy-cbb6cc68b-qv699 -n segredosdesucesso -- cat /app/chave-secreta.txt
aW5ncmVzcy1uZ2lueCAgIGluZ3Jlc3MtbmdpbngtY29udHJvbGxlciAgICAgICAgICAgICAgICAg
     ICAgICAgICAgICAgTG9hZEJhbGFuY2VyICAgMTAuMjMzLjE3Ljg0ICAgIDE5Mi4xNjguMS4zNSAg
     IDgwOjMxOTE2L1RDUCw0NDM6MzE3OTQvVENQICAgICAyM2ggICBhcHAua3ViZXJuZXRlcy5pby9j
     b21wb25lbnQ9Y29udHJvbGxlcixhcHAua3ViZXJuZXRlcy5pby9pbnN0YW5jZT1pbmdyZXNzLW5n
     aW54LGFwcC5rdWJlcm5ldGVzLmlvL25hbWU9aW5ncmVzcy1uZ
```
15 - 
```
angela@angela:~$ cat nginx.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: depconfigs
  namespace: site
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2 
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        volumeMounts:
            - name: nginx-index-file
              mountPath: /usr/share/nginx/html/
      volumes:
      - name: nginx-index-file
        configMap:
          name: configsite
```
```
angela@angela:~$ sudo kubectl create -f nginx.yaml 
deployment.apps/depconfigs created
```
```
angela@angela:~$ sudo kubectl get pods -n site
NAME                          READY   STATUS    RESTARTS   AGE
depconfigs-69cd7c5c7f-488c5   1/1     Running   0          2m25s
depconfigs-69cd7c5c7f-cbtdl   1/1     Running   0          2m25s
```
```
angela@angela:~$ sudo kubectl exec -ti depconfigs-69cd7c5c7f-488c5 -n site -- ls /usr/share/nginx/html 
index.html
```
```
sudo kubectl exec -ti depconfigs-69cd7c5c7f-488c5 -n site -- cat /usr/share/nginx/html/index.html 
Angela de Jesus
```
16 - Manifesto e criação do recurso ```meudeploy-2```:
```
angela@angela:~$ cat nginx-deployment-template.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    chaves: secretas
  name: meudeploy-2
  namespace: segredosdesucesso
spec:
  replicas: 1
  selector:
    matchLabels:
      chaves: secretas
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        chaves: secretas
    spec:
      containers:
      - image: nginx:1.16
        name: nginx
        env:
        - name: meu_segredo
          valueFrom:
            secretKeyRef:
              name: meusegredo
              key: segredo
        - name: minha_chave
          valueFrom:
            secretKeyRef:
              name: meusegredo
              key: chave-secreta.txt  
status: {}
```
```
angela@angela:~$ sudo kubectl create -f nginx-deployment-template.yaml
deployment.apps/meudeploy-2 created
```
```
angela@angela:~$ sudo kubectl describe deployment meudeploy-2 -n segredosdesucesso
[sudo] password for angela: 
Name:                   meudeploy-2
Namespace:              segredosdesucesso
CreationTimestamp:      Wed, 26 Oct 2022 17:56:25 +0100
Labels:                 chaves=secretas
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               chaves=secretas
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  chaves=secretas
  Containers:
   nginx:
    Image:      nginx:1.16
    Port:       <none>
    Host Port:  <none>
    Environment:
      meu_segredo:  <set to the key 'segredo' in secret 'meusegredo'>            Optional: false
      minha_chave:  <set to the key 'chave-secreta.txt' in secret 'meusegredo'>  Optional: false
    Mounts:         <none>
  Volumes:          <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   meudeploy-2-74b6c667d5 (1/1 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  10m   deployment-controller  Scaled up replica set meudeploy-2-74b6c667d5 to 1
```
```
angela@angela:~$ sudo kubectl describe pod -n segredosdesucesso
Name:             meudeploy-2-74b6c667d5-z5prs
Namespace:        segredosdesucesso
Priority:         0
Service Account:  default
Node:             meuk8s-worker2/172.18.0.4
Start Time:       Wed, 26 Oct 2022 17:56:25 +0100
Labels:           chaves=secretas
                  pod-template-hash=74b6c667d5
Annotations:      <none>
Status:           Running
IP:               10.244.2.52
IPs:
  IP:           10.244.2.52
Controlled By:  ReplicaSet/meudeploy-2-74b6c667d5
Containers:
  nginx:
    Container ID:   containerd://bbca13a111a47838055961a997b71316279d2321a515aacfc09c2e9727bc0232
    Image:          nginx:1.16
    Image ID:       docker.io/library/nginx@sha256:d20aa6d1cae56fd17cd458f4807e0de462caf2336f0b70b5eeb69fcaaf30dd9c
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Wed, 26 Oct 2022 17:56:26 +0100
    Ready:          True
    Restart Count:  0
    Environment:
      meu_segredo:  <set to the key 'segredo' in secret 'meusegredo'>            Optional: false
      minha_chave:  <set to the key 'chave-secreta.txt' in secret 'meusegredo'>  Optional: false
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-cgvgt (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-cgvgt:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  37s   default-scheduler  Successfully assigned segredosdesucesso/meudeploy-2-74b6c667d5-z5prs to meuk8s-worker2
  Normal  Pulled     36s   kubelet            Container image "nginx:1.16" already present on machine
  Normal  Created    36s   kubelet            Created container nginx
  Normal  Started    36s   kubelet            Started container nginx
```
Listando as variáveis de ambiente dentro do contêiner para verificar se o Secret foi criado:
```
angela@angela:~$ sudo kubectl exec meudeploy-2-74b6c667d5-z5prs -n segredosdesucesso -c nginx -it -- printenv
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=meudeploy-2-74b6c667d5-z5prs
NGINX_VERSION=1.16.1
NJS_VERSION=0.3.8
PKG_RELEASE=1~buster
meu_segredo=azul
minha_chave=aW5ncmVzcy1uZ2lueCAgIGluZ3Jlc3MtbmdpbngtY29udHJvbGxlciAgICAgICAgICAgICAgICAg
     ICAgICAgICAgICAgTG9hZEJhbGFuY2VyICAgMTAuMjMzLjE3Ljg0ICAgIDE5Mi4xNjguMS4zNSAg
     IDgwOjMxOTE2L1RDUCw0NDM6MzE3OTQvVENQICAgICAyM2ggICBhcHAua3ViZXJuZXRlcy5pby9j
     b21wb25lbnQ9Y29udHJvbGxlcixhcHAua3ViZXJuZXRlcy5pby9pbnN0YW5jZT1pbmdyZXNzLW5n
     aW54LGFwcC5rdWJlcm5ldGVzLmlvL25hbWU9aW5ncmVzcy1uZ
KUBERNETES_SERVICE_PORT=443
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
KUBERNETES_SERVICE_HOST=10.96.0.1
TERM=xterm
HOME=/root
```
17 - 
```
angela@angela:~$ sudo kubectl create namespace cabeludo
namespace/cabeludo created

angela@angela:~$ sudo kubectl get namespace 
NAME                 STATUS   AGE
cabeludo             Active   34m
default              Active   5d10h
kube-node-lease      Active   5d10h
kube-public          Active   5d10h
kube-system          Active   5d10h
local-path-storage   Active   5d10h
segredosdesucesso    Active   6h51m
angela@angela:~$ 
```
```
angela@angela:~$ cat nginx-deployment-template.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: cabelo
  name: cabelo
  namespace: cabeludo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cabelo
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: cabelo
    spec:
      containers:
      - image: nginx:latest
        name: nginx
        env:
        - name: USUARIO
          valueFrom:
            secretKeyRef:
              name: acesso
              key: username
        - name: SENHA
          valueFrom:
            secretKeyRef:
              name: acesso
              key: password  
status: {}
```
```
angela@angela:~$ sudo kubectl create -f nginx-deployment-template.yaml 
deployment.apps/cabelo created
```
```
angela@angela:~$ sudo kubectl get pods -n cabeludo
NAME                      READY   STATUS    RESTARTS   AGE
cabelo-5d8b5b769f-z7r5t   1/1     Running   0          80s
```
```
angela@angela:~$ sudo kubectl create secret generic acesso --namespace=cabeludo --from-literal username=pavao --from-literal password=asabranca
secret/acesso created
```
```
angela@angela:~$ sudo kubectl exec cabelo-5d8b5b769f-z7r5t -n cabeludo -c nginx -it -- printenv
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=cabelo-5d8b5b769f-z7r5t
NGINX_VERSION=1.23.2
NJS_VERSION=0.7.7
PKG_RELEASE=1~bullseye
USUARIO=pavao
SENHA=asabranca
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
KUBERNETES_SERVICE_HOST=10.96.0.1
KUBERNETES_SERVICE_PORT=443
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_PORT=443
TERM=xterm
HOME=/root
```
18 - 
```
angela@angela:~$ cat redis-deployment-template.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: redis
  name: redis
  namespace: cachehits
spec:
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
      name: redis
    spec:
      containers:
      - image: redis
        name: redis
        ports:
        - containerPort: 6379
        volumeMounts:
        - mountPath: /data/redis
          name: app-cache
      volumes:
      - name: app-cache
        emptyDir: {}
```
```
angela@angela:~$ sudo kubectl create -f redis-deployment-template.yaml 
deployment.apps/redis created
```
```
angela@angela:~$ sudo kubectl describe deployment redis -n cachehits
Name:                   redis
Namespace:              cachehits
CreationTimestamp:      Thu, 27 Oct 2022 20:53:24 +0100
Labels:                 app=redis
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=redis
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=redis
  Containers:
   redis:
    Image:        redis
    Port:         6379/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:
      /data/redis from app-cache (rw)
  Volumes:
   app-cache:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:     
    SizeLimit:  <unset>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   redis-69568fdd66 (1/1 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  42s   deployment-controller  Scaled up replica set redis-69568fdd66 to 1
```
19- 
```
angela@angela:~$ sudo kubectl create namespace azul && sudo kubectl create deployment basico --image=nginx --port=80 --namespace=azul && sudo kubectl scale deployment/basico --replicas=10 --namespace=azul
namespace/azul created
deployment.apps/basico created
deployment.apps/basico scaled
```
```
angela@angela:~$ sudo kubectl get pods -n azul
NAME                      READY   STATUS    RESTARTS   AGE
basico-86bdfcf757-2zq8b   1/1     Running   0          25s
basico-86bdfcf757-4mmrx   1/1     Running   0          25s
basico-86bdfcf757-5cnnm   1/1     Running   0          25s
basico-86bdfcf757-fp2mq   1/1     Running   0          25s
basico-86bdfcf757-hh8th   1/1     Running   0          25s
basico-86bdfcf757-hlx7p   1/1     Running   0          25s
basico-86bdfcf757-l6bvs   1/1     Running   0          25s
basico-86bdfcf757-qhjdn   1/1     Running   0          25s
basico-86bdfcf757-qjhbh   1/1     Running   0          25s
basico-86bdfcf757-tw2hx   1/1     Running   0          25s

```
```
angela@angela:~$ sudo kubectl get rs -n azul
NAME                DESIRED   CURRENT   READY   AGE
basico-86bdfcf757   10        10        10      40s
```
```
angela@angela:~$ sudo kubectl get deployments -n azul
NAME     READY   UP-TO-DATE   AVAILABLE   AGE
basico   10/10   10           10          53s
```
```
angela@angela:~$ sudo kubectl get namespace
NAME                 STATUS   AGE
azul                 Active   4m41s
default              Active   5d8h
kube-node-lease      Active   5d8h
kube-public          Active   5d8h
kube-system          Active   5d8h
local-path-storage   Active   5d8h
segredosdesucesso    Active   4h55m
```
20-
```
angela@angela:~$ sudo kubectl create namespace frontend && sudo kubectl create deployment site --image=nginx --port=80 --namespace=frontend && sudo kubectl autoscale deployment/site --min=2 --max=5 --cpu-percent=90 --namespace=frontend
namespace/frontend created
deployment.apps/site created
horizontalpodautoscaler.autoscaling/site autoscaled
```
```
angela@angela:~$ sudo kubectl get pods -n frontend
NAME                    READY   STATUS    RESTARTS   AGE
site-5869f8d577-8z9tm   1/1     Running   0          9m52s
site-5869f8d577-z4qm5   1/1     Running   0          10m
```
```
angela@angela:~$ sudo kubectl get deployment -n frontend
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
site   2/2     2            2           10m
```
```
angela@angela:~$ sudo kubectl get rs -n frontend
NAME              DESIRED   CURRENT   READY   AGE
site-5869f8d577   2         2         2       8m6s
```
Checando o status do HorizontalPodAutoscaler:
```
angela@angela:~$ sudo kubectl get hpa -n frontend
NAME   REFERENCE         TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
site   Deployment/site   <unknown>/90%   2         5         2          7m15s
```
21 - 
```
sudo kubectl get secrets/piadas -n meusegredos  -o jsonpath='{.data.segredos}' | base64 -d
```
22 - Como meu cluster possui dois nodes workers, fiz a marcação nos dois nodes com NoSchedule:
```
angela@angela:~$ sudo kubectl taint node meuk8s-worker2 key1=value1:NoSchedule
node/meuk8s-worker2 tainted
angela@angela:~$ sudo kubectl taint node meuk8s-worker key1=value1:NoSchedule
node/meuk8s-worker tainted
```
Podemos observar que temos 6 pods alocados no ```meuk8s-worker``` e no ```meuk8s-worker2```:
```
angela@angela:~$ sudo kubectl get pods -o wide
NAME                      READY   STATUS    RESTARTS   AGE   IP            NODE             NOMINATED NODE   READINESS GATES
meuweb-7ffbfc8df8-9bscr   1/1     Running   0          15m   10.244.1.95   meuk8s-worker    <none>           <none>
meuweb-7ffbfc8df8-gwblk   1/1     Running   0          15m   10.244.2.49   meuk8s-worker2   <none>           <none>
meuweb-7ffbfc8df8-hjn26   1/1     Running   0          28m   10.244.2.44   meuk8s-worker2   <none>           <none>
meuweb-7ffbfc8df8-jnsrw   1/1     Running   0          15m   10.244.1.94   meuk8s-worker    <none>           <none>
meuweb-7ffbfc8df8-kkdz8   1/1     Running   0          15m   10.244.2.50   meuk8s-worker2   <none>           <none>
meuweb-7ffbfc8df8-zdvx2   1/1     Running   0          15m   10.244.1.93   meuk8s-worker    <none>           <none>
```
Aumentando a quantidade de réplicas para 8 podemos ver observar que as novas réplicas ficaram órfãs esperando aparecer um node com as prioridades adequadas para o Schedule:
```
angela@angela:~$ sudo kubectl get pods -o wide
NAME                      READY   STATUS    RESTARTS   AGE   IP            NODE             NOMINATED NODE   READINESS GATES
meuweb-7ffbfc8df8-9bscr   1/1     Running   0          16m   10.244.1.95   meuk8s-worker    <none>           <none>
meuweb-7ffbfc8df8-gwblk   1/1     Running   0          16m   10.244.2.49   meuk8s-worker2   <none>           <none>
meuweb-7ffbfc8df8-hjn26   1/1     Running   0          30m   10.244.2.44   meuk8s-worker2   <none>           <none>
meuweb-7ffbfc8df8-jnsrw   1/1     Running   0          16m   10.244.1.94   meuk8s-worker    <none>           <none>
meuweb-7ffbfc8df8-kkdz8   1/1     Running   0          16m   10.244.2.50   meuk8s-worker2   <none>           <none>
meuweb-7ffbfc8df8-sjbdj   0/1     Pending   0          11s   <none>        <none>           <none>           <none>
meuweb-7ffbfc8df8-zdvx2   1/1     Running   0          16m   10.244.1.93   meuk8s-worker    <none>           <none>
meuweb-7ffbfc8df8-zgmmz   0/1     Pending   0          11s   <none>        <none>           <none>           <none>
```

23 - Podemos observar pods no node ``` meuk8s-worker``` e no ``` meuk8s-worker2```:
```
angela@angela:~$ sudo kubectl get pods -o wide
NAME                      READY   STATUS    RESTARTS   AGE     IP            NODE             NOMINATED NODE   READINESS GATES
meuweb-7ffbfc8df8-2hdkk   1/1     Running   0          2m51s   10.244.1.92   meuk8s-worker    <none>           <none>
meuweb-7ffbfc8df8-5fc64   1/1     Running   0          2m51s   10.244.1.90   meuk8s-worker    <none>           <none>
meuweb-7ffbfc8df8-9p2kb   1/1     Running   0          2m51s   10.244.1.91   meuk8s-worker    <none>           <none>
meuweb-7ffbfc8df8-hjn26   1/1     Running   0          12m     10.244.2.44   meuk8s-worker2   <none>           <none>
meuweb-7ffbfc8df8-vhhsf   1/1     Running   0          2m51s   10.244.2.45   meuk8s-worker2   <none>           <none>
```
Com o comando ```kube kubectl drain``` o node ```meuk8s-worker``` foi esvaziado:
```
angela@angela:~$ sudo kubectl drain meuk8s-worker --ignore-daemonsets
node/meuk8s-worker already cordoned
Warning: ignoring DaemonSet-managed Pods: kube-system/kindnet-b6z5v, kube-system/kube-proxy-cmvlg
evicting pod default/meuweb-7ffbfc8df8-2hdkk
evicting pod default/meuweb-7ffbfc8df8-5fc64
evicting pod default/meuweb-7ffbfc8df8-9p2kb
pod/meuweb-7ffbfc8df8-5fc64 evicted
pod/meuweb-7ffbfc8df8-2hdkk evicted
pod/meuweb-7ffbfc8df8-9p2kb evicted
node/meuk8s-worker drained
```
Agora todos os pods estão no node ```meuk8s-worker2```:
```
angela@angela:~$ sudo kubectl get pods -o wide
NAME                      READY   STATUS    RESTARTS   AGE     IP            NODE             NOMINATED NODE   READINESS GATES
meuweb-7ffbfc8df8-2j8mv   1/1     Running   0          8s      10.244.2.48   meuk8s-worker2   <none>           <none>
meuweb-7ffbfc8df8-fw5g7   1/1     Running   0          8s      10.244.2.47   meuk8s-worker2   <none>           <none>
meuweb-7ffbfc8df8-hjn26   1/1     Running   0          13m     10.244.2.44   meuk8s-worker2   <none>           <none>
meuweb-7ffbfc8df8-hls2p   1/1     Running   0          8s      10.244.2.46   meuk8s-worker2   <none>           <none>
meuweb-7ffbfc8df8-vhhsf   1/1     Running   0          3m13s   10.244.2.45   meuk8s-worker2   <none>           <none>
```
24 - Usando o ```nodeName``` é uma forma de fazer selecao de nodes. O ```nodeName``` é um campo na especificação do pod. Na atividade 4 usei o ```nodeName``` para garantir que o pode fosse executado exclusivamente no node ```meuk8s-control-plane```.

25 - Criação do namespace ```developer``` e da serviceaccount ```userx```:
```
angela@angela:~$ sudo kubectl create namespace developer && sudo kubectl create serviceaccount userx --namespace=developer
[sudo] password for angela: 
namespace/developer created
serviceaccount/userx created
```
```
angela@angela:~$ sudo kubectl get serviceaccount -n developer
NAME      SECRETS   AGE
default   0         92m
userx     0         92m
```
Manifesto para criação da role e da rolebinding:
```
angela@angela:~$ cat rbac.yaml 
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: developer
  name: role-desafio
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

---

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: role-desafio-bind
  namespace: developer
subjects:
- kind: ServiceAccount
  name: userx
  namespace: developer
roleRef:
  kind: Role 
  name: role-desafio
  apiGroup: rbac.authorization.k8s.io
```
```
angela@angela:~$ sudo kubectl create -f rbac.yaml 
role.rbac.authorization.k8s.io/role-desafio created
rolebinding.rbac.authorization.k8s.io/role-desafio-bind created
```
```
angela@angela:~$ sudo kubectl describe role -n developer
Name:         role-desafio
Labels:       <none>
Annotations:  <none>
PolicyRule:
  Resources         Non-Resource URLs  Resource Names  Verbs
  ---------         -----------------  --------------  -----
  pods/log          []                 []              [get list watch create update patch delete]
  pods              []                 []              [get list watch create update patch delete]
  deployments.apps  []                 []              [get list watch create update patch delete]
```
```
angela@angela:~$ sudo kubectl describe rolebinding -n developer
Name:         role-desafio-bind
Labels:       <none>
Annotations:  <none>
Role:
  Kind:  Role
  Name:  role-desafio
Subjects:
  Kind            Name   Namespace
  ----            ----   ---------
  ServiceAccount  userx  developer
```
26 -
```
angela@angela:~$ openssl genrsa -out jane.key 2048
```
```
angela@angela:~$ openssl req -new -key jane.key -out jane.csr 
```
```
 cat jane.csr | base64 | tr -d "\n"
 ```
 ```
 angela@angela:~$ sudo kubectl apply -f k8s-csr.yaml 
[sudo] password for angela: 
certificatesigningrequest.certificates.k8s.io/jane created
```
```
angela@angela:~$ sudo kubectl get csr
NAME   AGE   SIGNERNAME                            REQUESTOR          REQUESTEDDURATION   CONDITION
jane   80s   kubernetes.io/kube-apiserver-client   kubernetes-admin   <none>              Pending
```
```
angela@angela:~$ sudo kubectl certificate approve jane
certificatesigningrequest.certificates.k8s.io/jane approved
```
```
NAME   AGE     SIGNERNAME                            REQUESTOR          REQUESTEDDURATION   CONDITION
jane   2m49s   kubernetes.io/kube-apiserver-client   kubernetes-admin   <none>              Approved,Issued
```
```
angela@angela:~$ sudo kubectl get csr jane -o jsonpath='{.status.certificate}'| base64 -d > jane.crt
```
```
angela@angela:~$ cat rbac.yaml 
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: frontend
  name: list-pods
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["list"]

---

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: list-pods-bind
  namespace: frontend
subjects:
- kind: User
  name: jane
  namespace: frontend 
roleRef:
  kind: Role 
  name: list-pods
  apiGroup: rbac.authorization.k8s.io
```
```
angela@angela:~$ sudo kubectl apply -f rbac.yaml 
role.rbac.authorization.k8s.io/list-pods created
rolebinding.rbac.authorization.k8s.io/list-pods-bind created
```
```
angela@angela:~$ sudo kubectl describe role
Name:         list-pods
Labels:       <none>
Annotations:  <none>
PolicyRule:
  Resources  Non-Resource URLs  Resource Names  Verbs
  ---------  -----------------  --------------  -----
  pods       []                 []              [list]
```
```
angela@angela:~$ sudo kubectl describe rolebinding -n frontend
Name:         list-pods-bind
Labels:       <none>
Annotations:  <none>
Role:
  Kind:  Role
  Name:  list-pods
Subjects:
  Kind  Name  Namespace
  ----  ----  ---------
  User  jane  frontend
```
```
angela@angela:~$ kubectl config set-credentials jane --client-key=jane.key --client-certificate=jane.crt --embed-certs=true
User "jane" set.
```
```
angela@angela:~$ sudo kubectl config set-context jane --cluster=kubernetes --user=jane --namespace=frontend
Context "jane" created.
```
```
angela@angela:~$ kubectl config use-context jane  
Switched to context "jane".
```
```
angela@angela:~$ kubectl config view -o jsonpath='{.users[*].name}'
jane
```
```
angela@angela:~$ sudo kubectl delete pods nginx -n frontend --as=jane
Error from server (Forbidden): pods "nginx" is forbidden: User "jane" cannot delete resource "pods" in API group "" in the namespace "frontend"
```
```
angela@angela:~$ sudo kubectl run nginx --image=nginx -n frontend --as=jane
Error from server (Forbidden): pods is forbidden: User "jane" cannot create resource "pods" in API group "" in the namespace "frontend"
```
```
angela@angela:~$ sudo kubectl get  pods -n frontend --as=jane
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          2m4s
```
```
angela@angela:~$ sudo kubectl auth can-i create pods --namespace frontend --as=jane
no
```
```
angela@angela:~$ sudo kubectl auth can-i list  pods --namespace frontend --as=jane
yes
```
```
angela@angela:~$ sudo kubectl auth can-i delete  pods --namespace frontend --as=jane
no
```
27 -
