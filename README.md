# DevOps CI/CD Pet Project

Простой pet‑проект для демонстрации CI/CD: микросервис на Python (Flask), unit‑tests (pytest), Dockerfile и GitHub Actions pipeline, который запускает тесты, собирает контейнер и пушит в GitHub Container Registry (GHCR).

Цели:
- Показать CI‑пайплайн: тесты → сборка → push image
- Легко расширять (добавить deploy, Helm, ArgoCD и т.д.)

Структура репозитория:

- `app/` — приложение Flask
- `tests/` — pytest тесты
- `.github/workflows/ci.yml` — GitHub Actions workflow
- `Dockerfile` — образ приложения

Как запустить локально (PowerShell):

```powershell
# Перейти в папку приложения
cd .\app

# Установить зависимости (лучше в venv)
python -m venv .venv; .\.venv\Scripts\Activate.ps1
pip install -r requirements.txt

# Запустить приложение
python app.py
# Затем открыть http://localhost:8080

# Запустить тесты
pytest -q
```

Как работает CI (`.github/workflows/ci.yml`):
- На `push` и `pull_request` по ветке `main` запускается workflow
- Шаг `test` устанавливает зависимости и запускает `pytest`
- При успехе запускается `build-and-push`, который собирает Docker image и пушит в GHCR

Настройка для push в GHCR (если нужно):
- По умолчанию workflow использует `GITHUB_TOKEN` и даёт права `packages: write`.
- Если вы хотите использовать Docker Hub, в workflow замените шаг логина на DockerHub и добавьте секреты `DOCKERHUB_USERNAME` и `DOCKERHUB_PASSWORD`.

Deploy
------
В workflow добавлен job `deploy`, который копирует `docker-compose.yml` на удалённый сервер и выполняет `docker-compose pull && docker-compose up -d`.

Требования к серверу (удалённому хосту):
- Docker установлен
- docker-compose (или Docker Compose plugin) установлен
- Пользователь с правами на запуск docker (или использование sudo)

Необходимые секреты в GitHub репозитории (Settings → Secrets → Actions):
- `DEPLOY_HOST` — IP или хостнейм сервера
- `DEPLOY_USER` — пользователь для SSH
- `DEPLOY_PATH` — целевая директория на сервере (например `/home/ubuntu/app`)
- `DEPLOY_SSH_KEY` — приватный SSH ключ (формат PEM) для доступа к серверу

Как подготовить и запустить деплой вручную (PowerShell):

```powershell
# На сервере установите Docker и docker-compose
# Скопируйте публичный ключ в ~/.ssh/authorized_keys для пользователя

# После добавления секретов в GitHub — пуш в main запустит workflow и, при наличии секретов, выполнит deploy автоматически.
```
