# Project Startup — slideSMS

This file lists the bare-minimum base dependencies and quick setup steps any developer needs to get the SlideSMS project running locally and collaborating (works for different local clients).

Use this as the canonical quick-start for new contributors.

## Purpose / contract
- Inputs: repository checkout, environment variables from `.env` (copy `.env.example`), Docker Desktop access, local dev tools.
- Outputs: running local development environment (Postgres, backend API, frontend dev server, optional Azure Functions runtime) and verification commands to confirm each tool.
- Success criteria: `docker`, `python`, `node`/`npm` and (optionally) `func` & `az` are installed and verified; `docker-compose up -d` starts `db` and `adminer`; backend and frontend can be started per README.

## Minimal required tools (bare minimum)
1. Git (to clone and work with the repository)
2. Docker Desktop (Windows/macOS) or Docker Engine + docker-compose (Linux)
   - On Windows: enable WSL2 backend in Docker Desktop for best experience.
3. Docker Compose (v2 via `docker compose` or legacy `docker-compose`) — repository includes `docker-compose.yml`.
4. Python 3.11 (recommended) — used by `backend/` and `functions/` (project plan mentions Python 3.10/3.11). Install pip.
5. Node.js (LTS — Node 18 or 20 recommended) and npm — used by the `frontend/` (Vite + React).
6. PowerShell (pwsh) on Windows — instructions below use PowerShell commands.

Optional but recommended for contributors working on serverless parts or Azure integration:
7. Azure CLI (`az`) — to manage Azure resources.
8. Azure Functions Core Tools (`func`) — to run the `functions/` project locally.
9. VS Code (or another editor) and recommended extensions (Python, Pylance, ESLint, Prettier, Docker, Azure Tools).
10. Docker Hub account (if you need to push images); Twilio account (for sending real SMS in dev/testing).

## Project-specific runtime packages (installed via package managers)
- Backend Python requirements: install from `backend/requirements.txt` (FastAPI, Uvicorn, SQLAlchemy, psycopg2-binary, python-dotenv, alembic, twilio). Exact file: `backend/requirements.txt`.
- Functions Python requirements: `functions/requirements.txt` (azure-functions, azure-storage-queue, twilio, etc.).
- Frontend Node packages: `frontend/package.json` — run `npm install`.
- Local DB / docker-compose: `docker-compose.yml` starts Postgres 15 (image `postgres:15-alpine`) and Adminer for quick DB UI.

## Environment variables
- Copy `.env.example` → `.env` and fill required values (at minimum: `DATABASE_URL` and Twilio test credentials if you will test SMS sending).
- Typical env names used by the project: `DATABASE_URL`, `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_PHONE_NUMBER`, `APP_DOMAIN`, `FRONTEND_BASE_URL`.

## Quick verification commands (PowerShell)
Run these to confirm the base tools are present (Windows PowerShell / pwsh):

```powershell
# Docker
docker --version
# or when using the compose plugin
docker compose version

# Python
python --version
pip --version

# Node & npm
node --version
npm --version

# (optional) Azure & Functions
az --version
func --version

# Git
git --version
```

If any of these commands fail, install or fix the corresponding tool before proceeding.

## Minimal quick-start (get a dev env running)
Follow these steps from the repository root in PowerShell (Windows) or your shell on macOS/Linux. Adapt path syntax for your shell.

1) Clone repo (if not already):

```powershell
git clone <repo-url>
cd SlideSMS
```

2) Copy environment file and edit values:

```powershell
copy .env.example .env
# Edit .env in your editor and fill DATABASE_URL and TWILIO_* values
```

3) Start local Postgres and Adminer (docker-compose):

```powershell
docker compose up -d
# Confirm containers
docker compose ps
```

4) Backend (Python)

```powershell
# Create virtualenv and activate
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r backend/requirements.txt
# Run the backend (dev)
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

5) Frontend (Node)

```powershell
cd frontend
npm install
npm run dev
```

6) (Optional) Azure Functions locally

```powershell
cd functions
pip install -r requirements.txt
func start
```

7) Verify the app endpoints
- Backend health: open `http://localhost:8000/health` (or the backend's health endpoint).
- Adminer DB UI: `http://localhost:8080` (username/password from `docker-compose.yml` defaults: `postgres` / `postgres`).
- Frontend dev server: follow `npm run dev` output (usually `http://localhost:5173`).

## Notes for Windows (WSL2 / Docker Desktop)
- Install Docker Desktop for Windows from https://www.docker.com/products/docker-desktop and enable WSL2 integration during setup.
- If using WSL2, open the project in your WSL distro or use the Windows path; ensure Docker resources (CPU/memory) allocation is adequate for Postgres.
- Run PowerShell as Administrator when installing tools if prompted.

## Cross-platform differences
- macOS/Linux: install Docker Engine and docker-compose (or use Docker Desktop on macOS). Virtualenv activation differs: `source .venv/bin/activate`.
- Windows PowerShell activation uses `.\.venv\Scripts\Activate.ps1`.

## Short checklist for new devs (summary)
- [ ] Git installed and configured
- [ ] Docker Desktop (Windows/macOS) or Docker Engine + compose (Linux)
- [ ] Python 3.11 + pip
- [ ] Node 18+ and npm
- [ ] Copy `.env.example` -> `.env` and set secrets locally
- [ ] Run `docker compose up -d` and verify db & adminer
- [ ] pip install `backend/requirements.txt` and `functions/requirements.txt` (if developing functions)
- [ ] npm install in `frontend/`

## Common troubleshooting tips
- If ports (5432, 8000, 5173, 8080) are in use, stop the conflicting processes or change ports in `docker-compose.yml` / run commands.
- If `psycopg2-binary` install fails on your machine, ensure build tools are installed (Windows: use wheels; Linux: install libpq-dev & python-dev packages) — the project uses `psycopg2-binary` which should usually install without system packages, but native builds sometimes need system dependencies.
- If Docker on Windows reports WSL-related issues, ensure WSL2 is installed and set as default (`wsl --install`) and that Docker Desktop integration is enabled.

## Next steps / optional tools for productivity
- VS Code with extensions: Python, Pylance, Docker, ESLint, Prettier, Remote - WSL (if using WSL2), Azure Tools.
- Install Twilio CLI (optional) to test SMS sending and inspect messages.
- Create a Docker Hub account for pushing images if you'll be building/publishing images.

---

If you'd like, I can also:
- Add this file to `docs/` instead of repo root, or update the `README.md` to link to it.
- Create a small script `scripts/dev-setup.ps1` to automate common steps (env copying, venv creation, docker compose up). Ask and I'll add it.

Completed: created `ProjectStartup.md` and included verification steps and quick-start commands for PowerShell and other shells.