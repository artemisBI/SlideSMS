#!/bin/bash

# Complete full-stack setup and run script for SlideSMS
# This script creates the virtual environment, installs dependencies, and starts both backend and frontend

set -e  # Exit on any error

# Get the project root directory (parent of scripts directory)
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "================================================"
echo "SlideSMS Full Stack Setup & Run"
echo "================================================"
echo ""

# ========================
# BACKEND SETUP
# ========================
echo ">>> BACKEND SETUP <<<"
echo ""

# Navigate to backend directory
cd "$PROJECT_ROOT/backend" || exit 1

# Create virtual environment if it doesn't exist
if [ ! -d ".venv" ]; then
    echo "[1/3] Creating Python virtual environment..."
    py -m venv .venv
    echo "✓ Virtual environment created"
else
    echo "[1/3] Virtual environment already exists, skipping creation"
fi

# Activate virtual environment
echo "[2/3] Activating virtual environment..."
source .venv/Scripts/activate
echo "✓ Virtual environment activated"

# Install dependencies
echo "[3/3] Installing dependencies from requirements.txt..."
pip install -r requirements.txt
echo "✓ Dependencies installed"

echo ""
echo "================================================"
echo "Starting uvicorn server in background..."
echo "================================================"
echo ""
echo "Backend available at: http://localhost:8000"
echo "API documentation at: http://localhost:8000/docs"
echo "ReDoc documentation at: http://localhost:8000/redoc"
echo ""

# Start the uvicorn server in the background
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!
echo "✓ Backend server started (PID: $BACKEND_PID)"
echo ""

# Give the backend a moment to start
sleep 2

# ========================
# FRONTEND SETUP & RUN
# ========================
echo "================================================"
echo "Setting up frontend..."
echo "================================================"
echo ""

# Navigate to frontend directory
cd "$PROJECT_ROOT/frontend" || exit 1

echo "[1/2] Installing frontend dependencies..."
npm install
echo "✓ Frontend dependencies installed"

echo ""
echo "[2/2] Starting frontend dev server..."
echo "================================================"
echo "Starting frontend dev server in foreground..."
echo "================================================"
echo ""
echo "Frontend available at: http://localhost:5173"
echo ""
echo "Press Ctrl+C to stop both servers"
echo ""

# Detect OS and open browser
if command -v start &> /dev/null; then
    # Windows (Git Bash, MINGW, etc.)
    start http://localhost:5173 &
elif command -v open &> /dev/null; then
    # macOS
    open http://localhost:5173 &
elif command -v xdg-open &> /dev/null; then
    # Linux
    xdg-open http://localhost:5173 &
fi

# Start frontend in foreground
npm run dev

# Cleanup: Kill the backend server when frontend exits
kill $BACKEND_PID 2>/dev/null || true
echo ""
echo "Backend server stopped"
