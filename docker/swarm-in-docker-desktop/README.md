Create Swarm cluster

```console
docker swarm init
```
<pre>
Swarm initialized: current node (p84m9c0fbt527mk7pkkwmxr0t) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-567l9sdx6voi6zzw8xhsw9hw6symsi1jtqp1shjlulvx9jmase-7ehg1h1ab1vfcvsuq8646o744 192.168.65.3:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
</pre>

List all nodes of our cluster

```console
docker node ls
```
<pre>
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
p84m9c0fbt527mk7pkkwmxr0t *   docker-desktop      Ready               Active              Leader              19.03.5
</pre>

List all stack in our cluster

```console
docker stack  ls
```
<pre>

NAME                SERVICES            ORCHESTRATOR

</pre>

Confirm by docker info existance of our cluster

```console
docker info
```
<pre>
...

Swarm: active
  NodeID: p84m9c0fbt527mk7pkkwmxr0t
  Is Manager: true
  ClusterID: zdiofcdgdvbzow3q0uqmirmhj
  Managers: 1
  Nodes: 1
  Default Address Pool: 10.0.0.0/8
  SubnetSize: 24
  Data Path Port: 4789
  Orchestration:
   Task History Retention Limit: 5
...
</pre>

Create first  service from alpine image with command ping docker.com inside

```console
docker service create --replicas 1 --name helloworld alpine ping docker.com
```

<pre>
image alpine:latest could not be accessed on a registry to record
its digest. Each node will access alpine:latest independently,
possibly leading to different nodes running different
versions of the image.

qhrqnor2esddqxf1rg2h8m9pm
overall progress: 1 out of 1 tasks
1/1: running   [==================================================>]
verify: Service converged
</pre>

List all services in our cluster 

```console
docker service ls
```

<pre>
ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
qhrqnor2esdd        helloworld          replicated          1/1                 alpine:latest
</pre>


Inspecting our service 

```console
docker service inspect --pretty helloworld
```
<pre>
ID:             qhrqnor2esddqxf1rg2h8m9pm
Name:           helloworld
Service Mode:   Replicated
 Replicas:      1
Placement:
UpdateConfig:
 Parallelism:   1
 On failure:    pause
 Monitoring Period: 5s
 Max failure ratio: 0
 Update order:      stop-first
RollbackConfig:
 Parallelism:   1
 On failure:    pause
 Monitoring Period: 5s
 Max failure ratio: 0
 Rollback order:    stop-first
ContainerSpec:
 Image:         alpine:latest
 Args:          ping docker.com
 Init:          false
Resources:
Endpoint Mode:  vip

</pre>


Inspecting our service  in json format 

```console
docker service inspect  helloworld
```

```json
[
    {
        "ID": "qhrqnor2esddqxf1rg2h8m9pm",
        "Version": {
            "Index": 11
        },
        "CreatedAt": "2020-01-19T13:01:09.7112289Z",
        "UpdatedAt": "2020-01-19T13:01:09.7112289Z",
        "Spec": {
            "Name": "helloworld",
            "Labels": {},
            "TaskTemplate": {
                "ContainerSpec": {
                    "Image": "alpine:latest",       
                    "Args": [
                        "ping",
                        "docker.com"
                    ],
                    "Init": false,
                    "StopGracePeriod": 10000000000, 
                    "DNSConfig": {},
                    "Isolation": "default"
                },
                "Resources": {
                    "Limits": {},
                    "Reservations": {}
                },
                "RestartPolicy": {
                    "Condition": "any",
                    "Delay": 5000000000,
                    "MaxAttempts": 0
                },
                "Placement": {},
                "ForceUpdate": 0,
                "Runtime": "container"
            },
            "Mode": {
                "Replicated": {
                    "Replicas": 1
                }
            },
            "UpdateConfig": {
                "Parallelism": 1,
                "FailureAction": "pause",
                "Monitor": 5000000000,
                "MaxFailureRatio": 0,
                "Order": "stop-first"
            },
            "RollbackConfig": {
                "Parallelism": 1,
                "FailureAction": "pause",
                "Monitor": 5000000000,
                "MaxFailureRatio": 0,
                "Order": "stop-first"
            },
            "EndpointSpec": {
                "Mode": "vip"
            }
        },
        "Endpoint": {
            "Spec": {}
        }
    }
]
```

What is inside of our service 

```console
docker service ps helloworld
```

<pre>
ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE            ERROR
          PORTS
zt0vu1ow25tq        helloworld.1        alpine:latest       docker-desktop      Running             Running 9 minutes ago

2kiqjy5s8so4         \_ helloworld.1    alpine:latest       docker-desktop      Shutdown            Rejected 9 minutes ago   "No such image: alpine:latest"
</pre>



```console
docker service ls
ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
zro8s57yzfj5        helloworld               replicated          1/1                alpine:latest
```

<pre>

</pre>


Let's scale our service to five instances 


```console
docker service scale helloworld=5
```

<pre>
helloworld scaled to 5
overall progress: 5 out of 5 tasks
1/5: running   [==================================================>]
2/5: running   [==================================================>]
3/5: running   [==================================================>]
4/5: running   [==================================================>]
5/5: running   [==================================================>]
verify: Service converged
</pre>


```console
docker service ps helloworld
```
<pre>
ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE             ERROR
           PORTS
zt0vu1ow25tq        helloworld.1        alpine:latest       docker-desktop      Running             Running 21 minutes ago
2kiqjy5s8so4         \_ helloworld.1    alpine:latest       docker-desktop      Shutdown            Rejected 21 minutes ago   "No such image: alpine:latest"
jk4idtugd2bu        helloworld.2        alpine:latest       docker-desktop      Running             Running 2 minutes ago
m0y6a9tqeidg        helloworld.3        alpine:latest       docker-desktop      Running             Running 2 minutes ago
sb02ut6kjfzj        helloworld.4        alpine:latest       docker-desktop      Running             Running 2 minutes ago
ougy5e40f6lq        helloworld.5        alpine:latest       docker-desktop      Running             Running 2 minutes ago
</pre>

```
docker service rm helloworld
```
<pre>
helloworld
</pre>

```console
docker service rm helloworld
```
<pre>
Error: No such service: helloworld
</pre>



Using rolling updates

```console 
docker service create \
  --replicas 3 \
  --name redis \
  --update-delay 10s \
  redis:3.0.6
```
<pre>
image redis:3.0.6 could not be accessed on a registry to record
its digest. Each node will access redis:3.0.6 independently,
possibly leading to different nodes running different
versions of the image.

zro8s57yzfj5dxgmfuscx75us
overall progress: 3 out of 3 tasks
1/3: running   [==================================================>]
2/3: running   [==================================================>]
3/3: running   [==================================================>]
verify: Service converged
</pre>  
  
```console
docker service inspect --pretty redis
```
<pre>
ID:             zro8s57yzfj5dxgmfuscx75us
Name:           redis
Service Mode:   Replicated
 Replicas:      3
Placement:
UpdateConfig:
 Parallelism:   1
 Delay:         10s
 On failure:    pause
 Monitoring Period: 5s
 Max failure ratio: 0
 Update order:      stop-first
RollbackConfig:
 Parallelism:   1
 On failure:    pause
 Monitoring Period: 5s
 Max failure ratio: 0
 Rollback order:    stop-first
ContainerSpec:
 Image:         redis:3.0.6
 Init:          false
Resources:
Endpoint Mode:  vip

</pre>
```console
docker service update --image redis:3.0.7 redis
```
<pre>
redis
overall progress: 3 out of 3 tasks
1/3: running   [==================================================>]
2/3: running   [==================================================>]
3/3: running   [==================================================>]
verify: Service converged
</pre>


```console
docker service inspect --pretty redis
```
<pre>
ID:             zro8s57yzfj5dxgmfuscx75us
Name:           redis
Service Mode:   Replicated
 Replicas:      3
UpdateStatus:
 State:         completed
 Started:       About a minute ago
 Completed:     45 seconds ago
 Message:       update completed
Placement:
UpdateConfig:
 Parallelism:   1
 Delay:         10s
 On failure:    pause
 Monitoring Period: 5s
 Max failure ratio: 0
 Update order:      stop-first
RollbackConfig:
 Parallelism:   1
 On failure:    pause
 Monitoring Period: 5s
 Max failure ratio: 0
 Rollback order:    stop-first
ContainerSpec:
 Image:         redis:3.0.7@sha256:730b765df9fe96af414da64a2b67f3a5f70b8fd13a31e5096fee4807ed802e20
 Init:          false
Resources:
Endpoint Mode:  vip
</pre>


```console
docker service ps redis
```
<pre>
ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE            ERROR               PORTS
us9086w3x37x        redis.1             redis:3.0.7         docker-desktop      Running             Running 5 minutes ago
o91gvlser4rg         \_ redis.1         redis:3.0.6         docker-desktop      Shutdown            Shutdown 5 minutes ago
f2rzzh54hlkl        redis.2             redis:3.0.7         docker-desktop      Running             Running 4 minutes ago
rrrb7xpsrijn         \_ redis.2         redis:3.0.6         docker-desktop      Shutdown            Shutdown 4 minutes ago
3igddospyyyo        redis.3             redis:3.0.7         docker-desktop      Running             Running 4 minutes ago
zp9bix3p0n6w         \_ redis.3         redis:3.0.6         docker-desktop      Shutdown            Shutdown 4 minutes ago

</pre>

```console
docker service scale redis=5
```
<pre>
redis scaled to 5
overall progress: 5 out of 5 tasks
1/5: running   [==================================================>]
2/5: running   [==================================================>]
3/5: running   [==================================================>]
4/5: running   [==================================================>]
5/5: running   [==================================================>]
verify: Service converged
</pre>

```console
docker service ps redis
```
<pre>
ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE             ERROR               PORTS
us9086w3x37x        redis.1             redis:3.0.7         docker-desktop      Running             Running 15 minutes ago
o91gvlser4rg         \_ redis.1         redis:3.0.6         docker-desktop      Shutdown            Shutdown 15 minutes ago
f2rzzh54hlkl        redis.2             redis:3.0.7         docker-desktop      Running             Running 15 minutes ago
rrrb7xpsrijn         \_ redis.2         redis:3.0.6         docker-desktop      Shutdown            Shutdown 15 minutes ago
3igddospyyyo        redis.3             redis:3.0.7         docker-desktop      Running             Running 14 minutes ago
zp9bix3p0n6w         \_ redis.3         redis:3.0.6         docker-desktop      Shutdown            Shutdown 14 minutes ago
w60ob2ivrfgo        redis.4             redis:3.0.7         docker-desktop      Running             Running 41 seconds ago
ktagbhx5h6k1        redis.5             redis:3.0.7         docker-desktop      Running             Running 41 seconds ago
</pre>

Cleaning 
```console 
docker service rm redis
```
<pre>
redis
</pre>


Using stack in Swarm cluster
```console
docker service create --name registry --publish published=5000,target=5000 registry:2
```
<pre>
image registry:2 could not be accessed on a registry to record
its digest. Each node will access registry:2 independently,
possibly leading to different nodes running different
versions of the image.

k5mhcj07sii10vpund2rd0dbz
overall progress: 1 out of 1 tasks
1/1: running   [==================================================>]
verify: Service converged
</pre>



docker service ls
ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
k5mhcj07sii1        registry            replicated          1/1                 registry:2          *:5000->5000/tcp


curl http://localhost:5000/v2/
{}

```console
mkdir stackdemo
cd stackdemo
```

Inside stackdemo put several files

app.py

```python
from flask import Flask
from redis import Redis

app = Flask(__name__)
redis = Redis(host='redis', port=6379)

@app.route('/')
def hello():
    count = redis.incr('hits')
    return 'Hello World! I have been seen {} times.\n'.format(count)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)

```

requirements.txt

```
flask
redis
```

Dockerfile

```Dockerfile
FROM python:3.4-alpine
ADD . /code
WORKDIR /code
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
```


docker-compose.yaml

```yaml
version: '3'

services:
  web:
    image: 127.0.0.1:5000/stackdemo
    build: .
    ports:
      - "8000:8000"
  redis:
    image: redis:alpine

```


docker-compose up -d

<pre>

WARNING: The Docker Engine you're using is running in swarm mode.

Compose does not use swarm mode to deploy services to multiple nodes in a swarm. All containers will be scheduled on the current node.

To deploy your application across the swarm, use `docker stack deploy`.

Creating network "stackdemo_default" with the default driver
Building web
Step 1/5 : FROM python:3.4-alpine
3.4-alpine: Pulling from library/python
8e402f1a9c57: Pulling fs layer
cda9ba2397ef: Pulling fs layer
aafecf9bbbfd: Pulling fs layer
.....
Status: Downloaded newer image for redis:alpine
Creating stackdemo_redis_1 ... done
Creating stackdemo_web_1   ... done
</pre>

```console 
docker-compose  ps
```
<pre>
Name                     Command               State           Ports
-----------------------------------------------------------------------------------
stackdemo_redis_1   docker-entrypoint.sh redis ...   Up      6379/tcp
stackdemo_web_1     python app.py                    Up      0.0.0.0:8000->8000/tcp
</pre>

```console
curl http://localhost:8000
```
<pre>
Hello World! I have been seen 1 times.

Hello World! I have been seen 2 times.

Hello World! I have been seen 3 times.

Hello World! I have been seen 4 times.
</pre>


```console
docker-compose down --volumes
```
<pre>
Stopping stackdemo_redis_1 ... done
Stopping stackdemo_web_1   ... done
Removing stackdemo_redis_1 ... done
Removing stackdemo_web_1   ... done
</pre>

```console
docker-compose push
```
<pre>
Pushing web (127.0.0.1:5000/stackdemo:latest)...
The push refers to repository [127.0.0.1:5000/stackdemo]
f99a357b1d5b: Pushed
70749f2bdfa0: Pushed
62de8bcc470a: Pushed
58026b9b6bf1: Pushed
fbe16fc07f0d: Pushed
aabe8fddede5: Pushed
bcf2f368fe23: Pushed
latest: digest: sha256:98df9a6978b4f1e1ba2b86943bc3dd6c2f2eab6493410679b294174945624540 size: 1786
</pre>

```console
docker stack deploy --compose-file docker-compose.yaml stackdemo
```
<pre>
Ignoring unsupported options: build

Creating network stackdemo_default
Creating service stackdemo_redis
Creating service stackdemo_web
</pre>
```console
docker stack services stackdemo
```
<pre>
ID                  NAME                MODE                REPLICAS            IMAGE                             PORTS
mhgogkj75lne        stackdemo_redis     replicated          1/1                 redis:alpine
xkrkpbz1s4ma        stackdemo_web       replicated          1/1                 127.0.0.1:5000/stackdemo:latest   *:8000->8000/tcp
</pre>

```console
curl http://localhost:8000

```
<pre>
Hello World! I have been seen 1 times.

Hello World! I have been seen 2 times.

Hello World! I have been seen 3 times.

Hello World! I have been seen 4 times.
</pre>

```console
docker stack rm stackdemo
```
<pre>
Removing service stackdemo_redis
Removing service stackdemo_web
Removing network stackdemo_default
</pre>

```console
docker service rm registry
```

<pre>
registry
</pre>

```console
docker swarm leave --force
```
<pre>
Node left the swarm.
</pre>
```console
docker info
```
<pre>
...
Swarm: inactive
...
</pre>
Literature:


https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/

https://docs.docker.com/engine/swarm/stack-deploy/

