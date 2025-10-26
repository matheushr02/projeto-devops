from flask import Flask, jsonify, abort
import random
import logging

# Configuração básica de logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

app = Flask(__name__)

@app.route('/')
def home():
    """Endpoint principal que retorna uma mensagem de boas-vindas."""
    app.logger.info("Acessado o endpoint principal /")
    return jsonify({"message": "Olá! Aplicação de exemplo para o projeto DevOps."})

@app.route('/health')
def health_check():
    """Endpoint de verificação de saúde."""
    app.logger.info("Health check solicitado.")
    return jsonify({"status": "UP"}), 200

@app.route('/status/<int:code>')
def random_status(code):
    """
    Endpoint que retorna um status code HTTP específico.
    Útil para testar monitoramento.
    """
    if 100 <= code < 600:
        app.logger.warning(f"Retornando status code forçado: {code}")
        abort(code)
    else:
        app.logger.error(f"Tentativa de usar um status code inválido: {code}")
        return jsonify({"error": "Status code inválido."}), 400

@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Não encontrado", "message": "O recurso solicitado não existe."}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({"error": "Erro interno do servidor", "message": "Ocorreu um erro inesperado."}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
