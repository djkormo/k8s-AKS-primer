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
```console
kubectl apply -f ./deploy-hardcode.yaml
```


##### Using envirnment variables
```js
var http = require('http');
var fs = require('fs');
var server = http.createServer(function (request, response) {
  fs.readFile('./config/config.json', function (err, config) {
    if (err) return console.log(err);
    const language = JSON.parse(config).LANGUAGE;
    fs.readFile('./secret/secret.json', function (err, secret) {
      if (err) return console.log(err);
      const API_KEY = JSON.parse(secret).API_KEY;
      response.write(`Language: ${language}\n`);
      response.write(`API Key: ${API_KEY}\n`);
      response.end(`\n`);
    });
  });
});
server.listen(3000);

```

```console
```console
kubectl apply -f ./deploy-hardcode.yaml
```
```


##### Using Secrets and config maps


```console
kubectl create secret generic apikey --from-literal=API_KEY=123–456
```
<pre>
secret/apikey created
</pre>


```console`
kubectl create configmap language --from-literal=LANGUAGE=English
```
<pre>
configmap/language created
</pre>


```console
kubectl get secret apikey
```

<pre>
NAME     TYPE     DATA   AGE
apikey   Opaque   1      2m5s
</pre>

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

##### Using json files

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
