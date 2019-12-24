#!/bin/bash

echo "***************************************************************************************"
echo "*---------------------------------BEGIN LOAD TEST-------------------------------------*"
echo "***************************************************************************************"

export CONTENT_TYPE="Content-Type: application/json"
#export PAYLOAD='{"EmailAddress": "email@domain.com", "Product": "prod-1", "Total": 100}'
export PHASES=
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


if [ -z "$4" ]
then
  echo "PHASES was passed as a parameter, assuming it is passed as environment variable"
else
  echo "PHASES was passed as a parameter"
  export PHASES=$4
fi


echo "ENDPOINT: $ENDPOINT"
echo "METHOD: $METHOD"
echo "CONTENT_TYPE: $CONTENT_TYPE"
echo "PAYLOAD: $PAYLOAD"

echo "Phase 1: Warming up - 30 seconds, 100 users."
./hey -z 30s -c 100 -d "$PAYLOAD" -H "$CONTENT_TYPE" -m $METHOD "$ENDPOINT"

echo "Waiting 15 seconds for the cluster to stabilize"
sleep 15

if [$PHASEd<2]
then 
  exit 0
fi 

echo "\nPhase 2: Load test - 30 seconds, 400 users."
./hey -z 30s -c 400 -d "$PAYLOAD" -H "$CONTENT_TYPE" -m $METHOD "$ENDPOINT"

echo "Waiting 15 seconds for the cluster to stabilize"
sleep 15


if [$PHASEd<3]
then 
  exit 0
fi 


echo "\nPhase 3: Load test - 30 seconds, 1600 users."
./hey -z 30s -c 1600 -d "$PAYLOAD" -H "$CONTENT_TYPE" -m $METHOD "$ENDPOINT"

echo "Waiting 15 seconds for the cluster to stabilize"
sleep 15


if [$PHASEd<4]
then 
  exit 0
fi 

echo "\nPhase 4: Load test - 30 seconds, 3200 users."
./hey -z 30s -c 3200 -d "$PAYLOAD" -H "$CONTENT_TYPE" -m $METHOD "$ENDPOINT"

echo "Waiting 15 seconds for the cluster to stabilize"
sleep 15


if [$PHASEd<5]
then 
  exit 0
fi 



echo "\nPhase 5: Load test - 30 seconds, 6400 users."
./hey -z 30s -c 6400 -d "$PAYLOAD" -H "$CONTENT_TYPE" -m $METHOD "$ENDPOINT"

if [$PHASEd<6]
then 
  exit 0
fi 


echo "***************************************************************************************"
echo "*----------------------------------END LOAD TEST--------------------------------------*"
echo "***************************************************************************************"