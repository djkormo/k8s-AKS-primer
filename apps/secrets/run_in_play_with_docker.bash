docker run -p 3000:3000 -d djkormo/secrets:hardcode

docker run -p 3001:3000 -d -e LANGUAGE='Polish' -e API_KEY='987-654-321' \
  djkormo/secrets:envvars 


docker run -p 3002:3000 -d \
-v $(pwd)/secret/:/usr/src/app/secret/ \
-v $(pwd)/config/:/usr/src/app/config/ \
djkormo/secrets:file 