#!/bin/bash

docker pull portainer/portainer

docker run -d -p 9000:9000 --name portainer-linux --restart always -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer

