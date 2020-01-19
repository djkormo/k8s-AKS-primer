Installing Portainer


```console
docker pull portainer/portainer
```

On linux

```console
docker run -d -p 9000:9000 --name portainer-linux --restart always -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer
```

On Windows

```console
docker volume create portainer_data

docker run -d -p 9000:9000 -v //var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data  \
 --name portainer-windows portainer/portainer
 
 ```
 
 Visualizer for docker swarm
 
 On linux
 
 ```console
 docker service create -p 8080:8080 --constraint=node.role==manager --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock dockersamp
les/visualizer
 ```
 
 on windows 
 
``` console 
docker service create -p 8080:8080 --constraint=node.role==manager --mount=type=bind,src=//var/run/docker.sock,dst=/var/run/docker.sock \
  dockersamples/visualizer
```

 
 