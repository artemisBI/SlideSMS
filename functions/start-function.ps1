# Kill any existing func.exe processes
Get-Process func -ErrorAction SilentlyContinue | Stop-Process -Force

# Clear any existing Azure Functions host logs
$logPath = "$env:TEMP\LogFiles\Application\Functions\Host"
if (Test-Path $logPath) {
    Remove-Item -Path "$logPath\*" -Recurse -Force
}

# Activate virtual environment
. .\.venv\Scripts\Activate.ps1

# Start Function host with increased logging
$env:AZURE_FUNCTIONS_ENVIRONMENT = "Development"
$env:Functions_Worker_Runtime = "python"
func start --verbose --port 7071