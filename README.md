# Projeto DevOps - Flask com ELK Stack

Este projeto demonstra uma aplicação Flask integrada com ELK Stack (Elasticsearch, Logstash, Kibana) para monitoramento e análise de logs.

## 🏗️ Arquitetura

- **Flask App**: Aplicação web com logging estruturado em JSON
- **Elasticsearch**: Armazena e indexa os logs
- **Kibana**: Interface web para visualização e análise dos logs
- **Filebeat**: Coleta logs dos containers Docker e envia para Elasticsearch

## 📋 Pré-requisitos

- Docker Desktop instalado e rodando
- Docker Compose
- Porta 5001, 5601 e 9200 disponíveis

## 🚀 Como Usar

### 1. Iniciar o Stack Completo

```powershell
docker-compose up -d
```

Este comando irá:
- Construir a imagem da aplicação Flask
- Iniciar Elasticsearch
- Iniciar Kibana
- Iniciar Filebeat para coletar logs
- Iniciar a aplicação Flask

### 2. Verificar se os Containers Estão Rodando

```powershell
docker ps
```

Você deve ver 4 containers rodando:
- `app-para-logs` (Flask App)
- `elasticsearch`
- `kibana`
- `filebeat`

### 3. Verificar os Logs dos Containers

```powershell
# Logs da aplicação Flask
docker logs app-para-logs

# Logs do Filebeat
docker logs filebeat

# Logs do Elasticsearch
docker logs elasticsearch
```

### 4. Testar a Aplicação

```powershell
# Endpoint principal
Invoke-WebRequest -Uri http://localhost:5001/ | Select-Object -Expand Content

# Health check
Invoke-WebRequest -Uri http://localhost:5001/health | Select-Object -Expand Content

# Testar diferentes status codes
Invoke-WebRequest -Uri http://localhost:5001/status/200
Invoke-WebRequest -Uri http://localhost:5001/status/404 -SkipHttpErrorCheck
Invoke-WebRequest -Uri http://localhost:5001/status/500 -SkipHttpErrorCheck
```

### 5. Acessar o Kibana

1. Abra o navegador em: http://localhost:5601
2. Aguarde o Kibana inicializar (pode levar 1-2 minutos)
3. Vá em **Management** > **Stack Management** > **Index Patterns**
4. Clique em **Create index pattern**
5. Digite: `flask-logs-*`
6. Clique em **Next step**
7. Selecione `@timestamp` como Time field
8. Clique em **Create index pattern**

### 6. Visualizar os Logs

1. No menu lateral, clique em **Discover**
2. Selecione o index pattern `flask-logs-*`
3. Você verá todos os logs da aplicação Flask
4. Use os filtros para buscar logs específicos:
   - Por nível: `level: "INFO"` ou `level: "ERROR"`
   - Por endpoint: `endpoint: "/health"`
   - Por status code: `status_code: 404`

## 📊 Endpoints Disponíveis

| Endpoint | Método | Descrição |
|----------|--------|-----------|
| `/` | GET | Mensagem de boas-vindas |
| `/health` | GET | Health check da aplicação |
| `/status/<code>` | GET | Retorna o status code especificado |

## 🧪 Executar Testes

```powershell
# Instalar dependências de teste
pip install -r requirements.txt

# Executar testes
pytest test_app.py -v
```

## 🛠️ Troubleshooting

### Filebeat não está coletando logs

1. Verifique se o Filebeat está rodando:
   ```powershell
   docker logs filebeat
   ```

2. Verifique se o Docker socket está montado corretamente:
   ```powershell
   docker exec filebeat ls -la /var/run/docker.sock
   ```

3. Reinicie o Filebeat:
   ```powershell
   docker-compose restart filebeat
   ```

### Elasticsearch não está respondendo

1. Verifique os logs:
   ```powershell
   docker logs elasticsearch
   ```

2. Verifique se tem memória suficiente (mínimo 2GB recomendado)

3. Reinicie o container:
   ```powershell
   docker-compose restart elasticsearch
   ```

### Kibana não está acessível

1. Aguarde 1-2 minutos após iniciar (Kibana demora para inicializar)

2. Verifique os logs:
   ```powershell
   docker logs kibana
   ```

3. Verifique se o Elasticsearch está rodando

## 🧹 Limpeza

Para parar e remover todos os containers:

```powershell
docker-compose down
```

Para remover também os volumes (dados do Elasticsearch):

```powershell
docker-compose down -v
```

## 📝 Estrutura do Projeto

```
projeto-devops/
├── app.py                  # Aplicação Flask com logging JSON
├── Dockerfile              # Imagem Docker da aplicação
├── docker-compose.yml      # Orquestração dos serviços
├── requirements.txt        # Dependências Python
├── test_app.py            # Testes unitários
├── logging/
│   └── filebeat.yml       # Configuração do Filebeat
└── helm/                  # Charts Helm para Kubernetes
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
        ├── deployment.yaml
        ├── service.yaml
        └── _helpers.tpl
```

## 🎯 Características do Logging

- **Logs estruturados em JSON** para melhor análise
- **Campos customizados**:
  - `timestamp`: Data e hora do log
  - `level`: Nível do log (INFO, WARNING, ERROR)
  - `endpoint`: Endpoint acessado
  - `status_code`: Código HTTP retornado
  - `method`: Método HTTP usado
  - `ip`: IP do cliente
  - `message`: Mensagem do log

## 📚 Referências

- [Flask Documentation](https://flask.palletsprojects.com/)
- [Elasticsearch Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Filebeat Documentation](https://www.elastic.co/guide/en/beats/filebeat/current/index.html)
- [Kibana Documentation](https://www.elastic.co/guide/en/kibana/current/index.html)
