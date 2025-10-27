# ✅ Checklist de Verificação do Projeto

Use este checklist para garantir que tudo está funcionando corretamente.

---

## 📋 Pré-requisitos

- [ ] **Docker Desktop** instalado e rodando
- [ ] **PowerShell** disponível (Windows)
- [ ] **Portas disponíveis:**
  - [ ] 5001 (Flask App)
  - [ ] 9200 (Elasticsearch)
  - [ ] 5601 (Kibana)

### Verificar Portas
```powershell
# Execute este comando para verificar se as portas estão livres
@(5001, 9200, 5601) | ForEach-Object {
    $port = $_
    $inUse = (Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue) -ne $null
    if ($inUse) {
        Write-Host "❌ Porta $port em uso" -ForegroundColor Red
    } else {
        Write-Host "✅ Porta $port disponível" -ForegroundColor Green
    }
}
```

---

## 🚀 Fase 1: Inicialização

- [ ] **Navegou até a pasta do projeto**
  ```powershell
  cd "c:\Users\mathe\Downloads\trabalho rodrigo\projeto-devops"
  ```

- [ ] **Executou o script de setup**
  ```powershell
  .\setup.ps1
  ```

- [ ] **Aguardou os serviços iniciarem** (pode levar 2-3 minutos)

- [ ] **Verificou que 4 containers estão rodando**
  ```powershell
  docker ps
  # Deve mostrar: app-para-logs, elasticsearch, kibana, filebeat
  ```

---

## 🔍 Fase 2: Verificação dos Serviços

### Flask App
- [ ] **Container está rodando**
  ```powershell
  docker ps | findstr app-para-logs
  ```

- [ ] **Endpoint principal responde**
  ```powershell
  Invoke-WebRequest -Uri http://localhost:5001/
  # Deve retornar status 200
  ```

- [ ] **Health check funciona**
  ```powershell
  Invoke-WebRequest -Uri http://localhost:5001/health
  # Deve retornar: {"status": "UP"}
  ```

- [ ] **Logs estão em formato JSON**
  ```powershell
  docker logs app-para-logs --tail 5
  # Deve mostrar logs JSON com campos: timestamp, level, message, etc.
  ```

### Elasticsearch
- [ ] **Container está rodando**
  ```powershell
  docker ps | findstr elasticsearch
  ```

- [ ] **Serviço responde**
  ```powershell
  Invoke-WebRequest -Uri http://localhost:9200
  # Deve retornar informações do cluster
  ```

- [ ] **Cluster está saudável**
  ```powershell
  Invoke-WebRequest -Uri http://localhost:9200/_cluster/health | Select-Object -Expand Content
  # "status" deve ser "yellow" ou "green"
  ```

- [ ] **Índices foram criados**
  ```powershell
  Invoke-WebRequest -Uri http://localhost:9200/_cat/indices?v
  # Deve mostrar índice "flask-logs-YYYY.MM.DD"
  ```

### Filebeat
- [ ] **Container está rodando**
  ```powershell
  docker ps | findstr filebeat
  ```

- [ ] **Está coletando logs**
  ```powershell
  docker logs filebeat 2>&1 | Select-String "publish"
  # Deve mostrar linhas com "Non-zero metrics" ou eventos publicados
  ```

- [ ] **Sem erros críticos**
  ```powershell
  docker logs filebeat 2>&1 | Select-String "ERROR" | Select-Object -Last 10
  # Não deve ter muitos erros
  ```

### Kibana
- [ ] **Container está rodando**
  ```powershell
  docker ps | findstr kibana
  ```

- [ ] **Interface web acessível**
  ```powershell
  Start-Process "http://localhost:5601"
  # Deve abrir o Kibana no navegador
  ```

- [ ] **API responde**
  ```powershell
  Invoke-WebRequest -Uri http://localhost:5601/api/status
  # Deve retornar status 200
  ```

---

## 🧪 Fase 3: Testes Funcionais

- [ ] **Executou script de testes**
  ```powershell
  .\setup.ps1 -Test
  # ou
  .\test_logging.ps1
  ```

- [ ] **Todos os endpoints responderam:**
  - [ ] GET / (Status 200)
  - [ ] GET /health (Status 200)
  - [ ] GET /status/200 (Status 200)
  - [ ] GET /status/404 (Status 404)
  - [ ] GET /status/500 (Status 500)
  - [ ] GET /naoexiste (Status 404)
  - [ ] GET /status/999 (Status 400)

- [ ] **Logs foram gerados**
  ```powershell
  docker logs app-para-logs --tail 20
  # Deve mostrar logs das requisições feitas
  ```

- [ ] **Documentos chegaram no Elasticsearch**
  ```powershell
  Invoke-WebRequest -Uri http://localhost:9200/flask-logs-*/_count | Select-Object -Expand Content
  # count deve ser > 0
  ```

---

## 📊 Fase 4: Configuração do Kibana

- [ ] **Acessou o Kibana** (http://localhost:5601)

- [ ] **Navegou para Stack Management**
  - Menu ☰ → Management → Stack Management

- [ ] **Criou Index Pattern**
  - Kibana → Index Patterns → Create index pattern
  - Nome: `flask-logs-*`
  - Time field: `@timestamp`

- [ ] **Visualizou logs no Discover**
  - Menu ☰ → Analytics → Discover
  - Selecionou index pattern: `flask-logs-*`
  - Ajustou período de tempo (últimas 24 horas)

- [ ] **Vê logs da aplicação**
  - Deve mostrar logs JSON com todos os campos

- [ ] **Filtros funcionam:**
  - [ ] Filtro por level: `level: "INFO"`
  - [ ] Filtro por endpoint: `endpoint: "/health"`
  - [ ] Filtro por status: `status_code: 200`

---

## 🎨 Fase 5: Visualizações (Opcional)

- [ ] **Criou visualização: Status Codes**
  - Tipo: Pie Chart
  - Campo: status_code

- [ ] **Criou visualização: Requests por Endpoint**
  - Tipo: Bar Chart
  - Campo: endpoint

- [ ] **Criou visualização: Logs ao longo do tempo**
  - Tipo: Line Chart
  - Eixo X: @timestamp

- [ ] **Criou Dashboard**
  - Agrupou todas as visualizações
  - Salvou como "Flask App Monitoring"

---

## 🎯 Fase 6: Casos de Uso

### Cenário 1: Encontrar Erros
- [ ] **Filtrou por erros no Kibana**
  ```
  level: "ERROR"
  ```
- [ ] **Identificou endpoint com problema**
- [ ] **Viu detalhes do erro (mensagem, stack trace, etc.)**

### Cenário 2: Monitorar Health
- [ ] **Criou query para health checks**
  ```
  endpoint: "/health" AND level: "INFO"
  ```
- [ ] **Verificou frequência de requisições**
- [ ] **Confirmou que serviço está responsivo**

### Cenário 3: Análise de Performance
- [ ] **Filtrou requisições lentas** (se implementado)
- [ ] **Identificou endpoints mais acessados**
- [ ] **Analisou distribuição de status codes**

---

## 🔧 Troubleshooting

### Se algo não funcionar, verifique:

#### Containers não iniciam
- [ ] Docker Desktop está rodando?
- [ ] Portas estão livres?
- [ ] Executou `docker-compose down` antes de reiniciar?

#### Filebeat não coleta logs
- [ ] Container da app está rodando?
- [ ] Nome do container é `app-para-logs`?
- [ ] Volumes estão montados corretamente?
  ```powershell
  docker inspect filebeat | Select-String "Mounts" -Context 0,10
  ```

#### Elasticsearch sem dados
- [ ] Aguardou tempo suficiente? (30-60 segundos)
- [ ] Filebeat está publicando eventos?
  ```powershell
  docker logs filebeat | Select-String "publish"
  ```
- [ ] Índice foi criado?
  ```powershell
  Invoke-WebRequest -Uri http://localhost:9200/_cat/indices?v
  ```

#### Kibana não mostra logs
- [ ] Index pattern foi criado corretamente?
- [ ] Período de tempo está correto? (últimas 24h)
- [ ] Há dados no Elasticsearch?
- [ ] Cache do navegador limpo?

---

## 📚 Recursos Adicionais

- [ ] **Leu o README.md**
- [ ] **Consultou LOGGING_GUIDE.md** para queries avançadas
- [ ] **Revisou COMMANDS.md** para comandos úteis
- [ ] **Verificou CORRECTIONS.md** para entender as mudanças

---

## ✅ Checklist Final de Sucesso

### Deve estar funcionando:
- ✅ 4 containers rodando
- ✅ Flask app respondendo
- ✅ Logs em formato JSON
- ✅ Filebeat coletando logs
- ✅ Elasticsearch armazenando dados
- ✅ Kibana mostrando logs
- ✅ Filtros e buscas funcionando

### Você deve conseguir:
- ✅ Fazer requisições para a API
- ✅ Ver logs no terminal do container
- ✅ Buscar logs no Elasticsearch
- ✅ Visualizar logs no Kibana
- ✅ Filtrar por endpoint, status, level
- ✅ Criar visualizações e dashboards

---

## 🎉 Projeto 100% Funcional!

Se todos os itens acima estão marcados, **parabéns!** Seu sistema de logging com ELK Stack está funcionando perfeitamente! 🚀

### Próximos Passos Sugeridos:
1. Experimente criar visualizações customizadas
2. Configure alertas para erros críticos
3. Explore queries KQL mais avançadas
4. Documente casos de uso específicos do seu projeto
5. Considere adicionar mais campos nos logs

---

## 📞 Ajuda

Se encontrou problemas não listados aqui:
1. Verifique os logs: `.\setup.ps1 -Logs`
2. Consulte LOGGING_GUIDE.md seção Troubleshooting
3. Execute limpeza completa: `.\setup.ps1 -Clean` e reinicie

---

**Data da última verificação:** _________________

**Status:** [ ] ✅ Tudo funcionando  |  [ ] ⚠️ Alguns problemas  |  [ ] ❌ Não funcionando
