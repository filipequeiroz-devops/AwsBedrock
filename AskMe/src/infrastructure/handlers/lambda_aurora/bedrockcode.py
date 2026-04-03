import json
import os
import boto3
import urllib.request
from datetime import datetime, timedelta

#Clients
bedrock_agent     = boto3.client('bedrock-agent-runtime', region_name='us-east-1')
dynamodb          = boto3.resource('dynamodb', region_name='us-east-1')

#Env vars
WHATSAPP_TOKEN              = os.environ.get('WHATSAPP_TOKEN')
PHONE_NUMBER_ID             = os.environ.get('PHONE_NUMBER_ID')
SYSTEM_PROMPT               = os.environ.get('SYSTEM_PROMPT')
KNOWLEDGE_BASE_ID           = os.environ.get('KNOWLEDGE_BASE_ID')
MODEL_ARN                   = os.environ.get('MODEL_ARN')
DYNAMODB_TABLE              = os.environ.get('DYNAMODB_TABLE')
DYNAMODB_APPOINTMENTS_TABLE = os.environ.get('DYNAMODB_APPOINTMENTS_TABLE')
COMPANYS_PHONE              = os.environ.get('COMPANYS_PHONE')
COMPANYS_PHONE2             = os.environ.get('COMPANYS_PHONE2')


#admins
ADMINS = [COMPANYS_PHONE, COMPANYS_PHONE2]

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
            print(f"Sucesso Mensagem whatsapp enviada! Status: {response.getcode()}")
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
        telefone_remetente = str(event.get('telefone'))
        # Retirei o .lower() daqui para não mandar a mensagem toda em minúsculo pro Bedrock (pode atrapalhar o LLM)
        mensagem_recebida = event.get('mensagem', '').strip() 

        if not telefone_remetente or not mensagem_recebida:
            return {'statusCode': 400, 'body': 'Faltam dados'}

        # ==========================================================
        # 🛡️ VALIDAÇÃO DE IDENTIDADE: É UM DOS DONOS DA EMPRESA?
        # ==========================================================
        if telefone_remetente in ADMINS:
            # Descobre quem é o dono que está falando
            nome_admin_ativo = "RICARDO" if telefone_remetente == COMPANYS_PHONE else "VITOR"
            print(f"💼 Mensagem recebida do ADMIN {nome_admin_ativo}: {mensagem_recebida}")
            
            if "sim" in mensagem_recebida.lower() or "ok" in mensagem_recebida.lower():
                table_app = dynamodb.Table(DYNAMODB_APPOINTMENTS_TABLE)

                # Busca PENDENTES apenas para O BARBEIRO QUE RESPONDEU
                # Como a SK começa com o nome dele (Ex: RICARDO#14:30), podemos usar o Contains
                scan_response = table_app.scan(
                    FilterExpression=boto3.dynamodb.conditions.Attr('Status').eq('PENDENTE') &
                                     boto3.dynamodb.conditions.Attr('BarbeiroId#HorarioInicio').begins_with(nome_admin_ativo)
                )
                items = scan_response.get('Items', [])

                if items:
                    # Pega o mais recente
                    items.sort(key=lambda x: x['TimestampOriginal'], reverse=True)
                    agendamento = items[0]
                    cliente_id = agendamento['UserId']

                    # Atualiza usando a PK e SK exatas da nova tabela
                    table_app.update_item(
                        Key={
                            'ServiceData': agendamento['ServiceData'],
                            'BarbeiroId#HorarioInicio': agendamento['BarbeiroId#HorarioInicio']
                        },
                        UpdateExpression="set #st = :s",
                        ExpressionAttributeNames={'#st': 'Status'},
                        ExpressionAttributeValues={':s': 'CONFIRMADO'}
                    )

                    print("enviado mensagem de confirmação para o cliente e para o admin")
                    enviar_mensagem_whatsapp(telefone_remetente, f"✅ Confirmado! O cliente {cliente_id} foi avisado.")

                    print("enviado mensagem de confirmação para o cliente")
                    enviar_mensagem_whatsapp(cliente_id, f"Olá! Passando para avisar que o {nome_admin_ativo.capitalize()} confirmou seu agendamento. Até logo!")
                else:
                    print("Nenhum agendamento pendente encontrado para esse admin. Avisando o admin.")
                    enviar_mensagem_whatsapp(telefone_remetente, "Não encontrei agendamentos pendentes para você.")

                return {'statusCode': 200, 'body': 'Admin processado'}

            # Proteção contra conversa paralela do Admin
            enviar_mensagem_whatsapp(telefone_remetente, f"⚙️ Modo Admin {nome_admin_ativo} Ativo. Aguardando comando 'OK'.")
            return {'statusCode': 200, 'body': 'Admin ignorado'}
        

        # ==========================================================
        # 👤 FLUXO DO CLIENTE
        # ==========================================================
        table = dynamodb.Table(DYNAMODB_TABLE)
        print(f"Mensagem recebida do CLIENTE {telefone_remetente}: {mensagem_recebida}")

        # Memory
        historico = buscar_historico(table, telefone_remetente)
        summary = buscar_summary(table, telefone_remetente)

        # Hour context 
        now               = datetime.utcnow() - timedelta(hours=3)
        current_date_time = now.strftime('%Y-%m-%d %H:%M')
        weekday           = now.strftime('%A') # Ex: Thursday

        #============
        #SYSTEM PROMP
        #============
        prompt_final = f"""

<INFORMAÇÃO DE SISTEMA OBRIGATÓRIA>
Atenção IA: Hoje é {weekday}, dia {current_date_time} (Horário de Brasília).
Use esta data como base para entender quando o cliente disser "hoje", "amanhã", "dia 16", "próxima terça", etc.
</INFORMAÇÃO DE SISTEMA OBRIGATÓRIA>

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
            input={'text': mensagem_recebida},
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

        # Updates de conversations resume
        novo_historico = f"Usuário: {mensagem_recebida}\nAssistente: {resposta_ia}"
        novo_summary = atualizar_summary(summary, novo_historico)

        # Saves conversations History
        table.put_item(
            Item={
                'UserId'            : telefone_remetente,
                'Timestamp'         : datetime.utcnow().isoformat(),
                'UserMessage'       : mensagem_recebida,
                'AssistantResponse' : resposta_ia,
                'Summary'           : novo_summary
            }
        )

        # ==========================================================
        # 🔔 LÓGICA DE PRÉ-AGENDAMENTO E CONFLITOS
        # ==========================================================
        if "perfeito, solicitação enviada" in resposta_ia.lower():
            print("Detectada intenção de agendamento. Extraindo dados...")

            #Extracta data form the response using the tags we defined in the prompt
            try:
                data_pedido        = resposta_ia.split("[DATA:")[1].split("]")[0].strip()
                hora_pedido        = resposta_ia.split("[HORARIO:")[1].split("]")[0].strip()
                duracao_minutos    = int(resposta_ia.split("[DURACAO:")[1].split("]")[0].strip())
                barbeiro_escolhido = resposta_ia.split("[BARBEIRO:")[1].split("]")[0].strip().upper()
                
                formato_hora = "%H:%M"
                incio_atendimento = datetime.strptime(hora_pedido, formato_hora)
                fim_atendimento   = incio_atendimento + timedelta(minutes=duracao_minutos)
                horario_fim_str   = fim_atendimento.strftime(formato_hora)
                
                #Names to be used in the notification
                telefone_destino_admin = COMPANYS_PHONE if barbeiro_escolhido == "RICARDO" else COMPANYS_PHONE2
                nome_formatado         = "Ricardo" if barbeiro_escolhido == "RICARDO" else "Vitor"
                
                # Dynamo Keys
                pk_service_data     = data_pedido
                sk_barbeiro_horario = f"{barbeiro_escolhido}#{hora_pedido}"

                table_app           = dynamodb.Table(DYNAMODB_APPOINTMENTS_TABLE)
                
                # 🛑 VERIFICAÇÃO DE CONFLITO (A TRAVA DE AGENDA)
                response_conflito = table_app.query(
                    KeyConditionExpression=boto3.dynamodb.conditions.Key('ServiceData').eq(pk_service_data) &
                                           boto3.dynamodb.conditions.Key('BarbeiroId#HorarioInicio').begins_with(barbeiro_escolhido),
                    FilterExpression=boto3.dynamodb.conditions.Attr('Status').eq('CONFIRMADO')
                )

                conflito = False

                for item in response_conflito.get('Items', []):
                    ocupado_inicio = item['BarbeiroId#HorarioInicio'].split('#')[1] 
                    ocupado_fim    = item['HorarioFim']
                    if ocupado_inicio < horario_fim_str and ocupado_fim > hora_pedido:
                        conflito = True
                        break

                # Se bateu o horário, a gente aborta!
                if conflito:
                    print(f"Conflito detectado para {nome_formatado} às {hora_pedido}. Abortando.")
                    msg_erro_conflito = f"Poxa, fui verificar a agenda agora e o {nome_formatado} já tem um compromisso que bate com esse horário. 😕 Pode ser um pouquinho mais cedo ou mais tarde?"
                    enviar_mensagem_whatsapp(telefone_remetente, msg_erro_conflito)
                    return {'statusCode': 200, 'body': 'Conflito de horario tratado'}

                # ✅ TUDO LIVRE! SALVANDO AGENDAMENTO PENDENTE...
                table_app.put_item(
                    Item={
                        'ServiceData': pk_service_data,               
                        'BarbeiroId#HorarioInicio': sk_barbeiro_horario, 
                        'UserId': telefone_remetente,                 
                        'Status': 'PENDENTE',
                        'Descricao': mensagem_recebida,
                        'HorarioFim': horario_fim_str,
                        'TimestampOriginal': datetime.utcnow().isoformat()
                    }
                )
                
                # ROTEAMENTO: Manda pro Admin aprovar
                msg_admin = (f"🔔 *Novo Agendamento Pendente para {nome_formatado}*\n"
                             f"Cliente: {telefone_remetente}\n"
                             f"Data: {data_pedido}\n"
                             f"Horário: {hora_pedido} às {horario_fim_str}\n"
                             f"Responda 'OK' para confirmar.")

                print("enviado mensagem de novo agendamento para o admin")             
                enviar_mensagem_whatsapp(telefone_destino_admin, msg_admin)
                
                # Manda a resposta original limpa (sem as tags de sistema) para o cliente
                resposta_limpa = resposta_ia.split("[DATA:")[0].strip()
                
                print("enviado mensagem com o resumo do agendamento para o cliente")    
                enviar_mensagem_whatsapp(telefone_remetente, resposta_limpa)
                return {'statusCode': 200, 'body': 'OK'}

            except Exception as e:
                print(f"Erro ao fazer o parse das tags da IA ou salvar no Dynamo: {e}")
                enviar_mensagem_whatsapp(telefone_remetente, "Desculpe, houve um erro ao processar os horários. Pode repetir as informações, por favor?")
                print(f"")
                return {'statusCode': 200, 'body': 'Erro tratado no parse'}

        # Se NÃO for um agendamento (conversa normal), apenas envia a resposta
        print("Fluxo de conversa normal")
        enviar_mensagem_whatsapp(telefone_remetente, resposta_ia)
        return {'statusCode': 200, 'body': 'OK'}

    except Exception as e:
        print(f"ERRO: {str(e)}")
        enviar_mensagem_whatsapp(event.get('telefone', ''), "Erro temporário, tente novamente em instantes.")
        return {'statusCode': 500, 'body': str(e)}