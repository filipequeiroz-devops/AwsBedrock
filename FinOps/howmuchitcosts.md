# 📊 Estimativa de Custos da Arquitetura (AWS)

Esta documentação detalha a estimativa de custos para a infraestrutura Serverless com RAG (Retrieval-Augmented Generation) utilizando Amazon Bedrock e Aurora PostgreSQL Serverless v2.

> **Nota de Arquitetura (FinOps):** Este projeto utiliza um padrão de invocação de Lambdas (Pública acionando Privada) através de um **VPC Endpoint**, eliminando a necessidade de um NAT Gateway e reduzindo drasticamente os custos mensais de rede.
> *Cotação estimada utilizada: US$ 1,00 = R$ 5,00.*

### 1. Custos Mensais Fixos (Base da Arquitetura)
Estes são os recursos provisionados na VPC e que geram cobrança baseada no tempo de execução (hora/mês), independentemente do volume de tráfego.

<table width="100%">
  <thead>
    <tr>
      <th align="left">Recurso AWS</th>
      <th align="left">Função na Arquitetura</th>
      <th align="center">Custo Mensal (USD)</th>
      <th align="center">Custo Mensal (BRL)</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Amazon Aurora Serverless v2</strong></td>
      <td>O "Cérebro" Vetorial (PostgreSQL). Cobrado pelo mínimo de 0.5 ACU (Capacity Units) ligado 24/7.</td>
      <td align="center">~$43.80</td>
      <td align="center">~R$ 219,00</td>
    </tr>
    <tr>
      <td><strong>Armazenamento Aurora</strong></td>
      <td>Espaço em disco do banco de dados (Estimando 1GB de dados, suficiente para milhões de tokens).</td>
      <td align="center">$0.10</td>
      <td align="center">R$ 0,50</td>
    </tr>
    <tr>
      <td><strong>VPC Endpoint (Interface)</strong></td>
      <td>Permite que a Lambda Pública acione a Lambda Privada na sub-rede isolada com segurança.</td>
      <td align="center">~$7.30</td>
      <td align="center">~R$ 36,50</td>
    </tr>
    <tr>
      <td><strong>Amazon S3</strong></td>
      <td>Armazena a base de conhecimento (.txt) para ingestão do Bedrock.</td>
      <td align="center">~$0.01</td>
      <td align="center">~R$ 0,05</td>
    </tr>
    <tr>
      <td colspan="2" align="right"><strong>Total Base Estimado:</strong></td>
      <td align="center"><strong>~$51.21</strong></td>
      <td align="center"><strong>~R$ 256,05</strong></td>
    </tr>
  </tbody>
</table>

<br>

### 2. Custos Variáveis (Pagamento por Uso)
Serviços 100% sob demanda (*Pay-as-you-go*), onde a cobrança ocorre em frações de centavo baseadas estritamente nas requisições e no processamento de tokens da IA.

<table width="100%">
  <thead>
    <tr>
      <th align="left">Recurso AWS</th>
      <th align="left">Regra de Cobrança (USD)</th>
      <th align="left">Estimativa Prática (O que significa no projeto)</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Claude 3.5 Haiku (Input)</strong></td>
      <td>$0.0008 por 1.000 tokens</td>
      <td>A IA lendo a pergunta do cliente + o conteúdo do banco RAG. Custa <strong>menos de 1 décimo de centavo</strong> por requisição.</td>
    </tr>
    <tr>
      <td><strong>Claude 3.5 Haiku (Output)</strong></td>
      <td>$0.004 por 1.000 tokens</td>
      <td>A IA escrevendo a resposta final para o usuário. Custa cerca de <strong>meio centavo de dólar</strong> por resposta gerada.</td>
    </tr>
    <tr>
      <td><strong>Titan Embeddings G1</strong></td>
      <td>$0.00002 por 1.000 tokens</td>
      <td>Acionado ao sincronizar o arquivo do S3 com o Aurora. Custo virtualmente irrelevante (frações microscópicas de centavo).</td>
    </tr>
    <tr>
      <td><strong>AWS Lambda</strong></td>
      <td>$0.20 por 1 Milhão de invocações</td>
      <td>Execução do código Python (Boto3). Entra na <strong>Camada Gratuita</strong> da AWS para a grande maioria dos casos de uso de PMEs.</td>
    </tr>
    <tr>
      <td><strong>API Gateway</strong></td>
      <td>$1.00 por 1 Milhão de requisições</td>
      <td>Porta de entrada (Webhook) das mensagens do WhatsApp. Para tráfego de um negócio local, o custo beira <strong>~$0.01/mês</strong>.</td>
    </tr>
  </tbody>
</table>

> 💡 **Conclusão:** Para uma operação local (ex: Barbearia) com cerca de 2.000 atendimentos via chat no mês, o custo total da arquitetura em produção se concentra quase integralmente na base de dados (Aurora), mantendo o custo de inteligência artificial na casa de **menos de US$ 2.00 mensais**.