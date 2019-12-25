#!/bin/bash

echo "***************************************************************************************"
echo "*---------------------------------BEGIN LOAD TEST-------------------------------------*"
echo "***************************************************************************************"

export CONTENT_TYPE="Content-Type: application/json"

export PHASES=3


if [ -z "$1" ]
then
  echo "ENDPOINT was passed as a parameter, assuming it is passed as environment variable"
else
  export ENDPOINT=$1
  echo "ENDPOINT was passed as a parameter : value -> $ENDPOINT"

fi

if [ -z "$2" ]
then
  echo "METHOD was passed as a parameter, assuming it is passed as environment variable"
else
  export METHOD=$2
  echo "METHOD was passed as a parameter : value -> $METHOD"
  
fi

if [ -z "$3" ]
then
  echo "PAYLOAD was passed as a parameter, assuming it is passed as environment variable"
else
  export PAYLOAD=$3
  echo "PAYLOAD was passed as a parameter : value -> $PAYLOAD"
 
fi


if [ -z "$4" ]
then
  echo "PHASES was passed as a parameter, assuming it is passed as environment variable"
else
  export PHASES=$4
  echo "PHASES was passed as a parameter : value -> $PHASES"
fi


echo "ENDPOINT: $ENDPOINT"
echo "METHOD: $METHOD"
echo "CONTENT_TYPE: $CONTENT_TYPE"
echo "PAYLOAD: $PAYLOAD"
echo "PHASES: $PHASES"

echo "Phase 1: Warming up - 30 seconds, 100 users."
./hey -z 30s -c 100 -d "$PAYLOAD" -H "$CONTENT_TYPE" -m $METHOD "$ENDPOINT"

echo "Waiting 15 seconds for the cluster to stabilize"
sleep 15

if [ $PHASES -lt 2 ]
then 
  echo "***************************************************************************************"
  echo "*----------------------------------END LOAD TEST--------------------------------------*"
  echo "***************************************************************************************"
  exit 0
fi 

echo "\nPhase 2: Load test - 30 seconds, 400 users."
./hey -z 30s -c 400 -d "$PAYLOAD" -H "$CONTENT_TYPE" -m $METHOD "$ENDPOINT"

echo "Waiting 15 seconds for the cluster to stabilize"
sleep 15


if [ $PHASES -lt 3 ]
then 
  echo "***************************************************************************************"
  echo "*----------------------------------END LOAD TEST--------------------------------------*"
  echo "***************************************************************************************"
  exit 0
fi 


echo "\nPhase 3: Load test - 30 seconds, 1600 users."
./hey -z 30s -c 1600 -d "$PAYLOAD" -H "$CONTENT_TYPE" -m $METHOD "$ENDPOINT"

echo "Waiting 15 seconds for the cluster to stabilize"
sleep 15


if [ $PHASES -lt 4 ]
then 
  echo "***************************************************************************************"
  echo "*----------------------------------END LOAD TEST--------------------------------------*"
  echo "***************************************************************************************"
  exit 0
fi 

echo "\nPhase 4: Load test - 30 seconds, 3200 users."
./hey -z 30s -c 3200 -d "$PAYLOAD" -H "$CONTENT_TYPE" -m $METHOD "$ENDPOINT"

echo "Waiting 15 seconds for the cluster to stabilize"
sleep 15


if [ $PHASES -lt 5 ]
then 
  echo "***************************************************************************************"
  echo "*----------------------------------END LOAD TEST--------------------------------------*"
  echo "***************************************************************************************"
  exit 0
fi 



echo "\nPhase 5: Load test - 30 seconds, 6400 users."
./hey -z 30s -c 6400 -d "$PAYLOAD" -H "$CONTENT_TYPE" -m $METHOD "$ENDPOINT"

if [ $PHASES -lt 6 ]
then 
  echo "***************************************************************************************"
  echo "*----------------------------------END LOAD TEST--------------------------------------*"
  echo "***************************************************************************************"
  exit 0
fi 


echo "***************************************************************************************"
echo "*----------------------------------END LOAD TEST--------------------------------------*"
echo "***************************************************************************************"