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

---

## 📁 Project Structure

```

app/
├── api/                # API layer (versioned)
│   └── v1/
│       ├── routes/     # Endpoints (chat, health, leads)
│       └── router.py   # Route aggregation
├── main.py             # FastAPI entrypoint

tests/                  # Unit & integration tests

infra/                  # Deployment (Docker, Cloud Run)
├── docker/
│   ├── Dockerfile
│   └── .dockerignore
├── scripts/
│   ├── build.sh
│   └── deploy.sh

```

---

## ⚡ Getting Started

### 1. Install dependencies

```bash
make install
```

### 2. Run the API

```bash
make dev
```

API will be available at:

- [http://127.0.0.1:8000](http://127.0.0.1:8000)
- Swagger UI: [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)

---

## 🧪 API Endpoints

### Healthcheck

```http
GET /api/v1/health
```

Used for monitoring and Cloud Run readiness checks.

---

### Chat (AI entrypoint)

```http
POST /api/v1/chat
```

Example request:

```json
{
  "message": "Je veux refaire ma salle de bain"
}
```

This endpoint will eventually:

- orchestrate the LLM agent
- qualify the project
- estimate pricing
- extract structured lead data

---

### Leads

```http
GET /api/v1/leads
```

Returns extracted leads (placeholder for now).

---

## 🛠️ Development

### Run API

```bash
make dev
```

### Lint & Format (auto-fix)

```bash
make lint
```

### CI-style checks (no modifications)

```bash
make check
```

### Run tests

```bash
make test
```

---

## 🐳 Docker

### Build image

```bash
make docker-build
```

### Run container locally

```bash
make docker-run
```

App will be available at:

- [http://localhost:8080](http://localhost:8080)

---

## ☁️ Deployment (Cloud Run)

### Build & push image

```bash
bash infra/scripts/build.sh <PROJECT_ID>
```

### Deploy service

```bash
bash infra/scripts/deploy.sh <PROJECT_ID>
```

---

## 🧠 Roadmap

- [ ] LLM agent integration (Gemini / OpenAI)
- [ ] Structured lead extraction
- [ ] Pricing engine (rule-based + AI)
- [ ] Conversation state management
- [ ] CRM integration
- [ ] Cloud Run production setup (env vars, secrets)
- [ ] Evaluation pipeline (LLM evals)

---

## 📌 Design Notes

- API is versioned (`/api/v1`) to support non-breaking evolution
- Clear separation between:
  - API layer
  - domain logic (future)
  - LLM orchestration (future)

- Designed for production deployment on Cloud Run

---

## 📄 License

MIT
