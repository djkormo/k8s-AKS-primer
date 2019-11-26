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
 
 