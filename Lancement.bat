@echo off
chcp 65001 > nul
echo Lancement du convertisseur de CV...
echo.

rem Lancement direct du script PowerShell principal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Lancement_Application.ps1"

echo.
echo Script terminé.
pause