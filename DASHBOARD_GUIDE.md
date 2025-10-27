# 📊 Guia Completo: Criando Dashboard no Kibana

## 🎯 Objetivo
Criar um dashboard completo para monitorar sua aplicação Flask com visualizações de:
- Total de requisições
- Distribuição de status codes
- Requisições por endpoint
- Erros ao longo do tempo
- Logs recentes

---

## 📋 Passo 1: Acessar o Kibana

1. Abra seu navegador em: **http://localhost:5601**
2. Aguarde o Kibana carregar completamente

---

## 📑 Passo 2: Criar Index Pattern (se ainda não criou)

1. Clique no **menu ☰** (canto superior esquerdo)
2. Vá em **Management** → **Stack Management**
3. No menu lateral esquerdo, clique em **Index Patterns** (seção Kibana)
4. Clique em **Create index pattern**
5. Em "Name", digite: **`flask-logs-*`**
6. Clique em **Next step**
7. Em "Time field", selecione: **`@timestamp`**
8. Clique em **Create index pattern**

✅ Seu index pattern está criado!

---

## 📊 Passo 3: Criar Visualizações

Vamos criar 6 visualizações diferentes:

### 📈 Visualização 1: Total de Requisições (Metric)

1. Menu ☰ → **Analytics** → **Visualize Library**
2. Clique em **Create visualization**
3. Selecione **Lens** (recomendado) ou **Metric**
4. Selecione o index pattern: **flask-logs-***

**Se usar Lens:**
- Arraste o campo **Count** para a área central
- O número total de documentos aparecerá

**Se usar Metric:**
- Em "Metrics", mantenha **Count**
- Não precisa configurar nada mais

5. Clique em **Save** no canto superior direito
6. Nome: **Total de Requisicoes**
7. Clique em **Save and return**

---

### 🥧 Visualização 2: Distribuição por Status Code (Pie Chart)

1. Clique em **Create visualization** novamente
2. Selecione **Lens** ou **Pie**
3. Selecione o index pattern: **flask-logs-***

**Se usar Lens:**
- Arraste **status_code** para a área "Break down by"
- O gráfico de pizza será criado automaticamente

**Se usar Pie:**
- Em "Buckets", clique em **Add** → **Split slices**
- Aggregation: **Terms**
- Field: **status_code**
- Size: **10**
- Clique em **▶ Update**

4. **Save** → Nome: **Status Code Distribution**

---

### 📊 Visualização 3: Requisições por Endpoint (Bar Chart)

1. **Create visualization**
2. Selecione **Lens** ou **Vertical bar**
3. Index pattern: **flask-logs-***

**Se usar Lens:**
- Arraste **endpoint.keyword** para "Horizontal axis"
- Arraste **Count** para "Vertical axis"

**Se usar Vertical bar:**
- **Y-axis**: Metrics → **Count**
- **X-axis**: Buckets → **Add** → **X-axis**
  - Aggregation: **Terms**
  - Field: **endpoint.keyword**
  - Order By: **metric: Count**
  - Order: **Descending**
  - Size: **10**
- Clique em **▶ Update**

4. **Save** → Nome: **Requests by Endpoint**

---

### 📉 Visualização 4: Requisições ao Longo do Tempo (Line Chart)

1. **Create visualization**
2. Selecione **Lens** ou **Line**
3. Index pattern: **flask-logs-***

**Se usar Lens:**
- Arraste **@timestamp** para "Horizontal axis"
- Arraste **Count** para "Vertical axis"
- O gráfico de linha será criado

**Se usar Line:**
- **Y-axis**: Metrics → **Count**
- **X-axis**: Buckets → **Add** → **X-axis**
  - Aggregation: **Date Histogram**
  - Field: **@timestamp**
  - Minimum interval: **Auto**
- Clique em **▶ Update**

4. **Save** → Nome: **Requests Over Time**

---

### 🔴 Visualização 5: Total de Erros (Metric com Filtro)

1. **Create visualization**
2. Selecione **Lens** ou **Metric**
3. Index pattern: **flask-logs-***

**Adicionar Filtro:**
- Clique em **Add filter** (topo da página)
- Field: **level**
- Operator: **is**
- Value: **ERROR**
- Clique em **Save**

**Configurar Métrica:**
- Use **Count** como métrica

4. **Save** → Nome: **Total Errors**

---

### ⚠️ Visualização 6: Distribuição por Nível de Log (Donut Chart)

1. **Create visualization**
2. Selecione **Lens** ou **Pie**
3. Index pattern: **flask-logs-***

**Se usar Lens:**
- Arraste **level** para "Break down by"
- No menu de configuração, selecione **Donut** como tipo

**Se usar Pie:**
- Buckets → **Add** → **Split slices**
  - Aggregation: **Terms**
  - Field: **level**
  - Size: **5**
- Em **Options**, selecione **Donut** em "Pie Type"
- **▶ Update**

4. **Save** → Nome: **Log Level Distribution**

---

## 🎨 Passo 4: Criar o Dashboard

1. Menu ☰ → **Analytics** → **Dashboard**
2. Clique em **Create dashboard**
3. Clique em **Add from library** (ou ícone +)
4. Selecione todas as 6 visualizações que você criou:
   - ✅ Total de Requisicoes
   - ✅ Status Code Distribution
   - ✅ Requests by Endpoint
   - ✅ Requests Over Time
   - ✅ Total Errors
   - ✅ Log Level Distribution

5. Clique em **Close** após adicionar todas

---

## 🎯 Passo 5: Organizar o Dashboard

Organize os painéis desta forma (arraste e redimensione):

```
┌─────────────────────────────────────────────────────────┐
│  Total de Requisicoes  │  Total Errors  │  Log Level   │
│      (Metric)          │   (Metric)     │ Distribution │
├─────────────────────────────────────────────────────────┤
│          Requests Over Time (Line Chart)                │
│                    (Largo)                              │
├──────────────────────────┬──────────────────────────────┤
│  Status Code             │  Requests by Endpoint        │
│  Distribution (Pie)      │  (Bar Chart)                 │
└──────────────────────────┴──────────────────────────────┘
```

**Como organizar:**
1. Clique e arraste cada painel para posicioná-lo
2. Arraste as bordas para redimensionar
3. Coloque as métricas no topo (pequenas)
4. Coloque o gráfico de linha no meio (largo)
5. Coloque os gráficos de pizza e barras embaixo

---

## 💾 Passo 6: Salvar o Dashboard

1. Clique em **Save** no canto superior direito
2. Título: **Flask App Monitoring Dashboard**
3. Descrição: **Dashboard de monitoramento da aplicacao Flask com logs e metricas**
4. Marque a opção: **Store time with dashboard** (opcional)
5. Clique em **Save**

---

## ⚙️ Passo 7: Configurar Período de Tempo

1. Clique no **relógio** (canto superior direito)
2. Selecione: **Last 15 minutes** (ou **Last 1 hour**)
3. Marque: **Refresh every** → **10 seconds** (para atualização automática)
4. Clique em **Apply**

---

## 🎨 Passo 8: Adicionar Filtros Interativos (Opcional)

Para tornar o dashboard mais interativo:

1. Clique em **Add filter** (topo)
2. Adicione filtros para:
   - **endpoint** (para filtrar por endpoint específico)
   - **level** (para filtrar por nível de log)
   - **status_code** (para filtrar por código de status)

3. Clique em **Pin across all apps** para manter os filtros

---

## 📊 Passo 9: Adicionar Visualização de Tabela (Bonus)

Para ver os logs mais recentes:

1. No dashboard, clique em **Edit**
2. Clique em **Create visualization**
3. Selecione **Lens**
4. Configure:
   - Arraste **@timestamp** para Rows
   - Arraste **level** para Rows
   - Arraste **endpoint** para Rows
   - Arraste **message** para Rows
   - Arraste **status_code** para Rows

5. **Save** → Nome: **Recent Logs Table**
6. Adicione ao dashboard
7. Posicione embaixo de tudo (tabela larga)

---

## 🔄 Passo 10: Configurar Auto-Refresh

Para o dashboard atualizar automaticamente:

1. Clique no **relógio** (canto superior direito)
2. Clique em **Refresh every**
3. Selecione: **10 seconds** ou **30 seconds**
4. Clique em **Start**

Agora o dashboard atualizará automaticamente! 🔄

---

## 🎯 Resultado Final

Seu dashboard terá:

✅ **Métricas em Tempo Real:**
- Total de requisições
- Total de erros
- Distribuição de níveis de log

✅ **Gráficos Visuais:**
- Requisições ao longo do tempo (tendências)
- Status codes (distribuição)
- Endpoints mais acessados

✅ **Atualização Automática:**
- Dashboard se atualiza sozinho a cada 10 segundos

✅ **Filtros Interativos:**
- Filtre por endpoint, status, nível

---

## 🚀 Testando o Dashboard

Execute o script de testes para gerar logs:

```powershell
.\test_logging.ps1
```

Aguarde 10-30 segundos e veja o dashboard atualizar automaticamente!

---

## 💡 Dicas Extras

### Criar Alerta para Erros

1. Menu ☰ → **Management** → **Stack Management**
2. **Rules and Connectors** → **Create rule**
3. Configure:
   - Rule type: **Elasticsearch query**
   - Index: **flask-logs-***
   - Query: **level: "ERROR"**
   - Threshold: **count > 5** em 5 minutos
   - Ação: Configurar notificação (email, webhook, etc.)

### Exportar Dashboard

1. Menu ☰ → **Management** → **Stack Management**
2. **Saved Objects**
3. Selecione seu dashboard
4. **Export** → Download do arquivo JSON

### Compartilhar Dashboard

1. Abra o dashboard
2. Clique em **Share**
3. Escolha:
   - **Copy link** (link direto)
   - **Embed code** (incorporar em site)
   - **PDF Reports** (relatórios)

---

## 📚 Recursos Adicionais

### Consultas KQL Úteis

Use estas queries na barra de busca do dashboard:

```
# Apenas erros
level: "ERROR"

# Endpoint específico
endpoint: "/health"

# Status 5xx
status_code >= 500

# Combinações
level: "ERROR" AND endpoint: "/status/*"
```

### Personalizar Cores

1. Clique no painel
2. **Edit visualization**
3. **Panel settings** → **Color**
4. Escolha cores personalizadas

---

## ✅ Checklist Final

- [ ] Index pattern `flask-logs-*` criado
- [ ] 6 visualizações criadas
- [ ] Dashboard criado e organizado
- [ ] Período de tempo configurado (Last 15 minutes)
- [ ] Auto-refresh ativado (10 segundos)
- [ ] Dashboard salvo
- [ ] Testado com `.\test_logging.ps1`
- [ ] Verificado que dados aparecem

---

## 🆘 Troubleshooting

### Não vejo dados no dashboard
1. Verifique o período de tempo (canto superior direito)
2. Execute `.\test_logging.ps1` para gerar logs
3. Aguarde 30 segundos para processamento
4. Clique em **Refresh**

### Visualizações aparecem vazias
1. Verifique se o index pattern está correto
2. Execute: `Invoke-WebRequest -Uri "http://localhost:9200/flask-logs-*/_count"`
3. Se count = 0, gere logs com `.\test_logging.ps1`

### Campos não aparecem
1. Vá em **Management** → **Index Patterns**
2. Selecione `flask-logs-*`
3. Clique em **Refresh field list** (ícone de reload)

---

**Seu dashboard está pronto!** 🎉

Agora você tem um sistema completo de monitoramento em tempo real! 📊
