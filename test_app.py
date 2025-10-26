# -*- coding: utf-8 -*-
import pytest
import json
from app import app as flask_app

@pytest.fixture
def app():
    yield flask_app

@pytest.fixture
def client(app):
    return app.test_client()

def test_home(client):
    """Testa o endpoint principal."""
    res = client.get('/')
    data = json.loads(res.data) # Decodifica o JSON
    assert res.status_code == 200
    assert "Olá! Aplicação de exemplo" in data["message"] # Verifica dentro da chave "message"

def test_health_check(client):
    """Testa o endpoint de health check."""
    res = client.get('/health')
    assert res.status_code == 200
    assert res.data == b"OK"

def test_status_code_valid(client):
    """Testa o endpoint de status com um código válido."""
    res = client.get('/status/404')
    assert res.status_code == 404

def test_status_code_invalid(client):
    """Testa o endpoint de status com um código inválido."""
    res = client.get('/status/999')
    data = json.loads(res.data) # Decodifica o JSON
    assert res.status_code == 400
    assert "inválido" in data["error"] # Verifica dentro da chave "error"

