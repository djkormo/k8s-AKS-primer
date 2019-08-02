
kubectl apply -f https://raw.githubusercontent.com/spekt8/spekt8/master/fabric8-rbac.yaml

kubectl apply -f https://raw.githubusercontent.com/spekt8/spekt8/master/spekt8-deployment.yaml --namespace=default


kubectl expose deployment spekt8 --type=LoadBalancer --name=svc-spekt8


problem z hardcodem localhost:3000

kubectl port-forward --address 0.0.0.0 deployment/spekt8 3000:3000

