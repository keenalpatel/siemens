# lambda_function.py
import os
import json
import boto3
import base64
import requests

def lambda_handler(event, context):
    # Payload for the API request
    payload = {
        "subnet_id": os.environ["SUBNET_ID"],
        "name": os.environ["NAME"],
        "email": os.environ["EMAIL"]
    }

    # Headers for the API request
    headers = {
        "X-Siemens-Auth": "test"
    }

    # Invoke the remote API
    response = requests.post(
        "https://bc1yy8dzsg.execute-api.eu-west-1.amazonaws.com/v1/data",
        headers=headers,
        json=payload
    )

    # Log the response
    print("API Response:", response.text)

    # Return the response
    return {
        "statusCode": response.status_code,
        "body": response.text
    }