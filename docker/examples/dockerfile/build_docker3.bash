docker build -t mnist:v3 -f ./Dockerfile3 .
docker run -p 8083:80 -d mnist:v3