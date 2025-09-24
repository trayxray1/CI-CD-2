import json
from app import app


def test_health():
    client = app.test_client()
    resp = client.get('/health')
    assert resp.status_code == 200
    data = json.loads(resp.data)
    assert data['status'] == 'ok'


def test_root():
    client = app.test_client()
    resp = client.get('/')
    assert resp.status_code == 200
    data = json.loads(resp.data)
    assert 'message' in data
