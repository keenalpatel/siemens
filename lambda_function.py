import urllib.request
import json
import os

def handler(event, context):
    API_ENDPOINT  = os.environ['API_ENDPOINT']
    SUBNET_ID     = os.environ['SUBNET_ID']
    CANDIDATE_NAME = os.environ['CANDIDATE_NAME']
    CANDIDATE_EMAIL = os.environ['CANDIDATE_EMAIL']

    payload = {
        "subnet_id": SUBNET_ID,
        "name": CANDIDATE_NAME,
        "email": CANDIDATE_EMAIL
    }

    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-Siemens-Auth": "test"
    }

    data = json.dumps(payload).encode("utf-8")

    try:
        req = urllib.request.Request(API_ENDPOINT, data, headers)
        with urllib.request.urlopen(req) as f:
            res = f.read()
            return res.decode()
    except Exception as e:
        return e