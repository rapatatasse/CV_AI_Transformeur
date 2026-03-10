@echo off
REM Lancement.bat : affichage d'une boîte de dialogue puis lancement PowerShell script

powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; $ans=[System.Windows.Forms.MessageBox]::Show('Veux-tu lancer le module d\'import PDF (Python) ?','Lancement PDF', 'YesNo', 'Question'); if ($ans -eq 'Yes') { Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "' + (Convert-Path .\Lancement_Application.ps1) + '"' -Verb RunAs }}"

exit /b 0