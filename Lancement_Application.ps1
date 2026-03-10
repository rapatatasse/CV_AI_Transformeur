# Script : Lancement_Application.ps1
# Objectif : importer un PDF via Python et afficher le texte extrait (ou créer un traitement personnalisé)
# Prérequis : Python installé + package "pypdf" (pip install pypdf)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 1) Vérifier si Python est disponible
try {
    $pyVersion = python --version 2>&1
    Write-Host "Python trouvé : $pyVersion" -ForegroundColor Green
} catch {
    Write-Host "Erreur : Python n'est pas trouvé. Installez Python et relancez." -ForegroundColor Red
    exit 1
}

# 2) Demander le chemin du fichier PDF
$pathPdf = Read-Host "Chemin complet du fichier PDF à importer"
if (-not (Test-Path $pathPdf)) {
    Write-Host "Le fichier PDF n'existe pas : $pathPdf" -ForegroundColor Red
    exit 1
}

# 3) Script Python temporaire pour extraire le texte du PDF
$scriptPy = @"
import sys
from pypdf import PdfReader

f = sys.argv[1]
reader = PdfReader(f)
text = []
for i, page in enumerate(reader.pages):
    text.append(f"--- Page {i+1} ---\n")
    text.append(page.extract_text() or "")

print(''.join(text))
"@

$tempScript = Join-Path $env:TEMP "extract_pdf_text.py"
Set-Content -Path $tempScript -Value $scriptPy -Encoding UTF8

# 4) Exécuter le script Python
try {
    Write-Host "Extraction du PDF en cours..." -ForegroundColor Cyan
    $result = python $tempScript "`"$pathPdf`"" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Erreur lors de l'exécution Python :" -ForegroundColor Red
        Write-Host $result -ForegroundColor DarkRed
        exit 1
    }
    Write-Host "=== Contenu extrait du PDF (premières 1000 caractères) ===" -ForegroundColor Yellow
    Write-Host ($result.Substring(0, [Math]::Min(1000, $result.Length)))
    if ($result.Length -gt 1000) { Write-Host "... (texte tronqué)" }
} catch {
    Write-Host "Échec de l'import PDF : $_" -ForegroundColor Red
    exit 1
}

Write-Host "Import PDF terminé." -ForegroundColor Green

# 5) Nettoyer le script temporaire
Remove-Item -Path $tempScript -Force -ErrorAction SilentlyContinue
