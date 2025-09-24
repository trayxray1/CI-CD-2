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

Дальше: могу инициализировать git, закоммитить файлы в репозиторий, создать ветку `main`, или добавить пример deploy (Docker Compose / k8s + ArgoCD). Выберите следующий шаг.