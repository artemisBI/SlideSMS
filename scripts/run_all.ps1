# Complete full-stack setup and run script for SlideSMS
$ErrorActionPreference = "Stop"

# --- CONFIGURATION ---
$ProjectRoot = Resolve-Path "$PSScriptRoot\.."
$BackendDir  = "$ProjectRoot\backend"
$FrontendDir = "$ProjectRoot\frontend"
$VenvPath    = "$BackendDir\.venv"
$PythonExe   = "$VenvPath\Scripts\python.exe"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "SlideSMS Full Stack Setup & Run" -ForegroundColor Cyan
Write-Host "================================================"
Write-Host ""

# ========================
# 1. BACKEND SETUP
# ========================
Write-Host ">>> BACKEND SETUP <<<" -ForegroundColor Green
Set-Location $BackendDir

# --- Step 1: Determine Python Command ---
# We check this first to avoid nesting 'if' blocks later
$PyCmd = "python"
if (Get-Command py -ErrorAction SilentlyContinue) {
    $PyCmd = "py"
}

if (-not (Test-Path $VenvPath)) {
    Write-Host "Creating venv..."
    & $PyCmd -m venv .venv
    Write-Host ([char]0x2713 + " Virtual environment created") -ForegroundColor Green
}

if (Test-Path $VenvPath) {
    Write-Host "[1/3] Virtual environment exists."
} else {
    Write-Error "Failed to create virtual environment at $VenvPath"
}

# --- Step 3: Verify Python Executable ---
if (-not (Test-Path $PythonExe)) {
    Write-Error "Could not find python executable at $PythonExe. Please check your python installation."
}

# --- Step 4: Install Dependencies ---
Write-Host "[2/3] Installing dependencies from requirements.txt..."
& $PythonExe -m pip install -r requirements.txt
Write-Host ([char]0x2713 + "Dependencies installed") -ForegroundColor Green

# --- Step 5: Start Backend ---
Write-Host ""
Write-Host "================================================"
Write-Host "Starting uvicorn server in background..."
Write-Host "================================================"
Write-Host ""
Write-Host "Backend available at: http://localhost:8000"
Write-Host "API documentation at: http://localhost:8000/docs"
Write-Host "ReDoc documentation at: http://localhost:8000/redoc"
Write-Host ""

# Start the uvicorn server in the background
# FIX APPLIED: Added -WorkingDirectory so uvicorn finds the 'app' module
$BackendProcess = Start-Process -FilePath $PythonExe `
    -ArgumentList "-m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000" `
    -WorkingDirectory $BackendDir `
    -PassThru `
    -NoNewWindow

Write-Host ([char]0x2713 + " Backend server started (PID: $($BackendProcess.Id))") -ForegroundColor Green
Write-Host ""

# Give the backend a moment to start
Start-Sleep -Seconds 2

# ========================
# 2. FRONTEND SETUP & RUN
# ========================
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Setting up frontend..." -ForegroundColor Cyan
Write-Host "================================================"
Write-Host ""

# Navigate to frontend directory
Set-Location $FrontendDir

Write-Host "[1/2] Installing frontend dependencies..."
npm install
Write-Host ([char]0x2713 + " Frontend dependencies installed") -ForegroundColor Green

Write-Host ""
Write-Host "[2/2] Starting frontend dev server..."
Write-Host "================================================"
Write-Host "Starting frontend dev server in foreground..."
Write-Host "================================================"
Write-Host ""
Write-Host "Frontend available at: http://localhost:5173"
Write-Host ""
Write-Host "Press Ctrl+C to stop both servers" -ForegroundColor Yellow
Write-Host ""

# Open Browser
Start-Process "http://localhost:5173"

# Start frontend in foreground inside a Try/Finally block
try {
    npm run dev
} finally {
    Write-Host ""
    Write-Host "Stopping backend server (PID: $($BackendProcess.Id))..." -ForegroundColor Yellow
    Stop-Process -Id $BackendProcess.Id -ErrorAction SilentlyContinue
    Write-Host ([char]0x2713 + " Backend server stopped.") -ForegroundColor Green
    Set-Location $ProjectRoot
}