import os
import json
import urllib.request
import urllib.error

def lambda_handler(event, context):

    payload = {
        "subnet_id": os.environ["SUBNET_ID"],
        "name": os.environ["NAME"],
        "email": os.environ["EMAIL"]
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
        # Invoke the remote API
        with urllib.request.urlopen(req) as response:
            response_data = response.read().decode("utf-8")
            print("API Response:", response_data)
            return {
                "statusCode": response.getcode(),
                "body": response_data
            }
    except urllib.error.HTTPError as e:
        error_message = e.read().decode("utf-8")
        print("API Request Failed:", error_message)
        return {
            "statusCode": e.code,
            "body": json.dumps({"error": error_message})
        }
    except urllib.error.URLError as e:
        print("API Request Failed:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }