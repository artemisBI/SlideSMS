# SaveThis — Savepoint (scaffold created)

Date: 2025-11-08

This file is a snapshot/savepoint describing the scaffold I just added to the workspace. Use this as a reference while you take a break — it lists what was created, how to run locally, and suggested next steps.

Domain registered: slidesms.app — registered on 2025-11-08. Recommended immediate actions:
- Add/register nameservers at your registrar (or transfer DNS to Cloudflare) and enable Cloudflare for CDN/WAF/TLS if desired.
- Create DNS records (A or CNAME) for your frontend/API hosting and any verification TXT records Twilio requires for webhooks.
- Update `APP_DOMAIN` and `FRONTEND_BASE_URL` in `.env` and add the domain to GitHub Secrets for CI/CD.

## What was added
- `backend/` — FastAPI backend
  - `requirements.txt` — dependencies (FastAPI, Uvicorn, SQLAlchemy, psycopg2, Alembic, Twilio)
  - `app/main.py` — FastAPI application and router registration
  - `app/api/health.py` — /health endpoint
  - `app/api/send.py` — /api/send endpoint (message + recipients)
  - `app/twilio_client.py` — Twilio wrapper (uses env vars or returns mock responses for local dev)
  - `app/models.py` — SQLAlchemy models matching ProjectPlan schema
  - `Dockerfile` — containerize the backend

- `frontend/` — Vite + React app (minimal UI)
  - `package.json`, `index.html`, `src/main.jsx`, `src/App.jsx`, `src/styles.css`
  - `Dockerfile` — build frontend and serve via nginx

- `functions/` — Azure Functions skeleton
  - `host.json`
  - `TwilioWebhookFunction` — HTTP trigger placeholder
  - `QueueProcessorFunction` — queue trigger placeholder

- Project-level
  - `docker-compose.yml` — local Postgres (and Adminer) for development
  - `.env.example` — example env variables to copy to `.env`
  - `README.md` — quick-start instructions (PowerShell examples)
  - `.gitignore`
  - `.github/workflows/ci-cd.yml` — CI template with placeholders

## Quick local run (PowerShell)

1) Copy environment example and edit values:

```powershell
Copy-Item .env.example .env
# Edit .env with your editor and fill DATABASE_URL and Twilio creds when ready
```

2) Start local Postgres and Adminer with Docker Compose:

```powershell
docker-compose up -d
```

3) Backend (new PS window)

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r backend/requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

4) Frontend

```powershell
cd frontend
npm install
npm run dev
```

5) Optional: Run Azure Functions locally (if you have Azure Functions Core Tools)

```powershell
cd functions
func start
```

6) Test sending

POST to `http://localhost:8000/api/send` with JSON body such as:

```json
{
  "message": "Hello from SaveThis",
  "recipients": ["+15555550123"]
}
```

Notes:
- If Twilio environment variables are not set, the `send` endpoint returns a mocked response so you can test without Twilio credentials.
- To send real SMS, create a Twilio account, get `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, and a `TWILIO_FROM_NUMBER`, then add them to `.env` (or GitHub secrets for CI).

## Next recommended steps (pick one)
1. Add DB migrations + helper script to create tables from SQLAlchemy models (Alembic integration).
2. Add JWT-based authentication and protect the `send` endpoint.
3. Implement CI to build/push images to Docker Hub (requires DOCKERHUB credentials as secrets).
4. Provision Azure resources (Azure Database for PostgreSQL, Azure Functions, App Service) with Terraform/ARM and add deployment steps.

## Where to find things
- Project root: `SAVEPOINT.md`, `README.md`, `docker-compose.yml`, `.env.example`
- Backend: `backend/app/` (main.py, api/health.py, api/send.py, twilio_client.py, models.py)
- Frontend: `frontend/` (Vite + React files)
- Functions: `functions/` (Azure Functions skeleton)

## Safety & next actions before deployment
- Do not commit secrets to git. Use `.env` locally and GitHub secrets for CI.
- Test Twilio with trial/test credentials first.
- Add rate-limiting and compliance features (opt-in, unsubscribe) before sending bulk messages.

If you want, I can now implement one of the "Next recommended steps" — tell me which and I'll continue iterating when you're ready.
