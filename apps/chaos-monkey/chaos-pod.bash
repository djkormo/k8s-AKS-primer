#!/bin/bash

# Randomly delete pods in a Kubernetes namespace.
: ${DELAY:=30}
: ${NAMESPACE:=default}
: ${EXCLUDEDAPPS:=k8s-chaos-monkey}
# endless loop 
while true; do
  PODNAME=$(kubectl   get pods --field-selector=status.phase=Running -l app!=$EXCLUDEDAPPS --namespace $NAMESPACE -o 'jsonpath={.items[*].metadata.name}' |tr " " "\n" |shuf |head -n 1)
  echo "NAMESPACE :$NAMESPACE"
  echo "PODNAME :$PODNAME"
  NOW=$(date)
  echo "Current date: $NOW"
  # checking if there is a pod to delete
  if [[ -z "${PODNAME}" ]]; then
    echo "There are no pods to delete"
  else
    kubectl delete pod $PODNAME -n $NAMESPACE
  fi

  echo "DELAY: $DELAY seconds" 
  sleep $DELAY
done
