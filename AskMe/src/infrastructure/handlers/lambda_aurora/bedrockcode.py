import json
import os
import boto3
import urllib.request
from datetime import datetime

#Clients
bedrock_agent     = boto3.client('bedrock-agent-runtime', region_name='us-east-1')
dynamodb          = boto3.resource('dynamodb', region_name='us-east-1')

#Env vars
WHATSAPP_TOKEN    = os.environ.get('WHATSAPP_TOKEN')
PHONE_NUMBER_ID   = os.environ.get('PHONE_NUMBER_ID')
SYSTEM_PROMPT     = os.environ.get('SYSTEM_PROMPT')
KNOWLEDGE_BASE_ID = os.environ.get('KNOWLEDGE_BASE_ID')
MODEL_ARN         = os.environ.get('MODEL_ARN')
DYNAMODB_TABLE    = os.environ.get('DYNAMODB_TABLE')

# 🔹 Quantidade de mensagens recentes
MAX_HISTORY = 15


def enviar_mensagem_whatsapp(telefone_destino, texto_resposta):
    url = f"https://graph.facebook.com/v22.0/{PHONE_NUMBER_ID}/messages"
    headers = {
        'Authorization': f'Bearer {WHATSAPP_TOKEN}',
        'Content-Type': 'application/json'
    }
    payload = {
        "messaging_product": "whatsapp",
        "recipient_type": "individual",
        "to": telefone_destino,
        "type": "text",
        "text": {"preview_url": False, "body": texto_resposta}
    }

    data_bytes = json.dumps(payload).encode('utf-8')
    req = urllib.request.Request(url, data=data_bytes, headers=headers, method='POST')

    try:
        with urllib.request.urlopen(req) as response:
            print(f"Sucesso! Status: {response.getcode()}")
    except Exception as e:
        print(f"Erro WhatsApp: {str(e)}")


# 🔹 Buscar últimas mensagens
def buscar_historico(table, user_id):
    response = table.query(
        KeyConditionExpression=boto3.dynamodb.conditions.Key('UserId').eq(user_id),
        ScanIndexForward=False,  # mais recente primeiro
        Limit=MAX_HISTORY
    )

    items = response.get('Items', [])

    historico = []
    for item in reversed(items):
        historico.append(f"Usuário: {item['UserMessage']}")
        historico.append(f"Assistente: {item['AssistantResponse']}")

    return "\n".join(historico)


# 🔹 Buscar resumo existente
def buscar_summary(table, user_id):
    response = table.query(
        KeyConditionExpression=boto3.dynamodb.conditions.Key('UserId').eq(user_id),
        ScanIndexForward=False,
        Limit=1
    )

    items = response.get('Items', [])
    if items:
        return items[0].get('Summary', "")

    return ""


# 🔹 Atualizar resumo usando IA
def atualizar_summary(summary_antigo, historico_recente):
    prompt_resumo = f"""
Resumo atual:
{summary_antigo}

Novas interações:
{historico_recente}

Atualize o resumo da conversa em no máximo 5 linhas, mantendo apenas informações importantes.
"""

    response = bedrock_agent.retrieve_and_generate(
        input={'text': prompt_resumo},
        retrieveAndGenerateConfiguration={
            'type': 'KNOWLEDGE_BASE',
            'knowledgeBaseConfiguration': {
                'knowledgeBaseId': KNOWLEDGE_BASE_ID,
                'modelArn': MODEL_ARN
            }
        }
    )

    return response['output']['text']


def lambda_handler(event, context):
    try:
        telefone_cliente = event.get('telefone')
        mensagem_cliente = event.get('mensagem')

        if not telefone_cliente or not mensagem_cliente:
            return {'statusCode': 400, 'body': 'Faltam dados'}

        table = dynamodb.Table(DYNAMODB_TABLE)

        print(f"Mensagem recebida: {mensagem_cliente}")

        # ==========================================
        # 🧠 MEMÓRIA
        # ==========================================
        historico = buscar_historico(table, str(telefone_cliente))
        summary = buscar_summary(table, str(telefone_cliente))

        # ==========================================
        # 🧩 PROMPT INTELIGENTE
        # ==========================================
        prompt_final = f"""
{SYSTEM_PROMPT}

Resumo da conversa:
{summary}

Últimas interações:
{historico}

Contexto dos documentos:
$search_results$

Mensagem atual:
$query$
"""

        # RAG Call
        response = bedrock_agent.retrieve_and_generate(
            input={'text': mensagem_cliente},
            retrieveAndGenerateConfiguration={
                'type': 'KNOWLEDGE_BASE',
                'knowledgeBaseConfiguration': {
                    'knowledgeBaseId': KNOWLEDGE_BASE_ID,
                    'modelArn': MODEL_ARN,
                    'generationConfiguration': {
                        'promptTemplate': {
                            'textPromptTemplate': prompt_final
                        }
                    }
                }
            }
        )

        resposta_ia = response['output']['text']

        print(f"Resposta IA: {resposta_ia}")

        # ==========================================
        # 🧠 ATUALIZA RESUMO
        # ==========================================
        novo_historico = f"Usuário: {mensagem_cliente}\nAssistente: {resposta_ia}"

        novo_summary = atualizar_summary(summary, novo_historico)

        # ==========================================
        # 💾 SALVAR
        # ==========================================
        table.put_item(
            Item={
                'UserId': str(telefone_cliente),
                'Timestamp': datetime.utcnow().isoformat(),
                'UserMessage': mensagem_cliente,
                'AssistantResponse': resposta_ia,
                'Summary': novo_summary
            }
        )

        enviar_mensagem_whatsapp(telefone_cliente, resposta_ia)

        return {'statusCode': 200, 'body': 'OK'}

    except Exception as e:
        print(f"ERRO: {str(e)}")

        enviar_mensagem_whatsapp(
            event.get('telefone', ''),
            "Erro temporário, tente novamente em instantes."
        )

        return {'statusCode': 500, 'body': str(e)}