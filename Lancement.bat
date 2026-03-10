@echo off
rem Fichier Lancement.bat : lance le script PowerShell Lancement_Application.ps1
rem - mode console large
rem - couleurs affichage
rem - puis pause finale pour éviter fermeture brute
mode con: cols=100 lines=35
color 1f

echo ================================================================
echo = Lancement de l'application CV_AI_Transformeur =
echo ================================================================

echo.

echo En cours : execution du script PowerShell principal

echo.

rem Lancement du script PS1 qui ouvre le GUI
powershell.exe -NoProfile -ExecutionPolicy Bypass -NoExit -File "%~dp0Lancement_Application.ps1"

echo.
echo Appuyez sur une touche pour fermer...
pause > nul
exit /b 0