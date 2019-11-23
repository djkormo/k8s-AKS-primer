### Examples for Control Groups and Namespaces with Docker


Let's  run container with Ubuntu image

```console
docker run -it --rm ubuntu /bin/bash
```
<pre>
root@xxxxxxxxx
</pre>

From host point of view. Loook what pid  the ubuntu container is using

```console
docker inspect --format "{{.State.Pid}}"  container_id
```
<pre>
xxxx
</pre>

Look at processes inside our container

```console
ps -fp xxxx
```
<pre>

</pre>


```console
cat -v /proc/xxx/environ
```
<pre>

</pre>
No we have our HOSTNAME environment variable

Once again inside the ubuntu container
```console
ps -ef
```
<pre>

</pre>

Inside the container /bin/bash process is using PID equals 1  and its root (PPID) PID equals 0.


Tet's run three container with apache2 server.
```console
docker run -d httpd:2.4
docker run -d httpd:2.4
docker run -d httpd:2.4

docker ps
```

<pre>
CONTAINER ID        IMAGE               COMMAND              CREATED             STATUS              PORTS               NAMES
3aabc5aa6a18        httpd:2.4           "httpd-foreground"   4 seconds ago       Up 3 seconds        80/tcp              elated_bhaskara
27adb9503c95        httpd:2.4           "httpd-foreground"   9 seconds ago       Up 7 seconds        80/tcp              gallant_driscoll
8c3a6139262d        httpd:2.4           "httpd-foreground"   44 seconds ago      Up 43 seconds       80/tcp              angry_varahamihira
</pre>

```console
ifconfig 
```
<pre>
veth4e57d7b Link encap:Ethernet  HWaddr 42:D1:5D:39:D2:3A  
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

vethb4ada4f Link encap:Ethernet  HWaddr AA:CF:61:3D:E3:43  
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

vethec72ef3 Link encap:Ethernet  HWaddr 92:98:CD:C1:CA:36  
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
</pre>


```console
docker exec -it 3aabc5aa6a18 /bin/bash
```
<pre>
root@3aabc5aa6a18:/usr/local/apache2# cat /proc/mounts
...
cgroup /sys/fs/cgroup/systemd cgroup ro,nosuid,nodev,noexec,relatime,xattr,release_agent=/lib/systemd/systemd-cgroups-agent,name=systemd 0 0
cgroup /sys/fs/cgroup/perf_event cgroup ro,nosuid,nodev,noexec,relatime,perf_event 0 0
cgroup /sys/fs/cgroup/freezer cgroup ro,nosuid,nodev,noexec,relatime,freezer 0 0
cgroup /sys/fs/cgroup/cpuset cgroup ro,nosuid,nodev,noexec,relatime,cpuset 0 0
cgroup /sys/fs/cgroup/devices cgroup ro,nosuid,nodev,noexec,relatime,devices 0 0
cgroup /sys/fs/cgroup/pids cgroup ro,nosuid,nodev,noexec,relatime,pids 0 0
cgroup /sys/fs/cgroup/cpu,cpuacct cgroup ro,nosuid,nodev,noexec,relatime,cpu,cpuacct 0 0
cgroup /sys/fs/cgroup/hugetlb cgroup ro,nosuid,nodev,noexec,relatime,hugetlb 0 0
cgroup /sys/fs/cgroup/blkio cgroup ro,nosuid,nodev,noexec,relatime,blkio 0 0
cgroup /sys/fs/cgroup/net_cls,net_prio cgroup ro,nosuid,nodev,noexec,relatime,net_cls,net_prio 0 0
cgroup /sys/fs/cgroup/memory cgroup ro,nosuid,nodev,noexec,relatime,memory 0 0
...
</pre>

```console
docker inspect --format "{{.State.Pid}}"  3aabc5aa6a18
```
<pre>
5454  
</pre>

```console
cat -v /proc/5454/environ
```


<pre>
HTTPD_VERSION=2.4.41^@HOSTNAME=3aabc5aa6a18^@HOME=/root^@HTTPD_PATCHES=^@PATH=/usr/local/apache2/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin^@HTTPD_SHA256=133d48298fe5315ae9366a0ec66282fa4040efa5d566174481077ade7d18ea40^@HTTPD_PREFIX=/usr/local/apache2^@PWD=/usr/local/apache2^
</pre>

```console
sudo ls /proc/5454/ns
```
<pre>
cgroup  ipc     mnt     net     pid     user    uts
</pre>

```console
cd /sys/fs/cgroup/memory/docker/3aabc5aa6a187f14c494098c58726ce3b29fbf388e3b7b94174cc28a9f1f7605/
cat cat memory.max_usage_in_bytes 

cd /sys/fs/cgroup/cpu/docker/3aabc5aa6a187f14c494098c58726ce3b29fbf388e3b7b94174cc28a9f1f7605/
cat cpuacct.usage

```

<pre>
...
83320832   # (in bytes)
...
5477358944  # (in nanoseconds)
...
</pre>

