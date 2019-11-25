#!/bin/bash

docker run -ti \
  --rm \
  --name clair-scanner \
  --net clair \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --mount src=`pwd`,target=/home/scanner-logs/,type=bind \
  djkormo/clair-scanner:latest /bin/bash
  