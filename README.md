# SaveThis — Starter scaffold

This repository contains a minimal starter scaffold for the SaveThis group-SMS app.

What's included
- `frontend/` — Vite + React single page app (simple UI to compose messages)
- `backend/` — FastAPI backend with basic endpoints and Twilio wrapper
- `functions/` — Azure Functions skeleton for webhook and queue processing
- `docker-compose.yml` — starts a local Postgres and Adminer for development
- `.env.example` — environment variables to copy to `.env`
- `.github/workflows/ci-cd.yml` — starter CI workflow (placeholders)

Quick start (Windows PowerShell)

1. Copy `.env.example` to `.env` and edit values (at least `DATABASE_URL` and Twilio test creds).

2. Start local Postgres:

```powershell
docker-compose up -d
```

3. Backend (in a new PS window)

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r backend/requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

4. Frontend

```powershell
cd frontend
npm install
npm run dev
```

5. (Optional) Run Azure Functions locally if you have the Core Tools installed:

```powershell
cd functions
func start
```

Notes
- The FastAPI `/api/send` endpoint uses `TWILIO_*` env vars when present; if not present the Twilio client returns a mock response for local development.
- The scaffold is minimal — add migrations, tests, auth, and production configuration before deploying.

Note about domain
- You've registered `slidesms.app`. For staging/production you'll want to:
	- Add DNS entries pointing to your host (App Service IP or CNAME).
	- Configure Cloudflare (optional) for CDN/WAF/TLS and point nameservers to Cloudflare.
	- Set `APP_DOMAIN` and `FRONTEND_BASE_URL` in `.env` (local) and as GitHub Secrets (CI) so deployments use the correct domain.
# slideSMS.app

Project plan and notes for the slideSMS.app group SMS messaging web application.

This repository contains project documentation and planning artifacts.

Files of interest:
- `ProjectSummary.md` — Project plan converted from the original LaTeX file (main documentation).

Quick start:
1. Configure Git (see below).
2. Initialize a local repository and make your first commit.
3. Create a remote repository on GitHub and push.

See the `CONTRIBUTING.md` for suggestions on how to work with this repo.
