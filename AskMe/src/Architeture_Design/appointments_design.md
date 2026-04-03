# AI Barber Agent (HITL)

This is scheduling architeture, which a human gets in the middle to make the final decision
---

##  Visão Geral do Sistema

O sistema utiliza uma abordagem **Serverless** na AWS para garantir escalabilidade e baixo custo, integrando Processamento de Linguagem Natural (NLP) com persistência de estado.

###  MEssages flow (decision routes)

The first lambda Identify from who the message is comming from

#### Customer's route
1. **Entry:** The chustomer request's an scheduling.
2. **Context:** The lambds seacches the `Summary` and read the last 15 messages from **DynamoDB**.
3. **Brain (Bedrock):** Process the RAG
4. **Intercept:** IF the IA identify's an scheduling intent
   - Save the registry in the `appointments` table with the status `status: "PENDENTE"` (pendding).
   - Sends a notification the the company **personal WhatsApp**.
5. **Saída:** The customer receives: *"Vou verificar com o barbeiro e já te confirmo!"*. (I'll check the the companys's owner and i'll get back to you)

#### Owner's route
1. **Entrada:** Owner answers with  "OK" or "Sim" (yes) à notificação.
2. **Identificação:** Lambda recognizes the owners number.
3. **Atualização:** searchs for the most recent `PENDENTE` (pendding) pendding appoint from the customer.
4. **Confirmação:** Alters it to `CONFIRMADO` (confirmed).
5. **Saída:** Sends a message to the customer: *"Tudo certo! Seu horário está confirmado!"*  (your scheduling has been confirmed) .

---

# ------------------------------------- portuguese -------------------#