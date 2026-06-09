@echo off
rem AWS-SpeedTest
rem Copyright (C) 2026 AWS-SpeedTest contributors
rem SPDX-License-Identifier: GPL-3.0-only

chcp 65001 >nul
setlocal
cd /d "%~dp0"

echo ========================================
echo Amazon speed test and hosts update tool
echo ========================================
echo.

net session >nul 2>&1
if errorlevel 1 (
    echo Administrator permission is required.
    echo Please click Yes in the system prompt.
    "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -WorkingDirectory '%~dp0' -Verb RunAs"
    exit /b
)

if not exist "update-host.ps1" (
    echo Error: update-host.ps1 was not found.
    echo Please keep this bat file and update-host.ps1 in the same folder.
    echo.
    pause
    exit /b 1
)

"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0update-host.ps1"

echo.
pause
