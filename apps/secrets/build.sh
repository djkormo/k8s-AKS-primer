#!/bin/bash
DOCKER_REGISTRY=docker.io
DOCKER_PROJECT_ID=djkormo
SERVICE_NAME=secrets
DOCKER_IMAGE_NAME=$DOCKER_PROJECT_ID/$SERVICE_NAME
DOCKER_IMAGE_REPO_NAME=$DOCKER_REGISTRY/$DOCKER_IMAGE_NAME

echo "DOCKER_REGISTRY: $DOCKER_REGISTRY"
echo "DOCKER_PROJECT_ID: $DOCKER_PROJECT_ID"
echo "SERVICE_NAME: $SERVICE_NAME"
echo "DOCKER_IMAGE_NAME: $DOCKER_IMAGE_NAME"
echo "DOCKER_IMAGE_REPO_NAME: $DOCKER_IMAGE_REPO_NAME"



#  build 
docker build -t $SERVICE_NAME:hardcode . -f Dockerfile-hardcode
docker build -t $SERVICE_NAME:envvars . -f Dockerfile-envvars 
docker build -t $SERVICE_NAME:file . -f Dockerfile-file


# tag

docker tag $SERVICE_NAME:hardcode $DOCKER_IMAGE_NAME:hardcode 
docker tag $SERVICE_NAME:envvars $DOCKER_IMAGE_NAME:envvars 
docker tag $SERVICE_NAME:file $DOCKER_IMAGE_NAME:file 

#push

docker push  $DOCKER_IMAGE_NAME:hardcode
docker push  $DOCKER_IMAGE_NAME:envvars
docker push  $DOCKER_IMAGE_NAME:file
