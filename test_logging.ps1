# Script para gerar logs de teste# Script PowerShell para testar a aplicacao e gerar logs# Script PowerShell para testar a aplicação e gerar logs

Write-Host "Gerando logs de teste..." -ForegroundColor Cyan

Write-Host "==================================" -ForegroundColor CyanWrite-Host "==================================" -ForegroundColor Cyan

# Teste 1: Endpoint principal

Write-Host "Teste 1: /" -ForegroundColor YellowWrite-Host "Testando Aplicacao Flask com Logs" -ForegroundColor CyanWrite-Host "Testando Aplicação Flask com Logs" -ForegroundColor Cyan

Invoke-WebRequest -Uri "http://localhost:5001/" -UseBasicParsing | Out-Null

Write-Host "==================================" -ForegroundColor CyanWrite-Host "==================================" -ForegroundColor Cyan

# Teste 2: Health check

Write-Host "Teste 2: /health" -ForegroundColor YellowWrite-Host ""Write-Host ""

Invoke-WebRequest -Uri "http://localhost:5001/health" -UseBasicParsing | Out-Null



# Teste 3: Status 200

Write-Host "Teste 3: /status/200" -ForegroundColor Yellow# Funcao para fazer requisicoes e exibir resultado# Função para fazer requisições e exibir resultado

Invoke-WebRequest -Uri "http://localhost:5001/status/200" -UseBasicParsing | Out-Null

function Test-Endpoint {function Test-Endpoint {

# Teste 4: Status 404

Write-Host "Teste 4: /status/404" -ForegroundColor Yellow    param(    param(

Invoke-WebRequest -Uri "http://localhost:5001/status/404" -UseBasicParsing -SkipHttpErrorCheck | Out-Null

        [string]$Url,        [string]$Url,

# Teste 5: Status 500

Write-Host "Teste 5: /status/500" -ForegroundColor Yellow        [string]$Description        [string]$Description

Invoke-WebRequest -Uri "http://localhost:5001/status/500" -UseBasicParsing -SkipHttpErrorCheck | Out-Null

    )    )

# Teste 6: Endpoint inexistente

Write-Host "Teste 6: /naoexiste" -ForegroundColor Yellow        

Invoke-WebRequest -Uri "http://localhost:5001/naoexiste" -UseBasicParsing -SkipHttpErrorCheck | Out-Null

    Write-Host "Testando: $Description" -ForegroundColor Yellow    Write-Host "📍 $Description" -ForegroundColor Yellow

# Teste 7: Status invalido

Write-Host "Teste 7: /status/999" -ForegroundColor Yellow    Write-Host "   URL: $Url" -ForegroundColor Gray    Write-Host "   URL: $Url" -ForegroundColor Gray

Invoke-WebRequest -Uri "http://localhost:5001/status/999" -UseBasicParsing -SkipHttpErrorCheck | Out-Null

        

# Teste 8: Multiplas requisicoes

Write-Host "Teste 8: Multiplas requisicoes" -ForegroundColor Yellow    try {    try {

for ($i = 1; $i -le 20; $i++) {

    Invoke-WebRequest -Uri "http://localhost:5001/health" -UseBasicParsing | Out-Null        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -SkipHttpErrorCheck 2>$null        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -SkipHttpErrorCheck 2>$null

    Write-Host "   Requisicao $i" -ForegroundColor Gray

}        Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Green        Write-Host "   ✅ Status: $($response.StatusCode)" -ForegroundColor Green



Write-Host ""        Write-Host "   Resposta: $($response.Content)" -ForegroundColor White        Write-Host "   Resposta: $($response.Content)" -ForegroundColor White

Write-Host "Testes concluidos! Logs gerados." -ForegroundColor Green

Write-Host "Aguarde 30 segundos e acesse: http://localhost:5601" -ForegroundColor Cyan    } catch {    } catch {


        Write-Host "   Erro: $_" -ForegroundColor Red        Write-Host "   ❌ Erro: $_" -ForegroundColor Red

    }    }

    Write-Host ""    Write-Host ""

    Start-Sleep -Milliseconds 500    Start-Sleep -Milliseconds 500

}}



# Aguardar a aplicacao estar pronta# Aguardar a aplicação estar pronta

Write-Host "Aguardando aplicacao estar pronta..." -ForegroundColor YellowWrite-Host "⏳ Aguardando aplicação estar pronta..." -ForegroundColor Yellow

$maxAttempts = 30$maxAttempts = 30

$attempt = 0$attempt = 0

$ready = $false$ready = $false



while (-not $ready -and $attempt -lt $maxAttempts) {while (-not $ready -and $attempt -lt $maxAttempts) {

    try {    try {

        $response = Invoke-WebRequest -Uri "http://localhost:5001/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue        $response = Invoke-WebRequest -Uri "http://localhost:5001/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue

        if ($response.StatusCode -eq 200) {        if ($response.StatusCode -eq 200) {

            $ready = $true            $ready = $true

            Write-Host "Aplicacao esta pronta!" -ForegroundColor Green            Write-Host "✅ Aplicação está pronta!" -ForegroundColor Green

        }        }

    } catch {    } catch {

        $attempt++        $attempt++

        Write-Host "   Tentativa $attempt de $maxAttempts..." -ForegroundColor Gray        Write-Host "   Tentativa $attempt de $maxAttempts..." -ForegroundColor Gray

        Start-Sleep -Seconds 2        Start-Sleep -Seconds 2

    }    }

}}



if (-not $ready) {if (-not $ready) {

    Write-Host "Aplicacao nao respondeu apos $maxAttempts tentativas" -ForegroundColor Red    Write-Host "❌ Aplicação não respondeu após $maxAttempts tentativas" -ForegroundColor Red

    Write-Host "   Verifique se o container esta rodando: docker ps" -ForegroundColor Yellow    Write-Host "   Verifique se o container está rodando: docker ps" -ForegroundColor Yellow

    exit 1    exit 1

}}



Write-Host ""Write-Host ""

Write-Host "Iniciando testes..." -ForegroundColor CyanWrite-Host "Iniciando testes..." -ForegroundColor Cyan

Write-Host ""Write-Host ""



# Teste 1: Endpoint principal# Teste 1: Endpoint principal

Test-Endpoint -Url "http://localhost:5001/" -Description "Teste 1: Endpoint Principal"Test-Endpoint -Url "http://localhost:5001/" -Description "Teste 1: Endpoint Principal"



# Teste 2: Health check# Teste 2: Health check

Test-Endpoint -Url "http://localhost:5001/health" -Description "Teste 2: Health Check"Test-Endpoint -Url "http://localhost:5001/health" -Description "Teste 2: Health Check"



# Teste 3: Status 200# Teste 3: Status 200

Test-Endpoint -Url "http://localhost:5001/status/200" -Description "Teste 3: Status Code 200 (OK)"Test-Endpoint -Url "http://localhost:5001/status/200" -Description "Teste 3: Status Code 200 (OK)"



# Teste 4: Status 404# Teste 4: Status 404

Test-Endpoint -Url "http://localhost:5001/status/404" -Description "Teste 4: Status Code 404 (Not Found)"Test-Endpoint -Url "http://localhost:5001/status/404" -Description "Teste 4: Status Code 404 (Not Found)"



# Teste 5: Status 500# Teste 5: Status 500

Test-Endpoint -Url "http://localhost:5001/status/500" -Description "Teste 5: Status Code 500 (Internal Error)"Test-Endpoint -Url "http://localhost:5001/status/500" -Description "Teste 5: Status Code 500 (Internal Error)"



# Teste 6: Endpoint inexistente# Teste 6: Endpoint inexistente

Test-Endpoint -Url "http://localhost:5001/naoexiste" -Description "Teste 6: Endpoint Inexistente"Test-Endpoint -Url "http://localhost:5001/naoexiste" -Description "Teste 6: Endpoint Inexistente"



# Teste 7: Status invalido# Teste 7: Status inválido

Test-Endpoint -Url "http://localhost:5001/status/999" -Description "Teste 7: Status Code Invalido (999)"Test-Endpoint -Url "http://localhost:5001/status/999" -Description "Teste 7: Status Code Inválido (999)"



# Teste 8: Multiplas requisicoes rapidas# Teste 8: Múltiplas requisições rápidas

Write-Host "Teste 8: Multiplas Requisicoes Rapidas (10x)" -ForegroundColor YellowWrite-Host "📍 Teste 8: Múltiplas Requisições Rápidas (10x)" -ForegroundColor Yellow

for ($i = 1; $i -le 10; $i++) {for ($i = 1; $i -le 10; $i++) {

    try {    try {

        $response = Invoke-WebRequest -Uri "http://localhost:5001/health" -UseBasicParsing -SkipHttpErrorCheck 2>$null        $response = Invoke-WebRequest -Uri "http://localhost:5001/health" -UseBasicParsing -SkipHttpErrorCheck 2>$null

        Write-Host "   Requisicao $i : Status $($response.StatusCode)" -ForegroundColor Gray        Write-Host "   Requisição $i : Status $($response.StatusCode)" -ForegroundColor Gray

    } catch {    } catch {

        Write-Host "   Requisicao $i : Erro" -ForegroundColor Red        Write-Host "   Requisição $i : Erro" -ForegroundColor Red

    }    }

    Start-Sleep -Milliseconds 100    Start-Sleep -Milliseconds 100

}}

Write-Host ""Write-Host ""



Write-Host "==================================" -ForegroundColor CyanWrite-Host "==================================" -ForegroundColor Cyan

Write-Host "Testes Concluidos!" -ForegroundColor GreenWrite-Host "✅ Testes Concluídos!" -ForegroundColor Green

Write-Host "==================================" -ForegroundColor CyanWrite-Host "==================================" -ForegroundColor Cyan

Write-Host ""Write-Host ""

Write-Host "Proximos passos:" -ForegroundColor YellowWrite-Host "📊 Próximos passos:" -ForegroundColor Yellow

Write-Host "   1. Aguarde alguns segundos para os logs serem processados" -ForegroundColor WhiteWrite-Host "   1. Aguarde alguns segundos para os logs serem processados" -ForegroundColor White

Write-Host "   2. Acesse o Kibana em: http://localhost:5601" -ForegroundColor WhiteWrite-Host "   2. Acesse o Kibana em: http://localhost:5601" -ForegroundColor White

Write-Host "   3. Va em 'Discover' para visualizar os logs" -ForegroundColor WhiteWrite-Host "   3. Vá em 'Discover' para visualizar os logs" -ForegroundColor White

Write-Host "   4. Use filtros como: level:'ERROR' ou endpoint:'/health'" -ForegroundColor WhiteWrite-Host "   4. Use filtros como: level:'ERROR' ou endpoint:'/health'" -ForegroundColor White

Write-Host ""Write-Host ""

Write-Host "Verificar logs dos containers:" -ForegroundColor YellowWrite-Host "🔍 Verificar logs dos containers:" -ForegroundColor Yellow

Write-Host "   docker logs app-para-logs" -ForegroundColor GrayWrite-Host "   docker logs app-para-logs" -ForegroundColor Gray

Write-Host "   docker logs filebeat" -ForegroundColor GrayWrite-Host "   docker logs filebeat" -ForegroundColor Gray

Write-Host "   docker logs elasticsearch" -ForegroundColor GrayWrite-Host "   docker logs elasticsearch" -ForegroundColor Gray

Write-Host ""Write-Host ""

