### Using Clair to scan local docker images

#### Create new docker network (bridge driver)

```console
docker network create clair
```
<pre>
6ec758aba7be3d6847a833dcab845713bb15b99662211e5db7e872c77402ff42
</pre>
#### Listing all docker networks
```console
docker network ls

```
<pre>
NETWORK ID          NAME                DRIVER              SCOPE
45394c24d29e        bridge              bridge              local
6ec758aba7be        clair               bridge              local
847e487b5519        host                host                local
bf5b21d9917f        none                null                local
</pre>
##### Creating docker volume to postgresql storage

```console
docker volume create --name clair-postgres
```
<pre>
clair-postgres
</pre>

```console
docker volume ls 
```
<pre>
DRIVER              VOLUME NAME
local               clair-postgres
</pre>

#### Pull latest clair Docker image 
```console
docker pull  arminc/clair-db:latest
```
<pre>
latest: Pulling from arminc/clair-db
6c40cc604d8e: Pull complete 
3ea5fa93d025: Pull complete 
146f5c88cacb: Pull complete 
1549d653d730: Pull complete 
1f52f9ddebb6: Pull complete 
a4c85e4b61b7: Pull complete 
a562b26ea57a: Pull complete 
04f1f3b24313: Pull complete 
f2684c2bfb4b: Pull complete 
96c035fc29cd: Pull complete 
Digest: sha256:882fac86452e7386dbb1eeec08bf09246056e07cb2b51d419c359c998e3b8e3a
Status: Downloaded newer image for arminc/clair-db:latest
docker.io/arminc/clair-db:latest
</pre>

#### Run the image -> create container
```console
docker run --detach \
   --name clair-postgres \
   --publish 5432:5432 \
   --net clair \
   --volume clair-postgres:/var/lib/postgresql/data \
   arminc/clair-db:latest
```
<pre>
01529eecfe8a26644f0474e26ff549f875f4fa859456389fb5679cb27a9b437e
</pre>

```console    
docker logs --tail  10 clair-postgres 
```

<pre> 
2019-11-24 20:48:13.582 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
2019-11-24 20:48:13.583 UTC [1] LOG:  listening on IPv6 address "::", port 5432
2019-11-24 20:48:13.586 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2019-11-24 20:48:13.625 UTC [18] LOG:  database system was shut down at 2019-11-22 04:12:37 UTC
2019-11-24 20:48:13.640 UTC [1] LOG:  database system is ready to accept connections
</pre>   


#### Create config file 
```console
curl --silent https://raw.githubusercontent.com/nordri/config-files/master/clair/config-clair.yaml | sed "s/POSTGRES_NAME/clair-postgres/" > config.yaml
```
<pre>

</pre>


```console
docker run --detach \
  --name clair \
  --net clair \
  --publish 6060:6060 \
  --publish 6061:6061 \
  --volume ${PWD}/config.yaml:/config/config.yaml \
  quay.io/coreos/clair:latest -config /config/config.yaml
```
<pre>
cd0e687e9d6bc96c6d834efbd9ce9c56bd08c13430e8f703bbad935625571615
</pre>



#### Downbload the lates clair-scanner

```console
wget  https://github.com/arminc/clair-scanner/releases/download/v12/clair-scanner_linux_amd64
```
<pre>
Connecting to github.com (140.82.114.3:443)
Connecting to github-production-release-asset-2e65be.s3.amazonaws.com (52.216.141.100:443)
clair-scanner_linux_ 100% |**************************************************************************************| 9631k  0:00:00 ETA

</pre>

#### Build the docker image

```docker
FROM debian:jessie

COPY clair-scanner_linux_amd64 /clair-scanner
RUN chmod +x /clair-scanner
```


```console
docker build -t djkormo/clair-scanner .
```
<pre>
Sending build context to Docker daemon  48.01MB
Step 1/3 : FROM debian:jessie
jessie: Pulling from library/debian
a5019387ad9d: Pull complete 
Digest: sha256:9eaf4a70aeddf435bebc619383f3e3a178b8ad8c1f3948319cdf74b65918d156
Status: Downloaded newer image for debian:jessie
 ---> 4cb524c015d4
Step 2/3 : COPY clair-scanner_linux_amd64 /clair-scanner
 ---> 31c2789a192b
Step 3/3 : RUN chmod +x /clair-scanner
 ---> Running in 75e0c78523a1
Removing intermediate container 75e0c78523a1
 ---> 6f92411c370c
Successfully built 6f92411c370c
Successfully tagged djkormo/clair-scanner:latest
</pre>



#### Run the build docker 
```console
docker run -ti \
  --rm \
  --name clair-scanner \
  --net clair \
  -v /var/run/docker.sock:/var/run/docker.sock \
  djkormo/clair-scanner:latest /bin/bash
```

#### Inside docker
```console
export IP=$(ip r | tail -n1 | awk '{ print $9 }')
echo $IP 
/clair-scanner --ip ${IP} --clair=http://clair:6060 --threshold="Critical" debian:jessie
```
<pre>
172.19.0.4

</pre>

#### Let's pull some bad images
```console
docker pull node:10
docker pull imiell/bad-dockerfile
```

<pre>

</pre>
##### Run local image with clair scanner
bash ./run-local.bash 

#### Inside container
```console
./run-scanner.bash -n node:10 -t Critical
or 
./run-scanner.bash -n node:10 -t Critical
```

#### Links:

https://cloud.docker.com/repository/docker/arminc/clair-db
https://www.muspells.net/blog/2019/05/docker-image-scanner-for-vulnerabilities-with-clair/
https://nullsweep.com/docker-static-analysis-with-clair/


