Using Jobs and CronJobs in Kubernetes


```console
kubectl apply -f job.yaml -n default
```
<pre>
job.batch/countdown created
</pre>


```console
kubectl apply -f cronjob.yaml -n default
```
<pre>
cronjob.batch/middle created
</pre>


Literature:

https://medium.com/google-cloud/kubernetes-running-background-tasks-with-batch-jobs-56482fbc853

https://medium.com/jobteaser-dev-team/kubernetes-cronjob-101-56f0a8ea7ca2

