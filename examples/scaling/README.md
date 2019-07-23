
kubectl apply -f apache-php-api.yaml

kubectl apply -f apache-php-api-service.yaml

kubectl apply -f apache-php-api-hpa.yaml

#kubectl autoscale deployment apache-php-api --cpu-percent=20 --min=1 --max=10

kubectl get hpa apache-php-api
kubectl describe hpa apache-php-api


while true; do curl -X Get http://52.236.36.219/; done

#### start 
> $ kubectl get hpa apache-php-api
> NAME             REFERENCE                   TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
> apache-php-api   Deployment/apache-php-api   70%/30%   1         10        3          7h39m

$ kubectl get hpa apache-php-api
NAME             REFERENCE                   TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
apache-php-api   Deployment/apache-php-api   43%/30%   1         10        6          7h46m

#### stop



curl -s "http://http://52.236.36.219/?[1-1000]"


#### Based on  https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/

#### https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#support-for-cooldown-delay
