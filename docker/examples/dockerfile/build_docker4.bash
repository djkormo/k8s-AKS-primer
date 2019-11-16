docker build -t mnist:v4 -f ./Dockerfile4 .
docker run -p 8084:80 -d mnist:v4