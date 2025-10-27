# 🚀 Início Rápido - 5 Minutos

Este guia te coloca rodando em **menos de 5 minutos**!

---

## ⚡ Passo a Passo Rápido

### 1. Pré-requisitos (30 segundos)

✅ **Docker Desktop rodando** → [Baixar aqui](https://www.docker.com/products/docker-desktop/)

```powershell
# Verificar se Docker está rodando
docker --version
```

---

### 2. Iniciar Projeto (1 clique)

```powershell
# Na pasta do projeto, execute:
.\setup.ps1
```

**Aguarde 2-3 minutos** enquanto os containers inicializam...

☕ Vai tomar um café! O script irá:
- ✅ Construir a imagem da aplicação Flask
- ✅ Iniciar Elasticsearch
- ✅ Iniciar Kibana  
- ✅ Iniciar Filebeat
- ✅ Verificar se tudo está funcionando

---

### 3. Testar Aplicação (30 segundos)

Quando o script perguntar se deseja executar testes, digite **S** e pressione Enter.

Ou execute manualmente:
```powershell
.\setup.ps1 -Test
```

Você verá várias requisições sendo feitas e logs sendo gerados! 📊

---

### 4. Visualizar Logs no Kibana (2 minutos)

#### 4.1 Abrir Kibana
```powershell
# Abrir automaticamente no navegador
Start-Process "http://localhost:5601"
```

#### 4.2 Configurar Index Pattern (primeira vez apenas)

1. Clique no **menu ☰** (canto superior esquerdo)
2. Vá em **Management** → **Stack Management**
3. Clique em **Index Patterns** (lado esquerdo)
4. Clique em **Create index pattern**
5. Digite: **`flask-logs-*`**
6. Clique em **Next step**
7. Selecione **`@timestamp`**
8. Clique em **Create index pattern**

#### 4.3 Ver os Logs

1. Clique no **menu ☰**
2. Vá em **Analytics** → **Discover**
3. **Pronto!** Você deve ver todos os logs da aplicação! 🎉

**Dicas:**
- Ajuste o período de tempo (canto superior direito): "Last 15 minutes"
- Use filtros: `level: "ERROR"` ou `endpoint: "/health"`
- Clique nos logs para ver detalhes

---

## 🎯 URLs Principais

| Serviço | URL | Descrição |
|---------|-----|-----------|
| **Flask App** | http://localhost:5001 | Sua aplicação web |
| **Kibana** | http://localhost:5601 | Interface de visualização |
| **Elasticsearch** | http://localhost:9200 | API de busca |

---

## 🧪 Testar Manualmente

```powershell
# Endpoint principal
Invoke-WebRequest -Uri http://localhost:5001/

# Health check
Invoke-WebRequest -Uri http://localhost:5001/health

# Testar erro 404
Invoke-WebRequest -Uri http://localhost:5001/naoexiste -SkipHttpErrorCheck

# Ver logs gerados
docker logs app-para-logs --tail 10
```

---

## 🛑 Parar o Projeto

```powershell
.\setup.ps1 -Stop
```

---

## 🔄 Reiniciar o Projeto

```powershell
# Parar
.\setup.ps1 -Stop

# Aguardar 5 segundos
Start-Sleep -Seconds 5

# Iniciar novamente
.\setup.ps1
```

---

## 🧹 Limpeza Completa (se necessário)

```powershell
# Remove tudo: containers, volumes, imagens
.\setup.ps1 -Clean
```

---

## 📋 Comandos Mais Usados

```powershell
# Iniciar
.\setup.ps1

# Testar
.\setup.ps1 -Test

# Ver logs em tempo real
.\setup.ps1 -Logs

# Parar
.\setup.ps1 -Stop

# Status dos containers
docker ps

# Ver logs de um container específico
docker logs app-para-logs
docker logs filebeat
docker logs elasticsearch
docker logs kibana
```

---

## 🔍 Verificar se Está Funcionando

### ✅ Checklist Rápido

```powershell
# 1. Containers rodando? (deve mostrar 4)
docker ps

# 2. App respondendo?
Invoke-WebRequest -Uri http://localhost:5001/health

# 3. Elasticsearch tem dados?
Invoke-WebRequest -Uri http://localhost:9200/flask-logs-*/_count

# 4. Kibana acessível?
Start-Process "http://localhost:5601"
```

Se todos responderam **OK**, está tudo funcionando! ✅

---

## 🆘 Problemas Comuns

### Docker não está rodando
```
❌ Erro: Cannot connect to the Docker daemon
```
**Solução:** Abra o Docker Desktop e aguarde inicializar.

---

### Porta já em uso
```
❌ Error: Port 5001 is already allocated
```
**Solução:** 
```powershell
# Ver quem está usando a porta
netstat -ano | findstr :5001

# Parar o projeto antigo
.\setup.ps1 -Stop

# Ou matar o processo (substitua <PID>)
Stop-Process -Id <PID> -Force
```

---

### Filebeat não coleta logs
```powershell
# Verificar se está publicando eventos
docker logs filebeat | Select-String "publish"

# Se não estiver, reiniciar
docker-compose restart filebeat

# Aguardar 30 segundos
Start-Sleep -Seconds 30

# Verificar novamente
docker logs filebeat | Select-String "publish"
```

---

### Kibana não mostra logs

**Soluções:**

1. **Aguardar mais tempo** (pode levar até 2 minutos)
2. **Gerar mais logs:**
   ```powershell
   .\setup.ps1 -Test
   ```
3. **Verificar período de tempo no Kibana:**
   - Clique no relógio (canto superior direito)
   - Selecione "Last 1 hour" ou "Today"
4. **Recriar index pattern:**
   - Delete o index pattern antigo
   - Crie novamente: `flask-logs-*`

---

## 📚 Documentação Completa

Para informações detalhadas, consulte:

- **README.md** - Guia completo do projeto
- **LOGGING_GUIDE.md** - Como usar logging e Kibana
- **COMMANDS.md** - Todos os comandos úteis
- **CHECKLIST.md** - Verificação passo a passo
- **CORRECTIONS.md** - O que foi corrigido no projeto

---

## 🎉 Sucesso!

Se você chegou até aqui e está vendo logs no Kibana, **parabéns!** 🎊

Seu sistema de logging com ELK Stack está funcionando perfeitamente!

### Próximos Passos:

1. **Explore o Kibana:**
   - Crie visualizações (gráficos)
   - Crie um dashboard
   - Experimente filtros diferentes

2. **Teste diferentes cenários:**
   - Gere erros intencionalmente
   - Faça muitas requisições
   - Veja como os logs aparecem

3. **Customize:**
   - Adicione mais campos nos logs (`app.py`)
   - Crie alertas no Kibana
   - Ajuste configurações do Filebeat

---

## 💡 Dica Final

**Mantenha esta página aberta** como referência rápida! 📌

Para ajuda detalhada com qualquer comando ou conceito, consulte os outros arquivos de documentação.

---

**Tempo total:** ⏱️ ~5 minutos

**Dificuldade:** 🟢 Fácil

**Resultado:** 🎯 Sistema completo de logging funcionando!

---

Desenvolvido com ❤️ para facilitar sua vida com DevOps!
