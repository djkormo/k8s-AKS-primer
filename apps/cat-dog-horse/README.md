### Model generated at https://www.customvision.ai/

#### Tested at https://labs.play-with-docker.com

git clone https://github.com/djkormo/ContainersSamples.git

cd ContainersSamples/Docker/customvision-ai-cat-dog-horse-sample/


How to build:
==============================================

docker build -t  customvision-ai .

How to run locally:
==============================================
docker run -p 33000:80 -d customvision-ai



Then use your favorite tool to connect to the end points.

POST http://127.0.0.1:33000/image with multipart/form-data using the imageData key
e.g
	curl -X POST http://127.0.0.1:33000/image -F imageData=@some_file_name.jpg

POST http://127.0.0.1:33000/image with application/octet-stream
e.g.
	curl -X POST http://127.0.0.1:33000/image -H "Content-Type: application/octet-stream" --data-binary @some_file_name.jpg



For information on how to use these files to create and deploy through AzureML check out the readme.txt in the azureml directory.


Some pictures saved in images directory.


Examples:

##### 1

curl -X POST http://127.0.0.1:33000/image -F imageData=@images/cat1.jpg


{
  "created": "2019-02-17T22:50:13.088601",
  "id": "",
  "iteration": "",
  "predictions": [
    {
      "boundingBox": null,
      "probability": 1.0,
      "tagId": "",
      "tagName": "cat"
    }
  ],
  "project": ""
}

##### 2

curl -X POST http://127.0.0.1:33000/image -F imageData=@images/cat2.jpg

{
  "created": "2019-02-17T22:50:35.186215",
  "id": "",
  "iteration": "",
  "predictions": [
    {
      "boundingBox": null,
      "probability": 1.0,
      "tagId": "",
      "tagName": "cat"
    }
  ],
  "project": ""
}

##### 3

curl -X POST http://127.0.0.1:33000/image -F imageData=@images/dog1.jpg

{
  "created": "2019-02-17T22:50:56.874340",
  "id": "",
  "iteration": "",
  "predictions": [
    {
      "boundingBox": null,
      "probability": 1.0,
      "tagId": "",
      "tagName": "dog"
    }
  ],
  "project": ""
}



##### 4

curl -X POST http://127.0.0.1:33000/image -F imageData=@images/dog2.jpg

{
  "created": "2019-02-17T22:51:21.509273",
  "id": "",
  "iteration": "",
  "predictions": [
    {
      "boundingBox": null,
      "probability": 1.0,
      "tagId": "",
      "tagName": "dog"
    }
  ],
  "project": ""
}
##### 5

curl -X POST http://127.0.0.1:33000/image -F imageData=@images/horse1.jpg

{
  "created": "2019-02-17T22:49:21.158930",
  "id": "",
  "iteration": "",
  "predictions": [
    {
      "boundingBox": null,
      "probability": 1.0,
      "tagId": "",
      "tagName": "dog"
    }
  ],
  "project": ""
}

##### 6

curl -X POST http://127.0.0.1:33000/image -F imageData=@images/horse2.jpg


{
  "created": "2019-02-17T22:48:06.126164",
  "id": "",
  "iteration": "",
  "predictions": [
    {
      "boundingBox": null,
      "probability": 0.0015334499767050147,
      "tagId": "",
      "tagName": "dog"
    },
    {
      "boundingBox": null,
      "probability": 0.9984666109085083,
      "tagId": "",
      "tagName": "horse"
    }
  ],
  "project": ""
}






