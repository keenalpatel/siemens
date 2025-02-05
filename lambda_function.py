import os
import json
import requests

def lambda_handler(event, context):

    # Headers for the API request
    headers = {
        "X-Siemens-Auth": "test"
    }

    try:
        # Invoke the remote API
        response = requests.post(
            "https://bc1yy8dzsg.execute-api.eu-west-1.amazonaws.com/v1/data",
            headers=headers,
            json=payload
        )
        response.raise_for_status()  # Raise an exception for HTTP errors
        print("API Response:", response.text)
        return {
            "statusCode": response.status_code,
            "body": response.text
        }
    except requests.exceptions.RequestException as e:
        print("API Request Failed:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }