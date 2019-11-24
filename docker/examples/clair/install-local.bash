#!/bin/bash

docker network create clair

docker network ls


docker volume create --name clair-postgres


docker pull  arminc/clair-db:latest


docker run --detach \
   --name clair-postgres \
   --publish 5432:5432 \
   --net clair \
   --volume clair-postgres:/var/lib/postgresql/data \
   arminc/clair-db:latest
  
docker logs --tail  10 clair-postgres 


curl --silent https://raw.githubusercontent.com/nordri/config-files/master/clair/config-clair.yaml | sed "s/POSTGRES_NAME/clair-postgres/" > config.yaml



docker run --detach \
  --name clair \
  --net clair \
  --publish 6060:6060 \
  --publish 6061:6061 \
  --volume ${PWD}/config.yaml:/config/config.yaml \
  quay.io/coreos/clair:latest -config /config/config.yaml


wget  https://github.com/arminc/clair-scanner/releases/download/v12/clair-scanner_linux_amd64

docker build -t djkormo/clair-scanner .

