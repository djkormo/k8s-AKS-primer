
## Testing in play with docker sandbox

### Run logic	
```console
docker run -d -p 5000:5000 --name np-logic  djkormo/np-logic
```

#### testing from curl

```console
curl http://localhost:5000/analyse/sentiment -X POST --header "Content-Type: application/json"  -d '{"sentence": "I love to drink beer"}'

curl http://localhost:5000/analyse/sentiment -X POST --header "Content-Type: application/json"  -d '{"sentence": "I hate my life"}'

docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' np-logic

```

#### run webapp

```console

NP_LOGIC_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' np-logic );
echo $NP_LOGIC_IP

docker run -d -p 8080:8080 -e SA_LOGIC_API_URL="http://$NP_LOGIC_IP:5000" \
--name np-webapp djkormo/np-webapp	
```


docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' np-webapp


##### testing from curl

```console
curl http://localhost:8080/sentiment/ -X POST  --header "Content-Type: application/json"  -d '{"sentence": "I love yogobella"}'

curl http://localhost:8080/sentiment/ -X POST  --header "Content-Type: application/json"  -d '{"sentence": "I hate my mother"}'
```

#### run frontend 
```console
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' np-webapp


NP_WEBAPP_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' np-webapp );
echo $NP_WEBAPP_IP

docker run -d -p 80:80  -e SA_WEBAPP_API_URL="http://$NP_WEBAPP_IP:8080/sentiment/" --name np-frontend djkormo/np-frontend
``` 






