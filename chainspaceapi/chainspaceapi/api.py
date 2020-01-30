import requests
import json, ast
from json import dumps, loads

from chainspacecontract import ChainspaceObject

class ChainspaceClient(object):
    def __init__(self, host='127.0.0.1', port=5000):
        self.host = host
        self.port = port

    @property
    def url(self):
        return 'http://{}:{}'.format(self.host, self.port)

    def process_transaction(self, transaction):
        endpoint = self.url + '/api/1.0/transaction/process'
        print "POST " + endpoint + " HTTP/1.1"
        print "" + json.dumps(transaction)
        r = requests.post(endpoint, json=transaction)

        print "HTTP/1.1 " + str(r.status_code) + " " + r.reason
        print r.json()
        return r

    def dump_transaction(self, transaction):
        endpoint = self.url + '/api/1.0/transaction/dump'
        r = requests.post(endpoint, json=transaction)
        return r

    def get_objects(self, filters):
        endpoint = self.url + '/api/1.0/objects'
        r = requests.get(endpoint, params=filters)
        print r.url
        print "HTTP/1.1 " + str(r.status_code) + " " + r.reason
        print r.json()
        objects = []
        for i in r.json():
            obj = ast.literal_eval(dumps(i))
            objects.append(ChainspaceObject(obj['id'], obj['value']))
        return objects
        