```console

kubectl apply -f 

```


kubectl apply -f kuard-deploy-heath-check.yaml


kubectl get all --namespace=default

NAME                                           READY   STATUS    RESTARTS   AGE
pod/kuard-health-deployment-68d9766d56-hd6xp   1/1     Running   0          11m
pod/kuard-health-deployment-68d9766d56-kqhjh   1/1     Running   0          11m

NAME                   TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
service/kuard-health   NodePort    10.0.53.91    <none>        8080:31324/TCP   11m
service/kubernetes     ClusterIP   10.0.0.1      <none>        443/TCP          35m
service/my-app-ram     NodePort    10.0.228.77   <none>        80:32718/TCP     44h

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/kuard-health-deployment   2/2     2            2           11m

NAME                                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/kuard-health-deployment-68d9766d56   2         2         2       11m


kubectl port-forward deploy/kuard-health-deployment 8080:8080

Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Handling connection for 8080
Handling connection for 8080



#### Trying to allocate memory and putting liveness to status 500


kubectl get all --namespace=default
NAME                                           READY   STATUS    RESTARTS   AGE
pod/kuard-health-deployment-68d9766d56-hd6xp   1/1     Running   2          13m
pod/kuard-health-deployment-68d9766d56-kqhjh   1/1     Running   3          13m

NAME                   TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
service/kuard-health   NodePort    10.0.53.91    <none>        8080:31324/TCP   13m


NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/kuard-health-deployment   2/2     2            2           13m

NAME                                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/kuard-health-deployment-68d9766d56   2         2         2       13m