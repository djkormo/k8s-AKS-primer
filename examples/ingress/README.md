### What is an Ingress?

In Kubernetes, an Ingress is an object that allows access to your Kubernetes services from outside the Kubernetes cluster. You configure access by creating a collection of rules that define which inbound connections reach which services.

This lets you consolidate your routing rules into a single resource. For example, you might want to send requests to example.com/api/v1/ to an api-v1 service, and requests to example.com/api/v2/ to the api-v2 service. With an Ingress, you can easily set this up without creating a bunch of LoadBalancers or exposing each service on the Node.

Which leads us to the next point…
Kubernetes Ingress vs LoadBalancer vs NodePort

These options all do the same thing. They let you expose a service to external network requests. They let you send a request from outside the Kubernetes cluster to a service inside the cluster.

#### NodePort

nodeport in kubernetes

![nodeport](nodeport.png)

NodePort is a configuration setting you declare in a service’s YAML. Set the service spec’s type to NodePort. Then, Kubernetes will allocate a specific port on each Node to that service, and any request to your cluster on that port gets forwarded to the service.

This is cool and easy, it’s just not super robust. You don’t know what port your service is going to be allocated, and the port might get re-allocated at some point.

#### LoadBalancer

loadbalancer in kubernetes

![loadbalancer](loadbalancer.png)

You can set a service to be of type LoadBalancer the same way you’d set NodePort— specify the type property in the service’s YAML. There needs to be some external load balancer functionality in the cluster, typically implemented by a cloud provider.

This is typically heavily dependent on the cloud provider—GKE creates a Network Load Balancer with an IP address that you can use to access your service.

Every time you want to expose a service to the outside world, you have to create a new LoadBalancer and get an IP address.




#### Ingress

ingress in kubernetes

![ingress](ingress.png)

NodePort and LoadBalancer let you expose a service by specifying that value in the service’s type. Ingress, on the other hand, is a completely independent resource to your service. You declare, create and destroy it separately to your services.

This makes it decoupled and isolated from the services you want to expose. It also helps you to consolidate routing rules into one place.

The one downside is that you need to configure an Ingress Controller for your cluster. But that’s pretty easy—in this example, we’ll use the Nginx Ingress Controller.


##### Create a namespace for your ingress resources
```console
kubectl create namespace ingress-basic
```

##### Use Helm to deploy an NGINX ingress controller

```console
helm install stable/nginx-ingress \
    --namespace ingress-basic \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux
```


###### Create two apps

```yaml
kind: Pod
apiVersion: v1
metadata:
  name: apple-app
  labels:
    app: apple
spec:
  containers:
    - name: apple-app
      image: hashicorp/http-echo
      args:
        - "-text=apple"

---

kind: Service
apiVersion: v1
metadata:
  name: apple-service
spec:
  selector:
    app: apple
  ports:
    - port: 5678 # Default port for image
```


```yaml
kind: Pod
apiVersion: v1
metadata:
  name: banana-app
  labels:
    app: banana
spec:
  containers:
    - name: banana-app
      image: hashicorp/http-echo
      args:
        - "-text=banana"

---

kind: Service
apiVersion: v1
metadata:
  name: banana-service
spec:
  selector:
    app: banana
  ports:
    - port: 5678 # Default port for image
```

##### Create the resources 

```console
kubectl apply -f apple.yaml --namespace=ingress-basic
kubectl apply -f banana.yaml --namespace=ingress-basic
```

##### Definition for ingress object

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
        - path: /apple
          backend:
            serviceName: apple-service
            servicePort: 5678
        - path: /banana
          backend:
            serviceName: banana-service
            servicePort: 5678
```


```console
kubectl apply -f ingress.yaml --namespace=ingress-basic
```


#### Adding TLS to ingress

##### Generate cert
```console
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -out aks-ingress-tls.crt \
    -keyout aks-ingress-tls.key \
    -subj "//CN=demo.azure.com\O=aks-ingress-tls"
```
##### Create K8s secret to store cert

```console
kubectl create secret tls aks-ingress-tls \
    --namespace ingress-basic \
    --key aks-ingress-tls.key \
    --cert aks-ingress-tls.crt
    --namespace=ingress-basic
```

##### Deploy new version of ingress
```console
kubectl apply -f ingress-tls.yaml  --namespace=ingress-basic
```
##### Testing out service
```console
service=40.68.156.192
curl -v -k --resolve demo.azure.com:443:$service https://demo.azure.com/
curl -v -k --resolve demo.azure.com:443:$service https://demo.azure.com/apple
curl -v -k --resolve demo.azure.com:443:$service https://demo.azure.com/banana
```

<pre>
server: nginx/1.15.10
date: Tue, 30 Jul 2019 14:06:30 GMT
content-type: text/plain; charset=utf-8
content-length: 21
strict-transport-security: max-age=15724800; includeSubDomains
default backend - 404* Connection #0 to host demo.azure.com left intact

apple
* Connection #0 to host demo.azure.com left intact

banana
* Connection #0 to host demo.azure.com left intact

</pre>



##### Based on 
https://matthewpalmer.net/kubernetes-app-developer/articles/kubernetes-ingress-guide-nginx-example.html
https://docs.microsoft.com/en-us/azure/aks/ingress-basic
https://docs.microsoft.com/en-us/azure/aks/ingress-own-tls
