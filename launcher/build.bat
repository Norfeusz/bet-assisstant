@echo off
echo ================================
echo Building Bet Assistant Launcher
echo ================================
echo.

cd launcher

echo Building main launcher...
go build -o bet-assistant.exe main.go
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to build main launcher
    pause
    exit /b 1
)
echo ✓ bet-assistant.exe created

echo.
echo Building worker launcher...
go build -o bet-assistant-worker.exe worker-main.go
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to build worker launcher
    pause
    exit /b 1
)
echo ✓ bet-assistant-worker.exe created

echo.
echo ================================
echo Build completed successfully!
echo ================================
echo.
echo Files created:
dir /B *.exe
echo.
pause
