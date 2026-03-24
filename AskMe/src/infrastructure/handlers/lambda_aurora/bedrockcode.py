import boto3
import time
import os

#dynamodb client
dynamodb = boto3.resource('dynamodb')
table    = dynamodb.Table(os.environ['askme-table'])
    
#bedrock client
bedrock  = boto3.client('bedrock-agent-runtime')


def lambda_handler(event, context):
    
    #WhatsApp json
    user_id      = event.get('user_id') 
    user_message = event.get('message')
    current_time = int(time.time())

    #searchs in dynamodb user's conversation history

    #calls bedrock agent runtime with the user message and conversation history
    response = bedrock.retrieve_and_generate(
        input={'text': user_message},
        retrieveAndGenerateConfig={
            'type': 'KNOWLEDGE_BASE',
            'knowledgeBaseConfiguration': {
                'knowledgeBasedID': '<my_id_here>',
                'modelArn': 'arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-haiku-20240307-v1:0'
            }
        }
    )

    bot_response = response['output']['text']


    #save in dynamo
    table.put_item(
        Item={
            'session_id': user_id,
            'timestame' : current_time,
            'user_message': user_message,
            'bot_message': bot_response
        }
    )

    return {
        'statusCode': 200,
        'body': bot_response
    }