@echo off
title Assistant de Configuration Pro - Projet CV
:: Force le script a se positionner dans le dossier ou il est stocke
pushd "%~dp0"

:: ------------------------------------------------------------------------------
:: ANALYSE DES PRIVILÈGES ET ÉLÉVATION DE DROITS
:: ------------------------------------------------------------------------------
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Droits administrateur valides.
) else (
    echo.
    echo [!] Ce script necessite des privileges Administrateur.
    echo [!] Relancement automatique avec elevation des droits...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: ------------------------------------------------------------------------------
:: RESOLUTION DE L'ERREUR CONFIGURATION : ACTIVATION DES CHEMINS LONGS
:: ------------------------------------------------------------------------------
echo [Configuration] Activation du support des chemins longs (Registry)...
reg add "HKLM\System\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d 1 /f >nul 2>&1

:: ------------------------------------------------------------------------------
:: CONFIGURATION DE LA POLITIQUE D'EXECUTION POWERSHELL ET LANCEMENT
:: ------------------------------------------------------------------------------
echo [Execution] Application de la politique RemoteSigned et lancement du moteur...

:: 1. On recharge le PATH pour detecter Python s'il vient d'etre installe
:: 2. On applique la commande demandee par ton professeur (RemoteSigned sur CurrentUser)
:: 3. On lance ton script moteur_installation.ps1
powershell.exe -NoProfile -Command "[Environment]::SetEnvironmentVariable('PATH', [Environment]::GetEnvironmentVariable('PATH', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('PATH', 'User'), 'Process'); Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; & '.\moteur_installation.ps1'"

pause