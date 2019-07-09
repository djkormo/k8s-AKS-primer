#!/bin/bash

echo "***************************************************************************************"
echo "*---------------------------------BEGIN LOAD TEST-------------------------------------*"
echo "***************************************************************************************"

if [ -z "$1" ]
then
  echo "ENDPOINT was passed as a parameter, assuming it is passed as environment variable"
else
  echo "ENDPOINT was passed as a parameter"
  export ENDPOINT=$1
fi

if [ -z "$2" ]
then
  echo "METHOD was passed as a parameter, assuming it is passed as environment variable"
else
  echo "METHOD was passed as a parameter"
  export METHOD=$2
fi

if [ -z "$3" ]
then
  echo "PAYLOAD was passed as a parameter, assuming it is passed as environment variable"
else
  echo "PAYLOAD was passed as a parameter"
  export PAYLOAD=$3
fi

export CONTENT_TYPE="Content-Type: application/json"
export PAYLOAD='{"EmailAddress": "email@domain.com", "Product": "prod-1", "Total": 100}'
#export ENDPOINT=http://$SERVICE_IP/

echo "ENDPOINT: $ENDPOINT"
echo "METHOD: $METHOD"
echo "CONTENT_TYPE: $CONTENT_TYPE"
echo "PAYLOAD: $PAYLOAD"

echo "Phase 1: Warming up - 30 seconds, 100 users."
./hey -z 30s -c 100 -d "$PAYLOAD" -H "$CONTENT_TYPE" -m $METHOD "$ENDPOINT"

echo "Waiting 15 seconds for the cluster to stabilize"
sleep 15

echo "\nPhase 2: Load test - 30 seconds, 400 users."
./hey -z 30s -c 400 -d "$PAYLOAD" -H "$CONTENT_TYPE" -m $METHOD "$ENDPOINT"

echo "Waiting 15 seconds for the cluster to stabilize"
sleep 15

echo "\nPhase 3: Load test - 30 seconds, 1600 users."
./hey -z 30s -c 1600 -d "$PAYLOAD" -H "$CONTENT_TYPE" -m $METHOD "$ENDPOINT"

echo "Waiting 15 seconds for the cluster to stabilize"
sleep 15

echo "\nPhase 4: Load test - 30 seconds, 3200 users."
./hey -z 30s -c 3200 -d "$PAYLOAD" -H "$CONTENT_TYPE" -m $METHOD "$ENDPOINT"

echo "Waiting 15 seconds for the cluster to stabilize"
sleep 15

echo "\nPhase 5: Load test - 30 seconds, 6400 users."
./hey -z 30s -c 6400 -d "$PAYLOAD" -H "$CONTENT_TYPE" -m $METHOD "$ENDPOINT"

echo "***************************************************************************************"
echo "*----------------------------------END LOAD TEST--------------------------------------*"
echo "***************************************************************************************"