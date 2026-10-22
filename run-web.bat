@echo off
echo Starting TripBuddy Web UI on http://localhost:5173 ...
cd /d "%~dp0web-ui"
pnpm dev
