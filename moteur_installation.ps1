# On force l'encodage pour eviter les bugs d'accents
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Type -AssemblyName System.Windows.Forms

$verCible = [version]"3.14.0"
$pythonPackageId = "Python.Python.3.14"
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

function Install-Python {
    param([string]$packageId = $pythonPackageId)
    Show-Progress "Installation de Python $packageId..."
    $installResult = winget install --id $packageId --silent --accept-source-agreements --accept-package-agreements --force 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  --> ERREUR : Echec de l'installation de $packageId (code $LASTEXITCODE)." -ForegroundColor Red
        Write-Host "  --> Détail : $installResult" -ForegroundColor DarkRed
        if ($packageId -eq $pythonPackageId) {
            Write-Host "  --> Tentative de fallback vers Python.Python (dernier disponible)..." -ForegroundColor Yellow
            $fallbackResult = winget install --id Python.Python --silent --accept-source-agreements --accept-package-agreements --force 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  --> Fallback Python installé avec succès." -ForegroundColor Green
                Start-Sleep -Seconds 10
                return $true
            }
            Write-Host "  --> Echec du fallback Python.Python (code $LASTEXITCODE)." -ForegroundColor Red
            Write-Host "  --> Détail : $fallbackResult" -ForegroundColor DarkRed
        }
        return $false
    }
    Start-Sleep -Seconds 10
    return $true
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
            if (Install-Python) {
                Write-Host "  --> Python $verCible installe avec succes." -ForegroundColor Green
            } else {
                Write-Host "  --> Impossible d'installer Python $verCible." -ForegroundColor Red
            }
        }
    } else {
        Write-Host "  --> Statut : Ton Python est a jour !" -ForegroundColor Yellow
    }
} else {
    Write-Host "  --> Statut : Python n'est PAS installe !" -ForegroundColor Red
    $ans = [System.Windows.Forms.MessageBox]::Show("Python est absent. L'installer ?", "Installation", "YesNo", "Warning")
    if ($ans -eq "Yes") {
        if (Install-Python) {
            Write-Host "  --> Python est installe." -ForegroundColor Green
        } else {
            Write-Host "  --> Echec de l'installation de Python." -ForegroundColor Red
        }
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
        $ans2 = [System.Windows.Forms.MessageBox]::Show("Interpreteur Python non fonctionnel. Reinstaller Python ?", "Interpreteur", "YesNo", "Warning")
        if ($ans2 -eq "Yes") {
            if (Install-Python) {
                Write-Host "  --> Interpreteur reinstalle." -ForegroundColor Green
            } else {
                Write-Host "  --> Echec de la reinstalation de l'interpreteur Python." -ForegroundColor Red
            }
        }
    }
} catch {
    Write-Host "  --> Statut : Interpreteur Python inaccessible." -ForegroundColor Red
    $ans2 = [System.Windows.Forms.MessageBox]::Show("Interpreteur Python inaccessible. Reinstaller Python ?", "Interpreteur", "YesNo", "Warning")
    if ($ans2 -eq "Yes") {
        if (Install-Python) {
            Write-Host "  --> Interpreteur reinstalle." -ForegroundColor Green
        } else {
            Write-Host "  --> Echec de la reinstalation de l'interpreteur Python." -ForegroundColor Red
        }
    }
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
        $lmCmd = "winget install --id ElementLabs.LMStudio --accept-source-agreements --accept-package-agreements --silent --force"
        for ($attempt = 1; $attempt -le 3; $attempt++) {
            Show-Progress "Installation de LM Studio (tentative $attempt)..."
            $out = Invoke-Expression $lmCmd 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  --> LM Studio installe avec succes." -ForegroundColor Green
                $lmStudioFound = $true
                break
            } else {
                Write-Host "  --> Echec LM Studio (code: $LASTEXITCODE)." -ForegroundColor Red
                if ($LASTEXITCODE -eq 3221225477) {
                    Write-Host "  --> Code d'erreur reconnue: 3221225477 (accès mémoire). Vérifie que tu n'as pas d'antivirus bloquant ou exécution en mode Admin." -ForegroundColor Yellow
                }
                Start-Sleep -Seconds 5
            }
        }
        if (-not $lmStudioFound) {
            Write-Host "  --> Impossible d'installer LM Studio. Vérifie manuellement puis relance le script." -ForegroundColor Red
        }
    }
}

Write-Host "`n  [ 4 ] Installation du module Python openai..." -ForegroundColor Gray
try {
    python -m pip install --upgrade pip
    python -m pip install openai
    Write-Host "  --> Module openai installe avec succes." -ForegroundColor Green
} catch {
    Write-Host "  --> Echec installation openai. Vérifie la configuration Python/pip." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkRed
}

Write-Host "`n  [ Termine ! Appuie sur une touche pour quitter ]" -ForegroundColor DarkGray
Read-Host
