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
Write-Host "      Installation logiciel Projet CV          " -ForegroundColor Blue 
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
            Start-Sleep -Seconds 10
            Write-Host "  --> Installation terminee. Verification..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    } else {
        Write-Host "  --> Statut : Ton Python est a jour !" -ForegroundColor Yellow
    }
} else {
    Write-Host "  --> Statut : Python n'est PAS installe !" -ForegroundColor Red
    $ans = [System.Windows.Forms.MessageBox]::Show("Python est absent. L'installer ?", "Installation", "YesNo", "Warning")
    if ($ans -eq "Yes") {
        Show-Progress "Installation de Python 3.12..."
        winget install Python.Python.3.12 --silent
        Start-Sleep -Seconds 10
        Write-Host "  --> Installation terminee. Verification..." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    }
}

# 2. VERIF INTERPRETEUR PYTHON
Write-Host "`n  [2] Analyse de l'interpreteur Python..." -ForegroundColor Gray
try {
    $interpTest = python -c "import sys; print(sys.executable)" 2>$null
    if ($interpTest) {
        Write-Host "  --> INTERPRETEUR : $interpTest" -ForegroundColor Green -BackgroundColor Black
        Write-Host "  --> Statut : Interpreteur Python fonctionnel !" -ForegroundColor Yellow
    } else {
        Write-Host "  --> Statut : Interpreteur Python non fonctionnel." -ForegroundColor Red
    }
} catch {
    Write-Host "  --> Statut : Interpreteur Python inaccessible." -ForegroundColor Red
}

# 3. VERIF LM STUDIO
Write-Host "`n  [3] Analyse de LM Studio..." -ForegroundColor Gray
$lmStudioPaths = @(
    "$env:LOCALAPPDATA\LM Studio\LM Studio.exe",
    "$env:PROGRAMFILES\LM Studio\LM Studio.exe",
    "$env:PROGRAMFILES(X86)\LM Studio\LM Studio.exe"
)

$lmStudioFound = $false
$lmStudioPath = $null

foreach ($path in $lmStudioPaths) {
    if (Test-Path $path) {
        $lmStudioFound = $true
        $lmStudioPath = $path
        break
    }
}

# Vérification également via winget
$wingetLM = winget list --id "ElementLabs.LMStudio" --exact 2>$null
if ($wingetLM -and $wingetLM -match "LM Studio") {
    $lmStudioFound = $true
}

if ($lmStudioFound) {
    if ($lmStudioPath) {
        Write-Host "  --> CHEMINS : $lmStudioPath" -ForegroundColor Green -BackgroundColor Black
    }
    Write-Host "  --> Statut : LM Studio est pret." -ForegroundColor Green
    Write-Host "  --> LM Studio est pret a etre utilise !" -ForegroundColor Yellow
} else {
    Write-Host "  --> Statut : LM Studio est PAS installe !" -ForegroundColor Red
    $ans = [System.Windows.Forms.MessageBox]::Show("LM Studio est absent. L'installer ?", "Installation", "YesNo", "Warning")
    if ($ans -eq "Yes") {
        Show-Progress "Installation de LM Studio..."
        winget install --id ElementLabs.LMStudio --accept-source-agreements --accept-package-agreements --force
        Start-Sleep -Seconds 15
        Write-Host "  --> Installation terminee. Verification..." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    }
}

Write-Host "`n  [ Termine ! Appuie sur une touche pour quitter ]" -ForegroundColor DarkGray
Read-Host
