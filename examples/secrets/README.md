#### Using secrets in Kubernetes



##### Hardcoded example

```js
var http = require('http');
var server = http.createServer(function (request, response) {
  const language = 'English';
  const API_KEY = '123-456-789';
  response.write(`Language: ${language}\n`);
  response.write(`API Key: ${API_KEY}\n`);
  response.end(`\n`);
});
server.listen(3000);
```

#### Based on this code image was put in docker hub-> djkormo/secrets:hardcode

```console
kubectl apply -f ./deploy-hardcode.yaml
```


##### Using envirnment variables
```js
var http = require('http');
var server = http.createServer(function (request, response) {
  const language = process.env.LANGUAGE;
  const API_KEY = process.env.API_KEY;
  response.write(`Language: ${language}\n`);
  response.write(`API Key: ${API_KEY}\n`);
  response.end(`\n`);
});
server.listen(3000);
```

#### Based on this code image was put in docker hub-> djkormo/secrets:envvars


```console
kubectl apply -f ./deploy-envvars.yaml
```


##### Using Secrets and Config maps


```console
kubectl create secret generic apikey --from-literal=API_KEY=123–456
```

<pre>
secret/apikey created
</pre>


```console
kubectl create configmap language --from-literal=LANGUAGE=English
```

<pre>
configmap/language created
</pre>


```console
kubectl get secret apikey
kubectl describe secret apikey
```

<pre>
NAME     TYPE     DATA   AGE
apikey   Opaque   1      41s

Name:         apikey
Namespace:    my-app
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
API_KEY:  9 bytes

</pre>


##### How to get  value from secret
```console
kubectl get secret apikey -o yaml
```
```yaml
apiVersion: v1
data:
  API_KEY: MTIz4oCTNDU2
kind: Secret
metadata:
  creationTimestamp: "2019-08-04T20:59:30Z"
  name: apikey
  namespace: my-app
  resourceVersion: "1744160"
  selfLink: /api/v1/namespaces/my-app/secrets/apikey
  uid: c0cea9c7-b6fa-11e9-8fb6-7a04c9d91c64
type: Opaque
```

#### All types in Kubernetes Secret

##### SecretType = "Opaque"                                 // Opaque (arbitrary data; default)
##### SecretType = "kubernetes.io/service-account-token"    // Kubernetes auth token
##### SecretType = "kubernetes.io/dockercfg"                // Docker registry auth
##### SecretType = "kubernetes.io/dockerconfigjson"         // Latest Docker registry auth

```console
kubectl get configmap language
```
<pre>
NAME       DATA   AGE
language   1      2m31s
</pre>



```console
kubectl create configmap language --from-literal=LANGUAGE=Spanish \
-o yaml --dry-run | kubectl replace -f -
kubectl create secret generic apikey --from-literal=API_KEY=098765 \
-o yaml --dry-run | kubectl replace -f -
```
<pre>
configmap/language replaced
secret/apikey replaced
</pre>

```console
kubectl get pod -l name=secret-configmap
```
<pre>
NAME                                READY   STATUS    RESTARTS   AGE
secret-configmap-5cf69868d5-9wb84   1/1     Running   0          7m15s
</pre>

```
kubectl delete pod -l name=secret-configmap
```

<pre>
pod "secret-configmap-5cf69868d5-9wb84" deleted
</pre>


```console
kubectl get pod -l name=secret-configmap
```
<pre>
NAME                                READY   STATUS    RESTARTS   AGE
secret-configmap-5cf69868d5-vj8mm   1/1     Running   0          59s
</pre>



##### Using json files  TODO

```console
kubectl create secret generic my-secret --from-file=./secret/secret.json
```

<pre>
secret/my-secret created
</pre>

```console
kubectl create configmap my-config --from-file=./config/config.json
```

<pre>
configmap/my-config created
</pre>

```console
kubectl get secret my-secret
kubectl get configmap my-config
```
<pre>
NAME        TYPE     DATA   AGE
my-secret   Opaque   1      96s

NAME        DATA   AGE
my-config   1      61s

</pre>

```
echo -n 'admin123' | base64
echo -n 'pass55pass55Pass' | base64
```
<pre>
YWRtaW4xMjM=
cGFzczU1cGFzczU1UGFzcw==
</pre>

###### Using secrets
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: test-secret
data:
  username: YWRtaW4xMjM=
  password: cGFzczU1cGFzczU1UGFzcw==
```
```console
kubectl apply -f ./test-secret.yaml
```
<pre>
secret/test-secret created
</pre>

```console
kubectl get secret test-secret
```
<pre>
NAME          TYPE     DATA   AGE
test-secret   Opaque   2      61s
</pre>

```console
kubectl describe secret test-secret
```

<pre>
Name:         test-secret
Namespace:    my-app
Labels:       <none>
Annotations:
Type:         Opaque

Data
====
password:  12 bytes
username:  6 bytes

</pre>

##### use secret by attaching Volume

```console
kubectl apply -f ./secret-pod.yaml
``` 

#### how to decode values from secrets ?

```console
kubectl get secret test-secret -o yaml
```
```yaml

```

kubectl get secret test-secret -o yaml