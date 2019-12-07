from textblob import TextBlob
from flask import Flask, request, jsonify
from flask_restplus import Api, Resource, fields, cors
from flask_cors import CORS, cross_origin

app = Flask(__name__)
# enabling CORS
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'

api = Api(app, version='1.0', title='Sentiment API',
    description='Sentiment API',
)
# name space 
ns = api.namespace('', description='Operations for Sentiment API')


@ns.route('/health')  #  Create a URL route to this resource
class HelloWorld(Resource):            #  Create a RESTful resource
  def get(self):                     #  Create GET endpoint
    #return {'hello': 'world'}
    return '', 200


# was @app.route
@ns.route("/analyse/sentiment")
class Sentiment(Resource): 
  def post(self):
    sentence = request.get_json(force=True)['sentence']
    polarity = TextBlob(sentence).sentences[0].polarity
    return jsonify(
        sentence=sentence,
        polarity=polarity
    )


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)