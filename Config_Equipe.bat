@echo off
title Assistant de Configuration Pro - Projet CV
pushd "%~dp0"
:: On lance PowerShell en mode invisible derrière pour ouvrir les fenêtres de dialogue
powershell -ExecutionPolicy Bypass -File "moteur_installation.ps1"
pause