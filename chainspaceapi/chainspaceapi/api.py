import requests
import json, ast
import time
import random
from json import dumps, loads

from chainspacecontract import ChainspaceObject

class ChainspaceClient(object):
    def __init__(self, host='127.0.0.1', port=5000, max_retries=1, max_wait=10):
        self.host = host
        self.port = port
        self.max_retries = max_retries
        self.max_wait=max_wait

    @property
    def url(self):
        return 'http://{}:{}'.format(self.host, self.port)

    def process_transaction(self, transaction):
        success = False
        retries=0
        r = None
        while not success and retries<self.max_retries:
            if retries>0:
                print "Retrying..."
                time.sleep(self.max_wait)
            endpoint = self.url + '/api/1.0/transaction/process'
            print "POST " + endpoint + " HTTP/1.1"
            print "" + json.dumps(transaction)
            r = requests.post(endpoint, json=transaction)

            if r.status_code==200:
                success=True
            retries+=1
        print "HTTP/1.1 " + str(r.status_code) + " " + r.reason
        print r.json()
            
        return r

    def dump_transaction(self, transaction):
        endpoint = self.url + '/api/1.0/transaction/dump'
        r = requests.post(endpoint, json=transaction)
        return r
    
    def fix_json(self, obj):
        obj = ast.literal_eval(obj)
        obj = dumps(obj)
        return obj

    def get_objects(self, filters={}):
        endpoint = self.url + '/api/1.0/objects'
        r = requests.get(endpoint, params={'status':1})
        # print r.url
        # print "HTTP/1.1 " + str(r.status_code) + " " + r.reason
        # print r.json()
        objects = []
        for i in r.json():
            obj = loads(self.fix_json(dumps(i)))
            csobj = ChainspaceObject(obj['id'], dumps(obj['value']))
            accept = True
            for key, value in filters.items():
                obj = ast.literal_eval(str(csobj))
                if obj[key] != value:
                    accept = False
                    break
            if not accept:
                continue
            objects.append(csobj)
        return objects
        
