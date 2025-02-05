import os
import json
import urllib.request
import urllib.error

def lambda_handler(event, context):

    API_ENDPOINT = os.environ["API_ENDPOINT"]
    SUBNET_ID = os.environ["SUBNET_ID"],
    NAME = os.environ["NAME"],
    EMAIL = os.environ["EMAIL"]

    payload = {
        "subnet_id": SUBNET_ID,
        "name": NAME,
        "email": EMAIL
    }

    # Convert payload to JSON
    json_data = json.dumps(payload).encode("utf-8")

    # Headers for the API request
    headers = {
        "X-Siemens-Auth": "test",
        "Content-Type": "application/json"
    }

    # Prepare the request
    req = urllib.request.Request(
        "https://bc1yy8dzsg.execute-api.eu-west-1.amazonaws.com/v1/data",
        data=json_data,
        headers=headers,
        method="POST"
    )
    
    try:
        req = urllib.request.Request(API_ENDPOINT, json_data, headers)
        with urllib.request.urlopen(req) as f:
            res = f.read()
        return res.decode()
    except Exception as e:
        return e

    