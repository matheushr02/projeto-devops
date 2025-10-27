# Guia Completo de Logging e Monitoramento

## 📊 Visão Geral da Arquitetura de Logging

```
┌─────────────┐
│  Flask App  │ → Gera logs em JSON → STDOUT
└─────────────┘
       ↓
┌─────────────┐
│   Docker    │ → Armazena logs em arquivos JSON
└─────────────┘
       ↓
┌─────────────┐
│  Filebeat   │ → Coleta e envia logs
└─────────────┘
       ↓
┌─────────────┐
│Elasticsearch│ → Indexa e armazena logs
└─────────────┘
       ↓
┌─────────────┐
│   Kibana    │ → Visualiza e analisa logs
└─────────────┘
```

## 🔍 Estrutura dos Logs

Cada log gerado pela aplicação contém os seguintes campos:

```json
{
  "timestamp": "2025-10-26T10:30:45.123456Z",
  "level": "INFO",
  "logger": "flask_app",
  "message": "Request received: GET /health",
  "module": "app",
  "function": "log_request",
  "line": 42,
  "endpoint": "/health",
  "method": "GET",
  "ip": "172.18.0.1",
  "status_code": 200
}
```

### Campos Principais

| Campo | Descrição | Exemplo |
|-------|-----------|---------|
| `timestamp` | Data/hora do evento em UTC | `2025-10-26T10:30:45.123456Z` |
| `level` | Nível do log | `INFO`, `WARNING`, `ERROR` |
| `logger` | Nome do logger | `flask_app` |
| `message` | Mensagem descritiva | `Request received: GET /health` |
| `endpoint` | URL acessada | `/health`, `/status/404` |
| `method` | Método HTTP | `GET`, `POST`, `PUT`, `DELETE` |
| `ip` | IP do cliente | `172.18.0.1` |
| `status_code` | Código HTTP de resposta | `200`, `404`, `500` |
| `module` | Módulo Python | `app` |
| `function` | Função que gerou o log | `health_check`, `home` |
| `line` | Linha do código | `42` |

## 📈 Níveis de Log

| Nível | Uso | Quando Ocorre |
|-------|-----|---------------|
| `INFO` | Eventos normais | Requisições bem-sucedidas, health checks |
| `WARNING` | Situações inesperadas | Status codes 4xx, recursos não encontrados |
| `ERROR` | Erros que precisam atenção | Status codes 5xx, falhas internas |

## 🎯 Configurando o Kibana

### Passo 1: Criar Index Pattern

1. Acesse http://localhost:5601
2. Clique no menu ☰ (hamburger) no canto superior esquerdo
3. Vá em **Management** → **Stack Management**
4. Em **Kibana**, clique em **Index Patterns**
5. Clique em **Create index pattern**
6. Digite: `flask-logs-*`
7. Clique em **Next step**
8. Selecione `@timestamp` como Time field
9. Clique em **Create index pattern**

### Passo 2: Explorar Logs no Discover

1. No menu lateral, clique em **Discover**
2. Selecione o index pattern `flask-logs-*`
3. Ajuste o período de tempo no canto superior direito (ex: Last 15 minutes)
4. Você verá todos os logs da aplicação

### Passo 3: Adicionar Campos Úteis

Clique no botão **+** ao lado dos campos que deseja visualizar:
- `level`
- `message`
- `endpoint`
- `status_code`
- `method`
- `ip`

## 🔎 Queries Úteis no Kibana

### Buscar por Nível de Log

```
level: "INFO"
level: "WARNING"
level: "ERROR"
```

### Buscar por Endpoint

```
endpoint: "/health"
endpoint: "/status/*"
```

### Buscar por Status Code

```
status_code: 200
status_code: 404
status_code: 500
status_code >= 400
```

### Buscar por Método HTTP

```
method: "GET"
method: "POST"
```

### Queries Combinadas (AND)

```
level: "ERROR" AND endpoint: "/status/*"
status_code >= 400 AND method: "GET"
```

### Queries Combinadas (OR)

```
level: "ERROR" OR level: "WARNING"
status_code: 404 OR status_code: 500
```

### Buscar por Mensagem

```
message: "Health check"
message: *error*
```

### Buscar por IP

```
ip: "172.18.0.1"
```

## 📊 Criando Visualizações

### 1. Gráfico de Pizza - Distribuição por Status Code

1. Vá em **Visualize** → **Create visualization**
2. Escolha **Pie**
3. Selecione o index pattern `flask-logs-*`
4. Em **Buckets**, clique em **Add** → **Split slices**
5. Aggregation: **Terms**
6. Field: **status_code**
7. Clique em **▶ Update**
8. Salve como "Status Code Distribution"

### 2. Gráfico de Barras - Requisições por Endpoint

1. **Visualize** → **Create visualization** → **Vertical bar**
2. Y-axis: Count
3. X-axis Buckets: **Terms** → **endpoint**
4. Salve como "Requests by Endpoint"

### 3. Métrica - Total de Erros

1. **Visualize** → **Create visualization** → **Metric**
2. Adicione filtro: `level: "ERROR"`
3. Salve como "Total Errors"

### 4. Line Chart - Requisições ao Longo do Tempo

1. **Visualize** → **Create visualization** → **Line**
2. Y-axis: Count
3. X-axis: **Date Histogram** → **@timestamp**
4. Interval: Auto
5. Salve como "Requests Over Time"

## 📋 Criando um Dashboard

1. Vá em **Dashboard** → **Create dashboard**
2. Clique em **Add** → **Add from library**
3. Adicione as visualizações criadas:
   - Status Code Distribution
   - Requests by Endpoint
   - Total Errors
   - Requests Over Time
4. Organize os painéis arrastando e redimensionando
5. Salve como "Flask App Monitoring"

## 🚨 Alertas e Monitoramento

### Configurar Alerta de Erro

1. Vá em **Stack Management** → **Rules and Connectors**
2. Clique em **Create rule**
3. Selecione **Elasticsearch query**
4. Configure:
   - Index: `flask-logs-*`
   - Query: `level: "ERROR"`
   - Threshold: `count > 5` (mais de 5 erros em 5 minutos)
5. Configure ação (ex: enviar email, webhook, etc.)

## 🔧 Troubleshooting

### Não vejo logs no Kibana

1. **Verificar se o Filebeat está coletando logs:**
   ```powershell
   docker logs filebeat
   ```
   Procure por mensagens como "Non-zero metrics" ou "events published"

2. **Verificar se há logs no Elasticsearch:**
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:9200/flask-logs-*/_search?size=1" | Select-Object -Expand Content
   ```

3. **Verificar se a aplicação está gerando logs:**
   ```powershell
   docker logs app-para-logs
   ```

4. **Ajustar o período de tempo no Kibana:**
   - Clique no relógio no canto superior direito
   - Selecione "Last 1 hour" ou "Today"

### Logs estão truncados

- O Filebeat tem um limite de tamanho de linha
- Logs muito grandes podem ser truncados
- Considere dividir logs complexos em múltiplas entradas

### Elasticsearch está sem espaço

```powershell
# Ver uso de disco
docker exec elasticsearch df -h

# Limpar índices antigos (mais de 7 dias)
Invoke-WebRequest -Method DELETE -Uri "http://localhost:9200/flask-logs-2025.10.19"
```

### Performance lenta no Kibana

1. **Reduzir período de busca** (últimas horas ao invés de dias)
2. **Usar filtros específicos** ao invés de buscar tudo
3. **Limitar número de documentos retornados**
4. **Aumentar memória do Elasticsearch** no docker-compose.yml:
   ```yaml
   ES_JAVA_OPTS: "-Xms1g -Xmx1g"
   ```

## 📚 Referências e Recursos

- [KQL (Kibana Query Language) Guide](https://www.elastic.co/guide/en/kibana/current/kuery-query.html)
- [Elasticsearch Query DSL](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html)
- [Filebeat Configuration](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-reference-yml.html)
- [Python Logging Best Practices](https://docs.python.org/3/howto/logging.html)

## 💡 Dicas Avançadas

### 1. Adicionar mais campos customizados

Edite `app.py` e adicione campos no `extra={}`:

```python
logger.info(
    "Usuário fez login",
    extra={
        'endpoint': '/login',
        'user_id': user.id,
        'username': user.name
    }
)
```

### 2. Correlação de Requisições

Adicione um request_id para rastrear requisições:

```python
import uuid

@app.before_request
def add_request_id():
    request.request_id = str(uuid.uuid4())
```

### 3. Métricas de Performance

Adicione tempo de resposta nos logs:

```python
@app.after_request
def log_response(response):
    duration = time.time() - g.start_time
    logger.info(
        f"Response sent",
        extra={
            'duration_ms': duration * 1000,
            'status_code': response.status_code
        }
    )
    return response
```

### 4. Exportar Dados do Kibana

Para criar relatórios:
1. Em **Discover**, configure seus filtros
2. Clique em **Share** → **CSV Reports**
3. Gere e baixe o relatório
