docker build -t mnist:v1 -f ./Dockerfile1 .
docker run -p 8081:80 -d mnist:v1