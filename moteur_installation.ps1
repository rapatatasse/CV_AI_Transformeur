# On force l'encodage pour eviter les bugs d'accents
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Type -AssemblyName System.Windows.Forms

$verCible = [version]"3.12"
$pote = " (づ｡◕‿‿◕｡)づ"

# --- FONCTIONS ---
function Show-Progress($label) {
    Write-Host "`n  $label" -ForegroundColor Cyan
    for ($i = 0; $i -le 20; $i++) {
        $fill = "█" * $i
        $void = "░" * (20 - $i)
        Write-Host "`r  $fill$void $pote" -NoNewline -ForegroundColor Yellow
        Start-Sleep -Milliseconds 50
    }
    Write-Host " [OK]" -ForegroundColor Green
}

# --- DEBUT ---
Clear-Host
Write-Host "`n  ==========================================" -ForegroundColor Cyan
Write-Host "      CHECK-UP DU PROJET COMMUN CV          " -ForegroundColor Cyan -Bold
Write-Host "  ==========================================" -ForegroundColor Cyan

# 1. VERIF PYTHON
Write-Host "`n  [1] Analyse de Python..." -ForegroundColor Gray
$checkPy = python --version 2>$null

if ($checkPy) {
    $currentVerStr = ($checkPy -replace "Python ","").Trim()
    Write-Host "  --> VERSION ACTUELLE : $currentVerStr" -ForegroundColor Green -BackgroundColor Black
    
    $currentVer = [version]$currentVerStr
    if ($currentVer -lt $verCible) {
        $msg = "Ta version ($currentVer) est trop ancienne.`n`nVoulez-vous installer la $verCible ?"
        $ans = [System.Windows.Forms.MessageBox]::Show($msg, "Mise a jour", "YesNo", "Question")
        if ($ans -eq "Yes") {
            Show-Progress "Mise a jour en cours..."
            winget install Python.Python.3.12 --silent --force
        }
    } else {
        Write-Host "  --> Statut : Ton Python est a jour ! ✨" -ForegroundColor Yellow
    }
} else {
    Write-Host "  --> Statut : Python n'est PAS installe !" -ForegroundColor Red
    $ans = [System.Windows.Forms.MessageBox]::Show("Python est absent. L'installer ?", "Installation", "YesNo", "Warning")
    if ($ans -eq "Yes") {
        Show-Progress "Installation de Python 3.12..."
        winget install Python.Python.3.12 --silent
    }
}

# 2. VERIF VS CODE
Write-Host "`n  [2] Analyse de l'editeur..." -ForegroundColor Gray
if (Get-Command code -ErrorAction SilentlyContinue) {
    Write-Host "  --> Statut : VS Code est pret. ✅" -ForegroundColor Green
} else {
    Write-Host "  --> Statut : VS Code est manquant. ❌" -ForegroundColor Red
}

Write-Host "`n  [ Termine ! Appuie sur une touche pour quitter ]" -ForegroundColor DarkGray