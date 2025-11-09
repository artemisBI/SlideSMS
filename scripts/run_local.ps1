# PowerShell helper to run services locally
Write-Host "Starting local Postgres (docker-compose)..."
docker-compose up -d

Write-Host "To run the backend: \n  python -m venv .venv; .\.venv\Scripts\Activate.ps1; pip install -r backend/requirements.txt; uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"

Write-Host "To run the frontend: \n  cd frontend; npm install; npm run dev"
