# Usar uma imagem base oficial do Python
FROM python:3.9-slim

# Definir o diretório de trabalho no container
WORKDIR /app

# Copiar os arquivos de dependências
COPY requirements.txt .

# Instalar as dependências
RUN pip install --no-cache-dir -r requirements.txt

# Copiar o código da aplicação para o diretório de trabalho
COPY . .

# Expor a porta que a aplicação vai rodar
EXPOSE 5000

# Comando para executar a aplicação
CMD ["flask", "run", "--host=0.0.0.0"]
