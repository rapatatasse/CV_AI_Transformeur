@echo off
mode con: cols=100 lines=35
color 1f

echo ================================================================
echo = Lancement de l'application CV_AI_Transformeur =
echo ================================================================

echo.

echo En cours : execution du script PowerShell principal

echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -NoExit -File "%~dp0Lancement_Application.ps1"

echo.
echo Appuyez sur une touche pour fermer...
pause > nul
exit /b 0