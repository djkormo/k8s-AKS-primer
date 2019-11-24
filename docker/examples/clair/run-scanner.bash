#!/bin/bash


# running security scanner for local images 

# -n image name 
# -t threshold level 


while getopts n:t: option
do
case "${option}"
in
n) NAME=${OPTARG};;
t) THRESHOLD=${OPTARG};;
esac
done

if [ -n "$NAME" ]
then
      echo "\$NAME is empty"
else
      echo "\$NAME is NOT empty"
fi

if [ -t "$THRESHOLD" ]
then
      echo "\$THRESHOLD is empty"
else
      echo "\$THRESHOLD is NOT empty"
fi


export IP=$(ip r | tail -n1 | awk '{ print $9 }')
echo $IP 
./clair-scanner --ip ${IP} --clair=http://clair:6060 --threshold="$THRESHOLD" $NAME

