import urllib.request
import json
import os
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    # Get environment variables
    required_env_vars = ['API_ENDPOINT', 'SUBNET_ID', 'CANDIDATE_NAME', 'CANDIDATE_EMAIL']
    env_vars = {}
    
    # Validate environment variables
    for var in required_env_vars:
        if var not in os.environ:
            error_msg = f"Missing required environment variable: {var}"
            logger.error(error_msg)
            raise ValueError(error_msg)
        env_vars[var] = os.environ[var]
    
    # Log input event
    logger.info(f"Received event: {json.dumps(event)}")
    
    payload = {
        "subnet_id": env_vars['SUBNET_ID'],
        "name": env_vars['CANDIDATE_NAME'],
        "email": env_vars['CANDIDATE_EMAIL']
    }
    
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-Siemens-Auth": "test"
    }
    
    try:
        data = json.dumps(payload).encode("utf-8")
        logger.info(f"Sending request to {env_vars['API_ENDPOINT']} with payload: {payload}")
        
        req = urllib.request.Request(env_vars['API_ENDPOINT'], data, headers)
        with urllib.request.urlopen(req) as f:
            response = f.read().decode()
            logger.info(f"Received response: {response}")
            return {
                "statusCode": 200,
                "body": response
            }
    except Exception as e:
        logger.error(f"Error occurred: {str(e)}")
        return {
            "statusCode": 500,
            "body": str(e)
        }