@echo off
title Assistant de Configuration Pro - Projet CV
pushd "%~dp0"

:: Vérification des droits administrateur
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Droits administrateur OK.
) else (
    echo.
    echo Ce script necessite des droits administrateur.
    echo.
    echo Relancement avec elevation des privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: On lance PowerShell en mode visible pour exécuter le script
powershell.exe -ExecutionPolicy Bypass -File "moteur_installation.ps1"
pause