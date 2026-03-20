def lambda_handler(event, context):
    # Log the received event for debugging
    print("Received event:", event)

    # Extract the body from the event
    body = event.get('body', '{}')
    print("Extracted body:", body)

    # Here you can add your logic to process the body and interact with Bedrock or other services

    # For demonstration, we'll just return a success response
    response = {
        'statusCode': 200,
        'body': 'Request processed successfully'
    }
    
    return response