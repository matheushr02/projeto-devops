# 🚀 Comandos Úteis - Guia Rápido

## 📋 Comandos Essenciais

### Iniciar Projeto
```powershell
# Opção 1: Usando script automatizado (RECOMENDADO)
.\setup.ps1

# Opção 2: Manual
docker-compose up -d --build
```

### Parar Projeto
```powershell
# Opção 1: Usando script
.\setup.ps1 -Stop

# Opção 2: Manual
docker-compose down
```

### Ver Logs
```powershell
# Todos os containers
.\setup.ps1 -Logs
# ou
docker-compose logs -f

# Container específico
docker logs app-para-logs -f
docker logs filebeat -f
docker logs elasticsearch -f
docker logs kibana -f
```

### Testar Aplicação
```powershell
# Script de testes automatizado
.\setup.ps1 -Test
# ou
.\test_logging.ps1
```

### Limpeza Completa
```powershell
# Remove containers, volumes e imagens
.\setup.ps1 -Clean
```

---

## 🔍 Verificação e Diagnóstico

### Status dos Containers
```powershell
# Ver containers rodando
docker ps

# Ver todos containers (incluindo parados)
docker ps -a

# Ver uso de recursos
docker stats
```

### Verificar Saúde dos Serviços

#### Flask App
```powershell
# Health check
Invoke-WebRequest -Uri http://localhost:5001/health

# Ver resposta formatada
(Invoke-WebRequest -Uri http://localhost:5001/health).Content | ConvertFrom-Json
```

#### Elasticsearch
```powershell
# Status do cluster
Invoke-WebRequest -Uri http://localhost:9200/_cluster/health | Select-Object -Expand Content

# Listar índices
Invoke-WebRequest -Uri http://localhost:9200/_cat/indices?v

# Contar documentos no índice
Invoke-WebRequest -Uri http://localhost:9200/flask-logs-*/_count | Select-Object -Expand Content

# Ver documentos recentes
Invoke-WebRequest -Uri "http://localhost:9200/flask-logs-*/_search?size=5&sort=@timestamp:desc" | Select-Object -Expand Content | ConvertFrom-Json
```

#### Filebeat
```powershell
# Ver logs e filtrar por publicações
docker logs filebeat 2>&1 | Select-String "publish"

# Ver estatísticas
docker logs filebeat 2>&1 | Select-String "Non-zero metrics"

# Ver últimas 50 linhas
docker logs filebeat --tail 50
```

#### Kibana
```powershell
# Status da API
Invoke-WebRequest -Uri http://localhost:5601/api/status | Select-Object -Expand Content

# Ou simplesmente abrir no navegador
Start-Process "http://localhost:5601"
```

---

## 🧪 Testes Manuais

### Testar Endpoints
```powershell
# Endpoint principal
Invoke-WebRequest -Uri http://localhost:5001/

# Health check
Invoke-WebRequest -Uri http://localhost:5001/health

# Status 200 (OK)
Invoke-WebRequest -Uri http://localhost:5001/status/200

# Status 404 (Not Found)
Invoke-WebRequest -Uri http://localhost:5001/status/404 -SkipHttpErrorCheck

# Status 500 (Error)
Invoke-WebRequest -Uri http://localhost:5001/status/500 -SkipHttpErrorCheck

# Endpoint inexistente (404)
Invoke-WebRequest -Uri http://localhost:5001/naoexiste -SkipHttpErrorCheck

# Status inválido (400)
Invoke-WebRequest -Uri http://localhost:5001/status/999 -SkipHttpErrorCheck
```

### Gerar Volume de Logs
```powershell
# Loop de 100 requisições
for ($i=1; $i -le 100; $i++) {
    Invoke-WebRequest -Uri http://localhost:5001/health -UseBasicParsing | Out-Null
    Write-Host "Requisição $i enviada"
}

# Requisições variadas
1..50 | ForEach-Object {
    $endpoints = @("/", "/health", "/status/200", "/status/404", "/status/500")
    $endpoint = $endpoints | Get-Random
    Invoke-WebRequest -Uri "http://localhost:5001$endpoint" -SkipHttpErrorCheck -UseBasicParsing | Out-Null
    Write-Host "Teste $_: $endpoint"
    Start-Sleep -Milliseconds 100
}
```

---

## 📊 Elasticsearch - Queries Diretas

### Buscar Logs
```powershell
# Buscar logs de erro
$body = @{
    query = @{
        match = @{
            level = "ERROR"
        }
    }
    size = 10
} | ConvertTo-Json

Invoke-WebRequest -Method POST -Uri "http://localhost:9200/flask-logs-*/_search" `
    -ContentType "application/json" -Body $body | Select-Object -Expand Content

# Buscar por endpoint
$body = @{
    query = @{
        match = @{
            endpoint = "/health"
        }
    }
    size = 10
} | ConvertTo-Json

Invoke-WebRequest -Method POST -Uri "http://localhost:9200/flask-logs-*/_search" `
    -ContentType "application/json" -Body $body | Select-Object -Expand Content
```

### Estatísticas
```powershell
# Agregação por status_code
$body = @{
    size = 0
    aggs = @{
        status_codes = @{
            terms = @{
                field = "status_code"
            }
        }
    }
} | ConvertTo-Json -Depth 5

Invoke-WebRequest -Method POST -Uri "http://localhost:9200/flask-logs-*/_search" `
    -ContentType "application/json" -Body $body | Select-Object -Expand Content

# Agregação por endpoint
$body = @{
    size = 0
    aggs = @{
        endpoints = @{
            terms = @{
                field = "endpoint.keyword"
            }
        }
    }
} | ConvertTo-Json -Depth 5

Invoke-WebRequest -Method POST -Uri "http://localhost:9200/flask-logs-*/_search" `
    -ContentType "application/json" -Body $body | Select-Object -Expand Content
```

---

## 🔧 Manutenção

### Reiniciar Serviços
```powershell
# Reiniciar um container específico
docker-compose restart app
docker-compose restart filebeat
docker-compose restart elasticsearch
docker-compose restart kibana

# Reiniciar todos
docker-compose restart
```

### Rebuild da Aplicação
```powershell
# Rebuild apenas da app
docker-compose up -d --build app

# Rebuild completo
docker-compose down
docker-compose up -d --build
```

### Limpar Logs Antigos
```powershell
# Listar índices
Invoke-WebRequest -Uri "http://localhost:9200/_cat/indices/flask-logs-*?v"

# Deletar índice específico (exemplo: logs de 7 dias atrás)
$oldDate = (Get-Date).AddDays(-7).ToString("yyyy.MM.dd")
Invoke-WebRequest -Method DELETE -Uri "http://localhost:9200/flask-logs-$oldDate"

# Deletar todos índices (CUIDADO!)
# Invoke-WebRequest -Method DELETE -Uri "http://localhost:9200/flask-logs-*"
```

### Backup e Restore

#### Backup de Configurações
```powershell
# Backup do docker-compose
Copy-Item docker-compose.yml docker-compose.yml.backup

# Backup do filebeat.yml
Copy-Item logging\filebeat.yml logging\filebeat.yml.backup

# Backup do app.py
Copy-Item app.py app.py.backup
```

#### Exportar Dados do Elasticsearch
```powershell
# Exportar para JSON (últimos 1000 logs)
Invoke-WebRequest -Uri "http://localhost:9200/flask-logs-*/_search?size=1000" `
    | Select-Object -Expand Content | Out-File -FilePath "backup-logs.json"
```

---

## 📱 Acesso Rápido

### URLs Principais
```powershell
# Abrir aplicação Flask
Start-Process "http://localhost:5001"

# Abrir Kibana
Start-Process "http://localhost:5601"

# Abrir Elasticsearch (browser ou API)
Start-Process "http://localhost:9200"
```

### Atalhos PowerShell
```powershell
# Criar aliases (adicione ao seu $PROFILE)
function Start-DevOpsProject { .\setup.ps1 }
function Stop-DevOpsProject { .\setup.ps1 -Stop }
function Test-DevOpsProject { .\setup.ps1 -Test }
function Show-DevOpsLogs { .\setup.ps1 -Logs }

# Usar aliases
Set-Alias -Name devstart -Value Start-DevOpsProject
Set-Alias -Name devstop -Value Stop-DevOpsProject
Set-Alias -Name devtest -Value Test-DevOpsProject
Set-Alias -Name devlogs -Value Show-DevOpsLogs
```

---

## 🐛 Troubleshooting Rápido

### Problema: Container não inicia
```powershell
# Ver erro específico
docker logs <container-name>

# Verificar portas em uso
netstat -ano | findstr :5001
netstat -ano | findstr :9200
netstat -ano | findstr :5601

# Matar processo na porta (se necessário)
# Substitua <PID> pelo ID do processo
Stop-Process -Id <PID> -Force
```

### Problema: Filebeat não coleta logs
```powershell
# 1. Verificar se container da app está rodando
docker ps | findstr app-para-logs

# 2. Verificar logs do filebeat
docker logs filebeat 2>&1 | Select-String "ERROR"

# 3. Reiniciar filebeat
docker-compose restart filebeat

# 4. Verificar configuração
docker exec filebeat cat /usr/share/filebeat/filebeat.yml
```

### Problema: Elasticsearch sem memória
```powershell
# Verificar uso de memória
docker stats elasticsearch --no-stream

# Aumentar limite no docker-compose.yml
# Altere ES_JAVA_OPTS: "-Xms512m -Xmx512m"
# Para:  ES_JAVA_OPTS: "-Xms1g -Xmx1g"

# Aplicar mudança
docker-compose down
docker-compose up -d
```

### Problema: Kibana não carrega
```powershell
# 1. Verificar se Elasticsearch está funcionando
Invoke-WebRequest -Uri http://localhost:9200

# 2. Aguardar mais tempo (pode levar 2-3 minutos)
Start-Sleep -Seconds 30

# 3. Ver logs do Kibana
docker logs kibana --tail 50

# 4. Reiniciar Kibana
docker-compose restart kibana
```

---

## 📚 Comandos Docker Úteis

### Informações
```powershell
# Ver todas imagens
docker images

# Ver volumes
docker volume ls

# Ver redes
docker network ls

# Inspecionar container
docker inspect app-para-logs

# Ver processos dentro do container
docker top app-para-logs
```

### Limpeza
```powershell
# Remover containers parados
docker container prune

# Remover imagens não usadas
docker image prune

# Remover volumes não usados
docker volume prune

# Limpar tudo (CUIDADO!)
docker system prune -a --volumes
```

### Executar Comandos nos Containers
```powershell
# Shell no container da app
docker exec -it app-para-logs sh

# Shell no Elasticsearch
docker exec -it elasticsearch bash

# Ver arquivo de configuração do Filebeat
docker exec filebeat cat /usr/share/filebeat/filebeat.yml

# Testar Python no container
docker exec app-para-logs python -c "print('Hello from Docker')"
```

---

## 💡 Dicas e Truques

### Monitoramento em Tempo Real
```powershell
# Terminal 1: Logs da aplicação
docker logs -f app-para-logs

# Terminal 2: Logs do Filebeat
docker logs -f filebeat

# Terminal 3: Fazer requisições
while ($true) { 
    Invoke-WebRequest -Uri http://localhost:5001/health -UseBasicParsing | Out-Null
    Start-Sleep -Seconds 2
}
```

### Script de Health Check Completo
```powershell
# Salve como health_check.ps1
$services = @(
    @{Name="Flask App"; Url="http://localhost:5001/health"},
    @{Name="Elasticsearch"; Url="http://localhost:9200"},
    @{Name="Kibana"; Url="http://localhost:5601/api/status"}
)

foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri $service.Url -TimeoutSec 5 -UseBasicParsing
        Write-Host "✅ $($service.Name): OK ($($response.StatusCode))" -ForegroundColor Green
    } catch {
        Write-Host "❌ $($service.Name): FALHOU" -ForegroundColor Red
    }
}
```

---

## 📖 Referência Rápida

| Comando | Ação |
|---------|------|
| `.\setup.ps1` | Iniciar projeto |
| `.\setup.ps1 -Stop` | Parar projeto |
| `.\setup.ps1 -Test` | Executar testes |
| `.\setup.ps1 -Logs` | Ver logs |
| `.\setup.ps1 -Clean` | Limpeza completa |
| `docker-compose ps` | Status dos containers |
| `docker logs <container>` | Ver logs de um container |
| `docker-compose restart <service>` | Reiniciar serviço |

---

**💡 Dica:** Mantenha este arquivo aberto em uma janela separada para consulta rápida!
