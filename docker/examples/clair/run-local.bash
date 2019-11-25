#!/bin/bash

docker run -ti \
  --rm \
  --name clair-scanner \
  --net clair \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /home/scanner-logs:. \
  djkormo/clair-scanner:latest /bin/bash
  