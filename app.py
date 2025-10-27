from flask import Flask, jsonify, abort, request
import logging
import json
from datetime import datetime
import sys

# Configuração de logging estruturado em JSON
class JsonFormatter(logging.Formatter):
    """Formata logs em JSON para melhor integração com ELK Stack"""
    def format(self, record):
        log_data = {
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'level': record.levelname,
            'logger': record.name,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line': record.lineno
        }
        
        # Adiciona informações extras se existirem
        if hasattr(record, 'endpoint'):
            log_data['endpoint'] = record.endpoint
        if hasattr(record, 'status_code'):
            log_data['status_code'] = record.status_code
        if hasattr(record, 'method'):
            log_data['method'] = record.method
        if hasattr(record, 'ip'):
            log_data['ip'] = record.ip
            
        return json.dumps(log_data)

# Configurar handler para STDOUT
handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(JsonFormatter())

# Configurar logger da aplicação
logger = logging.getLogger('flask_app')
logger.setLevel(logging.INFO)
logger.addHandler(handler)

# Desabilitar logs duplicados do werkzeug
logging.getLogger('werkzeug').disabled = True

app = Flask(__name__)

@app.before_request
def log_request():
    """Log de todas as requisições recebidas"""
    logger.info(
        f"Request received: {request.method} {request.path}",
        extra={
            'endpoint': request.path,
            'method': request.method,
            'ip': request.remote_addr
        }
    )

@app.route('/')
def home():
    """Endpoint principal que retorna uma mensagem de boas-vindas."""
    logger.info(
        "Endpoint principal acessado com sucesso",
        extra={'endpoint': '/', 'status_code': 200, 'method': 'GET'}
    )
    return jsonify({"message": "Olá! Aplicação de exemplo para o projeto DevOps."})

@app.route('/health')
def health_check():
    """Endpoint de verificação de saúde."""
    logger.info(
        "Health check executado",
        extra={'endpoint': '/health', 'status_code': 200, 'method': 'GET'}
    )
    return jsonify({"status": "UP"}), 200

@app.route('/status/<int:code>')
def random_status(code):
    """
    Endpoint que retorna um status code HTTP específico.
    Útil para testar monitoramento.
    """
    if 100 <= code < 600:
        logger.warning(
            f"Retornando status code forçado: {code}",
            extra={'endpoint': f'/status/{code}', 'status_code': code, 'method': 'GET'}
        )
        abort(code)
    else:
        logger.error(
            f"Tentativa de usar status code inválido: {code}",
            extra={'endpoint': f'/status/{code}', 'status_code': 400, 'method': 'GET'}
        )
        return jsonify({"error": "Status code inválido."}), 400

@app.errorhandler(404)
def not_found(error):
    logger.warning(
        "Recurso não encontrado",
        extra={'status_code': 404, 'endpoint': request.path, 'method': request.method}
    )
    return jsonify({"error": "Não encontrado", "message": "O recurso solicitado não existe."}), 404

@app.errorhandler(500)
def internal_error(error):
    logger.error(
        "Erro interno do servidor",
        extra={'status_code': 500, 'endpoint': request.path, 'method': request.method}
    )
    return jsonify({"error": "Erro interno do servidor", "message": "Ocorreu um erro inesperado."}), 500


if __name__ == '__main__':
    logger.info("Iniciando aplicação Flask", extra={'status_code': 0, 'endpoint': 'startup'})
    app.run(host='0.0.0.0', port=5000)
