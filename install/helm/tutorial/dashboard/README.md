```console
kubectl apply -f kubernetes-dashboard-role.yaml -n default
kubectl apply -f kubernetes-dashboard-rolebinding.yaml -n default
kubectl apply -f kubernetes-dashboard-secret.yaml -n default
```

#### Installing dashboard from Helm charts repo
```console
helm install --name dash \
    --namespace default \
    -f values-dashboard.yaml \
    stable/kubernetes-dashboard
```    

```console
  export POD_NAME=$(kubectl get pods -n default -l "app=kubernetes-dashboard,release=dash" -o jsonpath="{.items[0].metadata.name}")
  echo https://127.0.0.1:8443/
  kubectl -n default port-forward $POD_NAME 8443:8443
```

### based on https://akomljen.com/installing-kubernetes-dashboard-per-namespace/