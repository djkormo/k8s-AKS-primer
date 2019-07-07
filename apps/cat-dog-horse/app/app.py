import json
import os
import io

# Imports for the REST API
from flask import Flask, request, jsonify
from flask_restplus import Api, Resource, fields, cors
from flask_cors import CORS, cross_origin


from werkzeug.datastructures import FileStorage

# Imports for image procesing
from PIL import Image

# Imports for prediction
from predict import initialize, predict_image, predict_url


app = Flask(__name__)
# enabling CORS
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'


api = Api(app, version='1.0', title='Classification API',
    description='A classification API for cats, dogs and horses in images',
)
# name space 
ns = api.namespace('', description='Operations for Classification API')


@ns.route('/health')  #  Create a URL route to this resource
class HelloWorld(Resource):            #  Create a RESTful resource
  def get(self):                     #  Create GET endpoint
    #return {'hello': 'world'}
    return '', 200



UPLOAD_KEY = 'imageData'
UPLOAD_LOCATION = 'files'
upload_parser = api.parser()
upload_parser.add_argument(UPLOAD_KEY,
                           location=UPLOAD_LOCATION,
                           type=FileStorage,
                           required=True)
        
@ns.route('/prediction')
class GanPrediction(Resource):
  @ns.doc(description='Return one of three classes (cat,dog,hose). ' +
  'Returns the probability of chosen class',
  responses={
    200: "Success",
    400: "Bad request",
    500: "Internal server error"
  })
  @ns.expect(upload_parser)
  #@cors.crossdomain(origin='*')
  @cross_origin()
  def post(self):
    try:
        imageData = None
        if ('imageData' in request.files):
            imageData = request.files['imageData']
        elif ('imageData' in request.form):
            imageData = request.form['imageData']
        else:
            imageData = io.BytesIO(request.get_data())

        img = Image.open(imageData)
        results = predict_image(img)
        return jsonify(results)
    except Exception as e:
        print('EXCEPTION:', str(e))
        return 'Error processing image', 500
    #return {'prediction': 'prediction'}
    
    
@app.route("/abc")
@cross_origin() # allow all origins all methods.
def helloWorld():
  return "Hello, cross-origin-world!"    
  

# 4MB Max image size limit
app.config['MAX_CONTENT_LENGTH'] = 4 * 1024 * 1024 

# Default route just shows simple text
@app.route('/')
def index():
    return 'CustomVision.ai model host harness'

# Like the CustomVision.ai Prediction service /image route handles either
#     - octet-stream image file 
#     - a multipart/form-data with files in the imageData parameter
@app.route('/image', methods=['POST'])
@app.route('/<project>/image', methods=['POST'])
@app.route('/<project>/image/nostore', methods=['POST'])

def predict_image_handler(project=None):
    try:
        imageData = None
        if ('imageData' in request.files):
            imageData = request.files['imageData']
        elif ('imageData' in request.form):
            imageData = request.form['imageData']
        else:
            imageData = io.BytesIO(request.get_data())

        img = Image.open(imageData)
        results = predict_image(img)
        return jsonify(results)
    except Exception as e:
        print('EXCEPTION:', str(e))
        return 'Error processing image', 500


# Like the CustomVision.ai Prediction service /url route handles url's
# in the body of hte request of the form:
#     { 'Url': '<http url>'}  
@app.route('/url', methods=['POST'])
@app.route('/<project>/url', methods=['POST'])
@app.route('/<project>/url/nostore', methods=['POST'])
def predict_url_handler(project=None):
    try:
        image_url = json.loads(request.get_data().decode('utf-8'))['url']
        results = predict_url(image_url)
        return jsonify(results)
    except Exception as e:
        print('EXCEPTION:', str(e))
        return 'Error processing image'

if __name__ == '__main__':
    # Load and intialize the model
    initialize()

    # Run the server
    app.run(host='0.0.0.0', port=80)