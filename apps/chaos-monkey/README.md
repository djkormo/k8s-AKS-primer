## Simple implementation of chaos monkey in Kubernetes



Choosing one pod to kill
```console
kubectl    get pods --namespace "kube-system" -o 'jsonpath={.items[*].metadata.name}' |tr " " "\n" |shuf |head -n 1
```

```bash
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
```


kubectl run kubectl-pod --generator=run-pod/v1 \
  --limits="cpu=200m,memory=100Mi" \
  --requests="cpu=100m,memory=50Mi" \
  --rm -i --tty --image debian:jessie -- bash


Based on:


https://hub.docker.com/r/jnewland/kubernetes-pod-chaos-monkey/


Literature:

https://github.com/Netflix/chaosmonkey

https://github.com/jnewland/kubernetes-pod-chaos-monkey

https://www.gremlin.com/chaos-monkey/chaos-monkey-alternatives/kubernetes/

https://medium.com/faun/failures-are-inevitable-even-a-strongest-platform-with-concrete-operations-infrastructure-can-7d0c016430c6

https://kubernetes.io/docs/tasks/tools/install-kubectl/



