Write-Host "Starting TripBuddy Web UI on http://localhost:5173 ..." -ForegroundColor Cyan
Set-Location -Path "$PSScriptRoot\web-ui"
pnpm dev
