
```console
cat <<EOF > crd.yml
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: databases.zalando.org
spec:
  scope: Namespaced
  group: zalando.org
  versions:
    - name: v1
      served: true
      storage: true
  names:
    kind: Database
    plural: databases
    singular: database
    shortNames:
      - db
      - dbs
  additionalPrinterColumns:
    - name: Type
      type: string
      priority: 0
      JSONPath: .spec.type
      description: The type of the database
EOF
```

``` console
kubectl apply -f crd.yml
```

<pre>
customresourcedefinition.apiextensions.k8s.io/databases.zalando.org created
</pre>

```console
kubectl get crd databases.zalando.org
```

<pre>
databases.zalando.org                   2019-09-19T21:12:07Z
</pre>


```console
cat <<EOF > sa.yml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: db-operator
EOF
```
```
kubectl apply -f sa.yml
```
<pre>
serviceaccount/db-operator created
</pre>

```console
cat <<EOF > binding.yml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: db-operator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: db-operator
    namespace: default
EOF
```

```console
kubectl apply -f binding.yml
```

<pre>
clusterrolebinding.rbac.authorization.k8s.io/db-operator created
</pre>

```console
cat <<EOF > operator.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: op
spec:
  selector:
    matchLabels:
      app: op
  template:
    metadata:
      labels:
        app: op
    spec:
      serviceAccountName: db-operator
      containers:
      - image: djkormo/db-op
        name: op
EOF
```

```console
kubectl apply -f operator.yml
```
<pre>
deployment.apps/op created
</pre>

```console
kubectl get deploy,pod
```

```console
cat <<EOF > mongo.yml
apiVersion: zalando.org/v1
kind: Database
metadata:
  name: mongo-db
spec:
  type: mongo
EOF
```

```console
kubectl apply -f mongo.yml
```
<pre>
database.zalando.org/mongo-db created
</pre>

```console
kubectl get pod,svc
```
Literature:

https://medium.com/swlh/building-a-kubernetes-operator-in-python-with-zalandos-kopf-37c311d8edff