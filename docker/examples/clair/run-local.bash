#!/bin/bash

docker run --detach \
  --name clair \
  --net clair \
  --publish 6060:6060 \
  --publish 6061:6061 \
  --volume ${PWD}/config.yaml:/config/config.yaml \
  quay.io/coreos/clair:latest -config /config/config.yaml