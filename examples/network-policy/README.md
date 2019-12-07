

Testing in play with docker sandbox

### Run logic	
```console
docker run -d -p 5000:5000 djkormo/np-logic
```

#### testing from curl

```console
curl http://localhost:5000/analyse/sentiment -X POST --header "Content-Type: application/json"  -d '{"sentence": "I love to drink beer"}'

curl http://localhost:5000/analyse/sentiment -X POST --header "Content-Type: application/json"  -d '{"sentence": "I hate my life"}'
```

#### run webapp

```console
docker run -d -p 8080:8080 -e SA_LOGIC_API_URL='http://ip172-18-0-13-bkkt6dpt0o8g009t5rr0-5000.direct.labs.play-with-docker.com/' djkormo/np-webapp	
```


##### testing from curl

```console
curl http://localhost:8080/sentiment/ -X POST  --header "Content-Type: application/json"  -d '{"sentence": "I love yogobella"}'

curl http://localhost:8080/sentiment/ -X POST  --header "Content-Type: application/json"  -d '{"sentence": "I hate my mother"}'
```

#### run frontend 
```console

docker run -d -p 80:80  -e SA_WEBAPP_API_URL='http://localhost:8000/sentiment/' djkormo/np-frontend
``` 