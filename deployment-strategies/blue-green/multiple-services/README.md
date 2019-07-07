Blue/green deployment to release multiple services simultaneously
=================================================================

> In this example, we release a new version of 2 services simultaneously using
the blue/green deployment strategy. [Traefik](https://traefik.io) in used as
Ingress controller, this example would also work with the
[Nginx Ingress controller](https://github.com/kubernetes/ingress-nginx).

## Steps to follow

1. service a and b are serving traffic
1. deploy new version of both services
1. wait for all services to be ready
1. switch incoming traffic from version 1 to version 2
1. shutdown version 1

## In practice

Install the latest version of
[Helm](https://docs.helm.sh/using_helm/#installing-helm), then install
[Traefik](https://traefik.io/):

```console
# Deploy Traefik with Helm
$ helm install \
    --name=traefik \
    --version=1.60.0 \
    --set rbac.enabled=true \
    stable/traefik
```

#### Deploy version 1 of application a and b and the ingress

```console
kubectl apply -f app-a-v1.yaml -f app-b-v1.yaml -f ingress-v1.yaml  --namespace=my-app
```


### Test if the deployment was successful

```console
ingress=$(minikube service traefik --url | head -n1)
curl $ingress -H 'Host: a.domain.com'
curl $ingress -H 'Host: b.domain.com'
```

### To see the deployment in action, open a new terminal and run the following
### command

```console
watch kubectl get po --namespace=my-app
```

### Then deploy version 2 of both applications

```console
kubectl apply -f app-a-v2.yaml -f app-b-v2.yaml --namespace=my-app
```

### Wait for both applications to be running

```console
kubectl rollout status deploy my-app-a-v2 -w
>deployment "my-app-a-v2" successfully rolled out

kubectl rollout status deploy my-app-b-v2 -w
>deployment "my-app-b-v2" successfully rolled out
```

### Check the status of the deployment, then when all the pods are ready, you can
### update the ingress

```console
kubectl apply -f ingress-v2.yaml --namespace=my-app
```

### Test if the deployment was successful

```console
curl $ingress -H 'Host: a.domain.com'

curl $ingress -H 'Host: b.domain.com'
```

### In case you need to rollback to the previous version

```console
kubectl apply -f ingress-v1.yaml
```

### If everything is working as expected, you can then delete the v1.0.0
### deployment

```console
kubectl delete -f ./app-a-v1.yaml -f ./app-b-v1.yaml
```

### Cleanup

```console
kubectl delete all -l app=my-app
helm del --purge traefik
```
