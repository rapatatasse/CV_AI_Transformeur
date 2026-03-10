@echo off
title Assistant de Configuration Pro - Projet CV
pushd "%~dp0"

:: On lance PowerShell en mode visible pour exécuter le script
powershell.exe -ExecutionPolicy Bypass -File "moteur_installation.ps1"
pause