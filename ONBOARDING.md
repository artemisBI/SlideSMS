# Onboarding Checklist — slideSMS (brief)

A short checklist for getting a new developer up and productive quickly.

## Accounts & service access
- [ ] GitHub account with access to the repository (ask repo admin to add collaborator or grant org access).
- [ ] Docker Hub account (optional, only if you will push images).
- [ ] Twilio account (trial is sufficient for initial dev/testing) — collect `TWILIO_ACCOUNT_SID` and `TWILIO_AUTH_TOKEN`.
- [ ] Azure subscription access (if you will deploy or manage infrastructure) — request Reader/Contributor role on the resource group used by the project.

## Local tools to install (minimum)
- Git
- Docker Desktop (Windows/macOS) or Docker Engine + docker-compose (Linux)
- Python 3.11 (pip available)
- Node.js (LTS, Node 18/20) and npm
- PowerShell / pwsh (Windows) or a POSIX shell on macOS/Linux

## Repo & secrets setup
- [ ] Clone the repository
- [ ] Copy `.env.example` → `.env` and fill required values (DATABASE_URL, TWILIO_*, APP_DOMAIN, etc.)
- [ ] Store production secrets in Azure Key Vault and CI secrets in GitHub Secrets (ask the repo admin for required secret names/values)

## Local run & verification (happy path)
1. From repo root: run `scripts\dev-setup.ps1` (Windows PowerShell) — this will copy `.env`, create a venv, install requirements, start docker-compose, and install frontend deps.
2. Confirm containers: `docker compose ps` and Adminer at `http://localhost:8080`.
3. Start backend: activate venv and run `uvicorn app.main:app --reload --host 0.0.0.0 --port 8000`.
4. Start frontend: `cd frontend` → `npm run dev` and open the dev URL reported by Vite.

## Repo workflow & policies (short)
- Use feature branches named `feature/<short-description>` or `fix/<issue>`.
- Open a Pull Request targeting `main` and request at least one reviewer before merging.
- Run unit tests / linters locally where available before pushing. CI will run tests on PRs.
- Protect `main` branch (admins) and avoid pushing credentials to the repo.

## Useful contacts
- Repo owner / maintainer: ask your team lead for the primary contact.
- For Azure infra and secrets: contact the person/team who manages the Azure subscription (owner listed in project docs).
- For Twilio/test phone numbers: contact whoever holds the Twilio account credentials.

## First PR suggestion
- Pick a small task: fix a typo in docs, add a README note, or add a simple unit test. This helps set up your dev environment and checks CI access.

---

If you'd like, I can:
- Add the onboarding checklist to `README.md` (link) and add a short developer badge/status.
- Add a GitHub Actions workflow template for running the dev-setup checks in CI (lightweight smoke tests).
