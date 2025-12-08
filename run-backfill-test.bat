@echo off
cd /d "%~dp0"
timeout /t 2 /nobreak > nul
npx tsx test-backfill.ts
pause
