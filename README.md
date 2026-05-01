# Reno Agent

AI-powered backend for renovation price estimation and lead qualification.

This project provides a FastAPI-based backend designed to:

- estimate renovation costs (e.g. bathroom renovation)
- qualify user projects through a conversational interface
- extract structured leads from user interactions

---

## 🚀 Tech Stack

- **FastAPI** — API framework
- **Pydantic** — data validation & schemas
- **Uvicorn** — ASGI server
- **uv** — package & environment management
- **Ruff** — linting & formatting
- **Pytest** — testing
- **LiteLLM** — unified LLM provider interface
- **Google Vertex AI** — Gemini model hosting
- **Cloud Run** — serverless deployment
- **Artifact Registry** — Docker image registry

---

## 📁 Project Structure

```

app/
├── api/
│   └── v1/
│       ├── routes/
│       └── router.py
├── llm/                # LLM client & agent logic
├── core/               # Config & settings
├── main.py

infra/
├── scripts/
│   ├── build.sh
│   ├── deploy.sh
│   └── setup_iam.sh

env/
├── dev.env
├── prod.env

tests/
Dockerfile

```

---

## ⚡ Getting Started

### Install dependencies

```bash
make install
```

### Run the API

```bash
make dev
```

- API: [http://127.0.0.1:8000](http://127.0.0.1:8000)
- Docs: [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)

---

## 🧪 API Endpoints

### Healthcheck

```http
GET /api/v1/health
```

---

### Chat (LLM entrypoint)

```http
POST /api/v1/chat
```

Example:

```json
{
  "message": "Je veux refaire ma salle de bain"
}
```

---

### Leads

Currently returns a placeholder response. Lead persistence will be implemented after structured extraction.

```http
GET /api/v1/leads
```

---

## 🛠️ Development

```bash
make dev
make lint
make check
make test
```

---

## 🐳 Docker

```bash
make docker-build
make docker-run
```

App runs on [http://localhost:8080](http://localhost:8080)

---

## ☁️ Deployment (Cloud Run)

### Environment config

Stored in:

```
env/dev.env
env/prod.env
```

---

### 1. Setup IAM (one-time)

```bash
make setup-iam-dev
make setup-iam-prod
```

---

### 2. Deploy

```bash
make deploy-dev
make deploy-prod
```

---

## 🧠 Roadmap

- [x] FastAPI backend scaffold

- [x] Cloud Run deployment

- [x] LLM integration (LiteLLM + Vertex AI)

- [x] Environment-based configuration

- [x] IAM setup for Cloud Run → Vertex AI

- [ ] Structured lead extraction

- [ ] Pricing engine (rule-based + AI)

- [ ] Conversation memory

- [ ] CRM integration

- [ ] Secret Manager integration

- [ ] LLM evaluation pipeline

- [ ] Terraform infrastructure

---

## 📌 Design Notes

- Versioned API (`/api/v1`)

- Clean separation:
  - API layer
  - LLM orchestration
  - Config

- Production-ready Cloud Run deployment

---

## 📄 License

MIT
