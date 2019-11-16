docker build -t mnist:v2 -f ./Dockerfile2 .
docker run -p 8082:80 -d mnist:v2