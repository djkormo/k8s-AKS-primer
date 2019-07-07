#!/bin/bash
DOCKER_REGISTRY=docker.io
DOCKER_PROJECT_ID=djkormo
SERVICE_NAME=chess-ai
DOCKER_IMAGE_NAME=$DOCKER_PROJECT_ID/$SERVICE_NAME
DOCKER_IMAGE_REPO_NAME=$DOCKER_REGISTRY/$DOCKER_IMAGE_NAME

echo "DOCKER_REGISTRY: $DOCKER_REGISTRY"
echo "DOCKER_PROJECT_ID: $DOCKER_PROJECT_ID"
echo "SERVICE_NAME: $SERVICE_NAME"
echo "DOCKER_IMAGE_NAME: $DOCKER_IMAGE_NAME"
echo "DOCKER_IMAGE_REPO_NAME: $DOCKER_IMAGE_REPO_NAME"



#  build 
docker build -t $SERVICE_NAME . -f Dockerfile
docker build -t $SERVICE_NAME:blue . -f Dockerfile-blue 
docker build -t $SERVICE_NAME:green . -f Dockerfile-green


# tag

docker tag $SERVICE_NAME $DOCKER_IMAGE_NAME 
docker tag $SERVICE_NAME:blue $DOCKER_IMAGE_NAME:blue 
docker tag $SERVICE_NAME:green $DOCKER_IMAGE_NAME:green 

#push

docker push  $DOCKER_IMAGE_NAME
docker push  $DOCKER_IMAGE_NAME:blue
docker push  $DOCKER_IMAGE_NAME:green