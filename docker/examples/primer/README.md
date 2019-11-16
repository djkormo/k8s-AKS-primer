
### Let's begin with simple web application


### Pull our first image
```console
docker pull djkormo/chess-ai
```
<pre>
Using default tag: latest
latest: Pulling from djkormo/chess-ai
c87736221ed0: Pull complete 
bc39323385b7: Pull complete 
a3e4aab3e365: Pull complete 
94a5e01ae273: Pull complete 
3a750cd5b787: Pull complete 
52cf23093b2e: Pull complete 
ae399b23dff8: Pull complete 
8664274c5ff2: Pull complete 
89fa526c6281: Pull complete 
c82cc8242e96: Pull complete 
Digest: sha256:675eec3ecf3c731d1ff9fdc1b11114a932180983b2c820199b482f134547ed75
Status: Downloaded newer image for djkormo/chess-ai:latest
docker.io/djkormo/chess-ai:latest

</pre>


### Listing local images

```console
docker images
```
<pre>
REPOSITORY          TAG                 IMAGE ID            CREATED       SIZE
djkormo/chess-ai    latest              4d91484a5092        3 months ago  44.1MB
</pre>

### Run our image
```console
docker run -d -p 8000:80 --name chess djkormo/chess-ai
```
<pre>
8311ba5af9ea1b34ce23705afd871e840413424873fa5bd16b3c4b7cd5df6afb
</pre>

### Showing all running containers
```console
$ docker ps
```

<pre>
CONTAINER ID        IMAGE               COMMAND                 CREATED              STATUS              PORTS                  NAMES
8311ba5af9ea        djkormo/chess-ai    "httpd -D FOREGROUND"   About a minute ago   Up About a minute   0.0.0.0:8000->80/tcp   chess
</pre>

### Stoping container 
```console
docker stop chess
```
<pre>
chess
</pre>

or

```console
docker stop 8311ba5af9ea
```

<pre>

</pre>

### Showing all running containers
```console
docker ps
```
<pre>
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
</pre>
### Show all running containers history
```console
docker ps -a
```
<pre>
CONTAINER ID        IMAGE               COMMAND                 CREATED             STATUS                          PORTS               NAMES
8311ba5af9ea        djkormo/chess-ai    "httpd -D FOREGROUND"   7 minutes ago       Exited (0) About a minute ago                       chess
</pre>

#### Running code inside container
```console
docker run debian /bin/hostname
```
<pre>
Unable to find image 'debian:latest' locally
latest: Pulling from library/debian
c7b7d16361e0: Pull complete 
Digest: sha256:41f76363fd83982e14f7644486e1fb04812b3894aa4e396137c3435eaf05de88
Status: Downloaded newer image for debian:latest
22e773556541
</pre>


```console
docker run debian date
```
<pre>
Sat Nov 16 15:31:00 UTC 2019
</pre>

```console
docker run debian date +%H:%M:%S
```
<pre>
15:31:52
</pre>

```console
docker run debian true ; echo $?
```
<pre>
0
</pre>
```console
docker run debian false ; echo $?
```
<pre>
1
</pre>

#### Lets look at difference of images and containers

```console
docker image ls
```
<pre>
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
debian              latest              8e9f8546050d        4 weeks ago         114MB
djkormo/chess-ai    latest              4d91484a5092        3 months ago        44.1MB
</pre>

```console 
docker ps -a
```
<pre>
CONTAINER ID        IMAGE               COMMAND                 CREATED             STATUS                      
PORTS               NAMES
4bc09cb35704        debian              "false"                 47 seconds ago      Exited (1) 46 seconds ago                       nice_agnesi
6e1650056333        debian              "true"                  58 seconds ago      Exited (0) 57 seconds ago                       zen_noyce
f489e3fd4d9f        debian              "date"                  3 minutes ago       Exited (0) 3 minutes ago                        xenodochial_ellis
4a517bd529f9        debian              "date +%H:%M:%S"        3 minutes ago       Exited (0) 3 minutes ago                        laughing_williams
22e773556541        debian              "/bin/hostname"         5 minutes ago       Exited (0) 5 minutes ago                        focused_chaum
8311ba5af9ea        djkormo/chess-ai    "httpd -D FOREGROUND"   16 minutes ago      Exited (0) 10 minutes ago                       chess
</pre>


#### Detaching mode

```console
docker run debian date
```
<pre>
Sat Nov 16 15:45:14 UTC 2019
</pre>
```console
docker run -d debian date
```
<pre>
ff5d4dd6355200abfa253fc62001b301ad155f2cc3b57fd4ae60e0abdd08fb7e
</pre>
```console
docker logs ff5d4
```
<pre>
Sat Nov 16 15:45:48 UTC 2019
</pre>


```console
docker run debian ls
```
<pre>
bin
boot
dev
etc
home
lib
lib64
media
mnt
opt
proc
root
run
sbin
srv
sys
tmp
usr
var
</pre>


```console
docker run -t debian bash
```
<pre>
root@806012f65dc9:/#
^C
$
</pre>

```console
docker run -t -i debian bash
```
<pre>
root@5e72680bf046:/# ls   
bin   dev  home  lib64  mnt  proc  run   srv  tmp  var
boot  etc  lib   media  opt  root  sbin  sys  usr
root@5e72680bf046:/# exit
exit
</pre>

### Overriding defaults

```console
docker run debian sh -c 'echo $FOO $BAR'
```
<pre>

</pre>

```console
docker run -e FOO=foo -e BAR=bar debian sh -c 'echo $FOO $BAR'
```
<pre>
foo bar
</pre>



Sat Nov 16 15:45:48 UTC 2019

```console
cmd
```
<pre>
out
</pre>