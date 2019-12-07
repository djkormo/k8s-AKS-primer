#!/bin/bash


docker network create np

# run logic
docker run -d -p 5000:5000 --name np-logic  --network np djkormo/np-logic

# run webapp

NP_LOGIC_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' np-logic );
echo $NP_LOGIC_IP

docker run -d -p 8080:8080 -e SA_LOGIC_API_URL="http://$NP_LOGIC_IP:5000" \
--name np-webapp --network np djkormo/np-webapp	

# run frontend

NP_WEBAPP_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' np-webapp );
echo $NP_WEBAPP_IP

docker run -d -p 80:80  -e SA_WEBAPP_API_URL="http://$NP_WEBAPP_IP:8080/sentiment/" \
--name np-frontend --network np djkormo/np-frontend


