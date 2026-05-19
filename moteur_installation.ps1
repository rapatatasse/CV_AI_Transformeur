# ==============================================================================
# Script : Moteur_Installation.ps1
# Objectif : Automatisation de l'environnement de developpement (Python, Pip, Librairies)
# Usage : Automatise le deploiement du projet de traitement de CV pour l'utilisateur
# ==============================================================================

# On force la console PowerShell a utiliser l'encodage UTF-8 universel
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Chargement de l'assembly graphique de Windows pour pouvoir afficher des fenetres de dialogue (MessageBox)
Add-Type -AssemblyName System.Windows.Forms

# --- CONFIGURATION COMPATIBILITÉ IA (BTS SIO) ---
# On cible la version stable 3.12 pour obtenir les paquets binaires pre-compiles (Wheels)
$verCible = [version]"3.12.0"
$verMaxMajeure = [version]"3.13.0"
$pythonPackageId = "Python.Python.3.12"

# --- FONCTIONS SCOPÉES ---

# Fonction simplifiee : affiche uniquement une phrase sobre de chargement
function Show-Progress($label) {
    Write-Host "`n  $label" -ForegroundColor Cyan
    Write-Host "  --> Installation en cours, veuillez patienter..." -ForegroundColor White
}

# Fonction deleguee a l'installation silencieuse de Python via le gestionnaire de paquets Windows (Winget)
function Install-Python {
    param([string]$packageId = $pythonPackageId)
    
    Show-Progress "Installation de Python $packageId..."
    
    # Appel de Winget en arriere-plan avec acceptation automatique des licences d'utilisation
    $installResult = winget install --id $packageId --silent --accept-source-agreements --accept-package-agreements --force 2>&1
    
    # Verification du code de retour du processus ($LASTEXITCODE). 0 signifie sans erreur.
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  --> ERREUR : Echec de l'installation de $packageId (code $LASTEXITCODE)." -ForegroundColor Red
        Write-Host "  --> Detail : $installResult" -ForegroundColor DarkRed
        return $false
    }
    Write-Host "  --> Application des modifications systeme. Pause de 5 secondes..." -ForegroundColor Gray
    Start-Sleep -Seconds 5
    return $true
}

# --- DEBUT DU SCRIPT PRINCIPAL ---
Clear-Host
Write-Host "`n  ==========================================" -ForegroundColor Cyan
Write-Host "       Installation logiciel Projet CV          " -ForegroundColor Blue 
Write-Host "  ==========================================" -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# ETAPE 1 : VERIFICATION DE LA PRESENCE ET DE LA VERSION DE PYTHON
# ------------------------------------------------------------------------------
Write-Host "`n  [1] Analyse de Python..." -ForegroundColor Gray

# Execution de la commande systeme pour checker la version, 2>$null masque les messages d'erreur natifs
$checkPy = python --version 2>$null

if ($checkPy) {
    # Nettoyage de la chaine renvoyee (ex: "Python 3.12.0" devient "3.12.0")
    $currentVerStr = ($checkPy -replace "Python ","").Trim()
    Write-Host "  --> VERSION ACTUELLE : $currentVerStr" -ForegroundColor Green -BackgroundColor Black
    
    # Cast (conversion) de la chaine de caracteres en objet [version] pour faire une comparaison de version
    $currentVer = [version]$currentVerStr
    if ($currentVer -lt $verCible -or $currentVer -ge $verMaxMajeure) {
        Write-Host "  --> ATTENTION : La version $currentVerStr va bloquer l'installation de l'IA (Erreur CMake)." -ForegroundColor Yellow
        $msg = "Ta version actuelle de Python ($currentVerStr) impose une compilation locale complexe.`n`nVoulez-vous installer la version stable recommandee (Python 3.12) via Winget ?"
        $ans = [System.Windows.Forms.MessageBox]::Show($msg, "Optimisation d'environnement IA", "YesNo", "Warning")
        if ($ans -eq "Yes") {
            if (Install-Python) {
                Write-Host "  --> Pre-requis Python 3.12 installe. Veuillez relancer le fichier .bat pour appliquer les changements." -ForegroundColor Cyan
                Write-Host "`n  [ Appuie sur une touche pour quitter et relancer via le .bat ]" -ForegroundColor DarkGray
                Read-Host
                exit
            }
        }
    } else {
        Write-Host "  --> Statut : Ton Python est parfaitement compatible et pret !" -ForegroundColor Yellow
    }
} else {
    # Cas ou Python est totalement introuvable sur le systeme de l'utilisateur
    Write-Host "  --> Statut : Python n'est PAS installe sur cette machine !" -ForegroundColor Red
    $ans = [System.Windows.Forms.MessageBox]::Show("Python est absent du systeme. L'installer maintenant ?", "Installation Requise", "YesNo", "Warning")
    if ($ans -eq "Yes") {
        if (Install-Python) {
            Write-Host "  --> Python 3.12 est installe. Relancez le .bat." -ForegroundColor Green
            exit
        }
    }
}

# ------------------------------------------------------------------------------
# ETAPE 2 : ANALYSE ET VALIDATION DE L'INTERPRÉTEUR PYTHON (PATH)
# ------------------------------------------------------------------------------
Write-Host "`n  [2] Analyse de l'interpreteur Python..." -ForegroundColor Gray
try {
    # On demande a Python d'executer une mini instruction systeme pour renvoyer le chemin exact de son executable (.exe)
    $interpTest = python -c "import sys; print(sys.executable)" 2>$null
    if ($interpTest) {
        Write-Host "  --> INTERPRETEUR : $interpTest" -ForegroundColor Green -BackgroundColor Black
        Write-Host "  --> Statut : Interpreteur Python operationnel et accessible !" -ForegroundColor Yellow
    } else {
        Write-Host "  --> Statut : L'interpreteur Python renvoie une reponse vide ou incorrecte." -ForegroundColor Red
        $ans2 = [System.Windows.Forms.MessageBox]::Show("Interpreteur defecteux. Forcer une reinstallation complet de Python ?", "Reparation", "YesNo", "Warning")
        if ($ans2 -eq "Yes") {
            [void](Install-Python)
        }
    }
} catch {
    Write-Host "  --> Statut : Exception critique lors de l'appel a l'interpreteur." -ForegroundColor Red
}

# ------------------------------------------------------------------------------
# ETAPE 3 : DEPLOIEMENT ET CONFIGURATION DES MODULES ET DEPENDANCES (PIP)
# ------------------------------------------------------------------------------
Write-Host "`n  [3] Installation des modules Python et IA..." -ForegroundColor Gray
try {
    # Mise a jour initiale du gestionnaire de paquets interne de Python (Pip)
    Show-Progress "Mise a jour du gestionnaire de paquets (pip)..."
    python -m pip install --upgrade pip 2>&1 | Out-Null
    Write-Host "  --> [OK] Gestionnaire pip mis a jour." -ForegroundColor Green
    
    # Deploiement de la librairie d'extraction brute des documents PDF (pypdf)
    Show-Progress "Installation du module d'extraction (pypdf)..."
    $pypdfOut = python -m pip install pypdf 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  --> [OK] Module pypdf installe avec succes." -ForegroundColor Green
    } else {
        Write-Host "  --> Echec de l'installation de pypdf." -ForegroundColor Red
        Write-Host "  --> Detail : $pypdfOut" -ForegroundColor DarkRed
    }

    # Deploiement de l'infrastructure d'execution de LLM Local (llama-cpp-python)
    Show-Progress "Installation du moteur IA Local (llama-cpp-python)..."
    
    # Stratégie de contournement des chemins longs :
    $tmpDir = "C:\pytmp"
    if (-not (Test-Path $tmpDir)) { New-Item -ItemType Directory -Path $tmpDir | Out-Null }
    
    # On sauvegarde et surcharge les variables d'environnement de la session
    $oldTmp = $env:TMP
    $oldTemp = $env:TEMP
    $env:TMP = $tmpDir
    $env:TEMP = $tmpDir
    
    # Lancement de l'installation (pip chargera directement le binaire stable sans compiler)
    $llamaOut = py -m pip install llama-cpp-python --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cpu
    
    # Restauration des variables d'environnement d'origine
    $env:TMP = $oldTmp
    $env:TEMP = $oldTemp
    
    # Nettoyage physique du dossier temporaire court
    Remove-Item -Path $tmpDir -Recurse -Force -ErrorAction SilentlyContinue

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  --> [OK] Module llama-cpp-python deploye avec succes (Moteur LLM pret)." -ForegroundColor Green
    } else {
        Write-Host "  --> Echec de l'installation de llama-cpp-python." -ForegroundColor Red
        Write-Host "  --> Detail : $llamaOut" -ForegroundColor DarkRed
    }

} catch {
    # Capturation de toute exception PowerShell imprevue
    Write-Host "  --> Echec general lors de la configuration de l'ecosysteme Python." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkRed
}

# Cloture propre de la console d'automatisation
Write-Host "`n  [ Termine ! Appuie sur une touche pour quitter ]" -ForegroundColor DarkGray
Read-Host