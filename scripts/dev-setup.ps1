<#
PowerShell dev setup helper for SlideSMS
This script performs idempotent, minimal local setup steps for Windows PowerShell (pwsh).
It does NOT change remote systems or push images.
Usage: run from repo root in pwsh: `scripts\dev-setup.ps1` or `.\scripts\dev-setup.ps1`
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Ok($msg){ Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Note($msg){ Write-Host "[NOTE] $msg" -ForegroundColor Cyan }
function Write-Err($msg){ Write-Host "[ERROR] $msg" -ForegroundColor Red }

# Ensure script runs from repository root (where this script lives in scripts/)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Push-Location $scriptDir\.. | Out-Null

Write-Host "Running dev setup from: $(Get-Location)"

# 1) Copy .env.example to .env if needed
if (-Not (Test-Path .env.example)) {
    Write-Err ".env.example not found in repo root. Please create or restore it before continuing."
    Pop-Location
    exit 1
}

if (-Not (Test-Path .env)) {
    Copy-Item .env.example .env
    Write-Ok "Copied .env.example -> .env"
} else {
    Write-Note ".env already exists — skipping copy"
}

# 2) Ensure Python available
if (-Not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Err "Python not found on PATH. Please install Python 3.11+ and try again."
    Pop-Location
    exit 1
}

# create venv if missing
if (-Not (Test-Path .venv)) {
    Write-Host "Creating virtual environment at .venv..."
    python -m venv .venv
    Write-Ok "Virtual environment created"
} else {
    Write-Note "Virtual environment .venv already exists"
}

# Use the venv pip executable directly to avoid activation issues
$pipPath = Join-Path (Join-Path (Get-Location) '.venv') 'Scripts\pip.exe'
if (-Not (Test-Path $pipPath)) {
    Write-Err "pip executable not found in venv. Check your Python installation or recreate the venv."
    Pop-Location
    exit 1
}

# 3) Install backend requirements
$backendReq = 'backend\requirements.txt'
if (Test-Path $backendReq) {
    Write-Host "Installing backend Python requirements..."
    & $pipPath install -r $backendReq
    Write-Ok "Backend requirements installed"
} else {
    Write-Note "$backendReq not found — skipping backend pip install"
}

# 4) Install functions requirements (optional)
$funcReq = 'functions\requirements.txt'
if (Test-Path $funcReq) {
    Write-Host "Installing Azure Functions Python requirements (functions)..."
    & $pipPath install -r $funcReq
    Write-Ok "Functions requirements installed"
} else {
    Write-Note "$funcReq not found — skipping functions pip install"
}

# 5) Start docker-compose services
if (-Not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Err "Docker not found on PATH. Please install Docker Desktop (Windows) or Docker Engine and docker-compose."
    Pop-Location
    exit 1
}

Write-Host "Bringing up Docker services (docker compose up -d)..."
# Prefer plugin-style `docker compose` if present
$composeCmd = if (Get-Command 'docker' | ForEach-Object { $_.Source } ) { 'docker compose' } else { 'docker-compose' }
try {
    & docker compose up -d
    Write-Ok "Docker compose services started (db, adminer)"
} catch {
    Write-Err "docker compose up failed: $_"
}

# 6) Frontend npm install
if (Test-Path 'frontend') {
    if (-Not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Note "npm not found — skipping frontend install. Install Node.js and run 'npm install' in frontend/ when ready."
    } else {
        Push-Location frontend
        Write-Host "Installing frontend dependencies..."
        npm ci 2>$null || npm install
        Write-Ok "Frontend dependencies installed"
        Pop-Location
    }
} else {
    Write-Note "frontend/ not present — skipping frontend install"
}

# 7) Final notes
Write-Host "\nDev setup finished. Next steps:"
Write-Host " - Activate the virtualenv: .\\.venv\\Scripts\\Activate.ps1"
Write-Host " - Start backend (from repo root): uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"
Write-Host " - Start frontend (from frontend/): npm run dev"
Write-Host " - Check Adminer at http://localhost:8080 and backend health at http://localhost:8000/health (if implemented)"

Pop-Location

Exit 0
