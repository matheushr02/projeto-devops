# Script PowerShell para configurar e iniciar o projeto
param(
    [switch]$Clean,
    [switch]$Stop,
    [switch]$Logs,
    [switch]$Test
)

$ErrorActionPreference = "Stop"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "    Projeto DevOps - Flask + ELK   " -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Função para verificar se Docker está rodando
function Test-DockerRunning {
    try {
        $result = docker ps 2>&1
        if ($LASTEXITCODE -eq 0) {
            return $true
        }
        return $false
    } catch {
        return $false
    }
}

# Verificar se Docker está instalado e rodando
if (-not (Test-DockerRunning)) {
    Write-Host "Docker nao esta rodando ou nao esta instalado" -ForegroundColor Red
    Write-Host "   Por favor, inicie o Docker Desktop e tente novamente" -ForegroundColor Yellow
    exit 1
}

# Modo: Parar containers
if ($Stop) {
    Write-Host "Parando todos os containers..." -ForegroundColor Yellow
    docker-compose down
    Write-Host "Containers parados" -ForegroundColor Green
    exit 0
}

# Modo: Limpeza completa
if ($Clean) {
    Write-Host "Limpeza completa (containers + volumes + imagens)..." -ForegroundColor Yellow
    docker-compose down -v --rmi all
    Write-Host "Limpeza concluida" -ForegroundColor Green
    exit 0
}

# Modo: Ver logs
if ($Logs) {
    Write-Host "Logs dos containers (Ctrl+C para sair)..." -ForegroundColor Yellow
    Write-Host ""
    docker-compose logs -f
    exit 0
}

# Modo: Executar testes
if ($Test) {
    Write-Host "Executando testes de requisicoes..." -ForegroundColor Yellow
    Write-Host ""
    & "$PSScriptRoot\test_logging.ps1"
    exit 0
}

# Modo padrão: Iniciar o projeto
Write-Host "Iniciando projeto..." -ForegroundColor Yellow
Write-Host ""

# Verificar se já existem containers rodando
$existingContainers = docker ps -a --filter "name=app-para-logs" --filter "name=elasticsearch" --filter "name=kibana" --filter "name=filebeat" -q
if ($existingContainers) {
    Write-Host "Containers existentes encontrados" -ForegroundColor Yellow
    $response = Read-Host "Deseja parar e remover os containers existentes? (S/N)"
    if ($response -eq "S" -or $response -eq "s") {
        Write-Host "   Removendo containers antigos..." -ForegroundColor Gray
        docker-compose down
        Write-Host "   Containers removidos" -ForegroundColor Green
    }
    Write-Host ""
}

# Construir e iniciar os containers
Write-Host "Construindo imagens e iniciando containers..." -ForegroundColor Yellow
docker-compose up -d --build

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erro ao iniciar os containers" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Containers iniciados com sucesso!" -ForegroundColor Green
Write-Host ""

# Mostrar status dos containers
Write-Host "Status dos containers:" -ForegroundColor Yellow
docker-compose ps
Write-Host ""

# Aguardar serviços estarem prontos
Write-Host "Aguardando servicos ficarem prontos..." -ForegroundColor Yellow
Write-Host ""

# Aguardar Elasticsearch
Write-Host "   Elasticsearch..." -ForegroundColor Gray
$maxAttempts = 60
$attempt = 0
while ($attempt -lt $maxAttempts) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:9200" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "   Elasticsearch pronto" -ForegroundColor Green
            break
        }
    } catch {
        $attempt++
        if ($attempt % 10 -eq 0) {
            Write-Host "      Aguardando... ($attempt/$maxAttempts)" -ForegroundColor Gray
        }
        Start-Sleep -Seconds 2
    }
}

# Aguardar Flask App
Write-Host "   Flask App..." -ForegroundColor Gray
$attempt = 0
while ($attempt -lt 30) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5001/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "   Flask App pronta" -ForegroundColor Green
            break
        }
    } catch {
        $attempt++
        Start-Sleep -Seconds 2
    }
}

# Aguardar Kibana
Write-Host "   Kibana (pode demorar 1-2 minutos)..." -ForegroundColor Gray
$attempt = 0
while ($attempt -lt 60) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5601/api/status" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "   Kibana pronto" -ForegroundColor Green
            break
        }
    } catch {
        $attempt++
        if ($attempt % 10 -eq 0) {
            Write-Host "      Aguardando... ($attempt/60)" -ForegroundColor Gray
        }
        Start-Sleep -Seconds 2
    }
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Projeto Iniciado com Sucesso!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "URLs Disponiveis:" -ForegroundColor Yellow
Write-Host "   Flask App:      http://localhost:5001" -ForegroundColor White
Write-Host "   Elasticsearch:  http://localhost:9200" -ForegroundColor White
Write-Host "   Kibana:         http://localhost:5601" -ForegroundColor White
Write-Host ""

Write-Host "Endpoints da API:" -ForegroundColor Yellow
Write-Host "   GET /               - Mensagem de boas-vindas" -ForegroundColor White
Write-Host "   GET /health         - Health check" -ForegroundColor White
Write-Host "   GET /status/<code>  - Retorna status code especifico" -ForegroundColor White
Write-Host ""

Write-Host "Comandos uteis:" -ForegroundColor Yellow
Write-Host "   .\setup.ps1 -Test    - Executar testes de requisicoes" -ForegroundColor White
Write-Host "   .\setup.ps1 -Logs    - Ver logs dos containers" -ForegroundColor White
Write-Host "   .\setup.ps1 -Stop    - Parar os containers" -ForegroundColor White
Write-Host "   .\setup.ps1 -Clean   - Limpeza completa" -ForegroundColor White
Write-Host ""

Write-Host "Proximos passos:" -ForegroundColor Yellow
Write-Host "   1. Execute: .\setup.ps1 -Test" -ForegroundColor White
Write-Host "   2. Acesse o Kibana em: http://localhost:5601" -ForegroundColor White
Write-Host "   3. Configure o index pattern: flask-logs-*" -ForegroundColor White
Write-Host "   4. Explore os logs na aba 'Discover'" -ForegroundColor White
Write-Host ""

# Perguntar se deseja executar os testes
$runTests = Read-Host "Deseja executar os testes de requisicoes agora? (S/N)"
if ($runTests -eq "S" -or $runTests -eq "s") {
    Write-Host ""
    & "$PSScriptRoot\test_logging.ps1"
}
