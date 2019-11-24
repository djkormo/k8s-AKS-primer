#!/bin/bash

docker run -ti \
  --rm \
  --name clair-scanner \
  --net clair \
  -v /var/run/docker.sock:/var/run/docker.sock \
  djkormo/clair-scanner:latest /bin/bash