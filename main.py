'''
Created on 08/17/2016
@author: andrey.vaker
'''
import os
from tornado import ioloop, web, wsgi
from pymongo import MongoClient
import json
from bson import json_util
import time
import tornado.httpserver
import logging
import logging.handlers

MONGODB_DB_URL = os.environ.get('MLAB_DB_URL') if os.environ.get('MLAB_DB_URL') else 'mongodb://localhost:27017/'
MONGODB_DB_NAME = os.environ.get('MLAB_DB_NAME') if os.environ.get('MLAB_DB_NAME') else 'tcontrol'

REST_PATH = "/api/v1/temperatures"

hn = logging.NullHandler()
hn.setLevel(logging.DEBUG)
logging.getLogger("tornado.access").addHandler(hn)
logging.getLogger("tornado.access").propagate = False

client = MongoClient(MONGODB_DB_URL, connect=False)
db = client[MONGODB_DB_NAME]
 
class IndexHandler(web.RequestHandler):
    def get(self):
        self.render("index.html", path="http://" + self.request.host + REST_PATH)
        
class TemperaturesHandler(web.RequestHandler):
    def get(self):
        temperatures = db.temperatures.find()
        self.set_header("Content-Type", "application/json")
        self.write(json.dumps(list(temperatures),default=json_util.default))
  
    def post(self):
        time.time()
        temperature_data = json.loads(self.request.body)
        temperature_data['create_date'] = time.time()
        db.temperatures.insert(temperature_data)
        self.set_header("Content-Type", "application/json")
        self.set_status(201)     
        self.write(json.dumps((temperature_data),default=json_util.default))   
        
settings = {
    "template_path": os.path.join(os.path.dirname(__file__), "templates"),
    "static_path": os.path.join(os.path.dirname(__file__), "static"),
    "debug" : True
}

app = web.Application([
    (r'/', IndexHandler),
    (r'/index', IndexHandler),
    (REST_PATH,TemperaturesHandler),
    ], **settings)

application = tornado.wsgi.WSGIAdapter(app)

#def main():
#    application = app
#    http_server = tornado.httpserver.HTTPServer(application)
#    port = int(os.environ.get("PORT", 5000))
#    http_server.listen(port)
#    ioloop.IOLoop.instance().start() 
    
#if __name__ == "__main__":
#    main()
