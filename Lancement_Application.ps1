# Script : Lancement_Application.ps1
# Objectif : interface graphique pour transformer CV PDF en JSON
# Prérequis : Python 3.14+ et module Python pypdf (installé automatiquement si absent)
# Usage : double-cliquer sur Lancement.bat ou exécuter directement ce script

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Show-BadAnswerLoop {
    while ($true) {
        $errorForm = New-Object System.Windows.Forms.Form
        $errorForm.Text = 'Mauvaise Réponse'
        $errorForm.Size = New-Object System.Drawing.Size(650, 230)
        $errorForm.StartPosition = 'CenterScreen'
        $errorForm.FormBorderStyle = 'FixedDialog'
        $errorForm.MaximizeBox = $false
        $errorForm.MinimizeBox = $false

        $errorLabel = New-Object System.Windows.Forms.Label
        $errorLabel.Text = "MAUVAISE REPONSE`nTu es vraiment le pire élève ou la personne la plus jalouse"
        $errorLabel.Font = New-Object System.Drawing.Font('Arial', 18, [System.Drawing.FontStyle]::Bold)
        $errorLabel.ForeColor = [System.Drawing.Color]::Red
        $errorLabel.AutoSize = $false
        $errorLabel.TextAlign = 'MiddleCenter'
        $errorLabel.Dock = 'Top'
        $errorLabel.Height = 140
        $errorForm.Controls.Add($errorLabel)

        $btnGrosNul = New-Object System.Windows.Forms.Button
        $btnGrosNul.Text = 'Gros nul'
        $btnGrosNul.Size = New-Object System.Drawing.Size(160, 40)
        $btnGrosNul.Location = New-Object System.Drawing.Point(245, 150)
        $btnGrosNul.BackColor = [System.Drawing.Color]::DarkBlue
        $btnGrosNul.ForeColor = [System.Drawing.Color]::White
        $errorForm.Controls.Add($btnGrosNul)

        $btnGrosNul.Add_Click({ $errorForm.Close() })

        [void]$errorForm.ShowDialog()
    }
}

function Show-MainForm {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Lancement Application - CV en JSON'
    $form.Size = New-Object System.Drawing.Size(780, 560)
    $form.StartPosition = 'CenterScreen'
    $form.TopMost = $true
    $form.FormBorderStyle = 'FixedSingle'
    $form.MaximizeBox = $false

    $btnChoosePdf = New-Object System.Windows.Forms.Button
    $btnChoosePdf.Text = 'Choisir le PDF'
    $btnChoosePdf.Size = New-Object System.Drawing.Size(150, 40)
    $btnChoosePdf.Location = New-Object System.Drawing.Point(25, 20)
    $btnChoosePdf.BackColor = [System.Drawing.Color]::FromArgb(0, 128, 255)
    $btnChoosePdf.ForeColor = [System.Drawing.Color]::White
    $form.Controls.Add($btnChoosePdf)

    $btnImport = New-Object System.Windows.Forms.Button
    $btnImport.Text = 'Lancer l application'
    $btnImport.Size = New-Object System.Drawing.Size(220, 50)
    $btnImport.Location = New-Object System.Drawing.Point(190, 15)
    $btnImport.BackColor = [System.Drawing.Color]::FromArgb(60, 120, 215)
    $btnImport.ForeColor = [System.Drawing.Color]::White
    $form.Controls.Add($btnImport)

    $lblPdfPath = New-Object System.Windows.Forms.Label
    $lblPdfPath.AutoSize = $true
    $lblPdfPath.Location = New-Object System.Drawing.Point(25, 68)
    $lblPdfPath.ForeColor = [System.Drawing.Color]::Black
    $lblPdfPath.Text = 'PDF sélectionné : aucun'
    $form.Controls.Add($lblPdfPath)

    $status = New-Object System.Windows.Forms.Label
    $status.AutoSize = $true
    $status.Location = New-Object System.Drawing.Point(25, 520)
    $status.ForeColor = [System.Drawing.Color]::DarkGreen
    $status.Text = 'Statut : prêt'
    $form.Controls.Add($status)

    $output = New-Object System.Windows.Forms.TextBox
    $output.Multiline = $true
    $output.ReadOnly = $true
    $output.ScrollBars = 'Vertical'
    $output.WordWrap = $true
    $output.BackColor = [System.Drawing.Color]::White
    $output.ForeColor = [System.Drawing.Color]::Black
    $output.Location = New-Object System.Drawing.Point(25, 90)
    $output.Size = New-Object System.Drawing.Size(730, 400)
    $form.Controls.Add($output)

    $global:SelectedPdf = ''

    $btnChoosePdf.Add_Click({
        $ofd = New-Object System.Windows.Forms.OpenFileDialog
        $ofd.Filter = 'PDF (*.pdf)|*.pdf'
        $ofd.Title = 'Choisissez un CV PDF à importer'
        if ($ofd.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
            $status.Text = 'Statut : sélection annulée.'
            return
        }
        $global:SelectedPdf = $ofd.FileName
        $lblPdfPath.Text = "PDF sélectionné : $global:SelectedPdf"
        $status.Text = 'Statut : PDF sélectionné.'
    })

    $btnImport.Add_Click({
        if ([string]::IsNullOrEmpty($global:SelectedPdf) -or -not (Test-Path $global:SelectedPdf)) {
            $nodeFolder = Join-Path $PSScriptRoot 'logiciels\node js'
            $appJsPath = Join-Path $nodeFolder 'app.js'
            if (-not (Test-Path $appJsPath)) {
                [System.Windows.Forms.MessageBox]::Show("Fichier app.js introuvable : $appJsPath", 'Erreur', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
                $status.Text = 'Statut : app.js non trouvé.'
                return
            }
            $status.Text = 'Statut : lancement node app.js...'
            Start-Process -FilePath 'node' -ArgumentList "`"$appJsPath`"" -WorkingDirectory $nodeFolder
            return
        }

        $pdfPath = $global:SelectedPdf
        $status.Text = 'Statut : vérification Python...'
        if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
            $status.Text = 'Statut : python non trouvé.'
            [System.Windows.Forms.MessageBox]::Show('Python n''est pas installé ou pas dans PATH. Installez Python 3.14+.', 'Erreur', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
            return
        }

        try { python -c "import pypdf" 2>$null } catch {
            $status.Text = 'Statut : installation pypdf...'
            python -m pip install --upgrade pip
            python -m pip install pypdf
        }

        $status.Text = 'Statut : extraction et conversion en cours...'
        $pyScript = @"
import sys
import json
from pypdf import PdfReader
path = sys.argv[1]
reader = PdfReader(path)
text = ''
for page in reader.pages:
    text += page.extract_text() or ''
lines = [l.strip() for l in text.splitlines() if l.strip()]
cv = {'raw': text, 'email': None, 'telephone': None, 'nom': None, 'competences': []}
for l in lines:
    low = l.lower()
    if '@' in l and cv['email'] is None: cv['email'] = l
    if any(x in low for x in ['tel', 'tél', 'telephone', 'phone']) and cv['telephone'] is None: cv['telephone'] = l
    if any(x in low for x in ['compétence', 'skills', 'skill']): cv['competences'].append(l)
    if cv['nom'] is None and any(x in low for x in ['mr', 'mme', 'm.', 'madame', 'monsieur']): cv['nom'] = l
if cv['nom'] is None and lines: cv['nom'] = lines[0]
print(json.dumps(cv, ensure_ascii=False, indent=2))
"@
        $tmpPy = Join-Path $env:TEMP 'extract_pdf_to_json.py'
        Set-Content -Path $tmpPy -Value $pyScript -Encoding UTF8
        $jsonResult = python $tmpPy "`"$pdfPath`"" 2>&1
        Remove-Item -Path $tmpPy -Force -ErrorAction SilentlyContinue

        if ($LASTEXITCODE -ne 0) {
            $status.Text = 'Statut : échec conversion.'
            $output.Text = $jsonResult
            [System.Windows.Forms.MessageBox]::Show('Erreur lors de la conversion. Voir la sortie.', 'Erreur', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
            return
        }

        $status.Text = 'Statut : CV converti en JSON.'
        $output.Text = $jsonResult
    })

    [void]$form.ShowDialog()
}

function Show-Welcome {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Alerte importante'
    $form.Size = New-Object System.Drawing.Size(700, 220)
    $form.StartPosition = 'CenterScreen'
    $form.FormBorderStyle = 'FixedDialog'
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Camille C'est Le Plus Fort des Eleves"
    $label.Font = New-Object System.Drawing.Font('Arial', 22, [System.Drawing.FontStyle]::Bold)
    $label.ForeColor = [System.Drawing.Color]::Red
    $label.AutoSize = $false
    $label.TextAlign = 'MiddleCenter'
    $label.Dock = 'Top'
    $label.Height = 120
    $form.Controls.Add($label)

    $btnYes = New-Object System.Windows.Forms.Button
    $btnYes.Text = 'Oui'
    $btnYes.Size = New-Object System.Drawing.Size(120, 40)
    $btnYes.Location = New-Object System.Drawing.Point(170, 130)
    $btnYes.BackColor = [System.Drawing.Color]::Green
    $btnYes.ForeColor = [System.Drawing.Color]::White
    $form.Controls.Add($btnYes)

    $btnNo = New-Object System.Windows.Forms.Button
    $btnNo.Text = 'Non'
    $btnNo.Size = New-Object System.Drawing.Size(120, 40)
    $btnNo.Location = New-Object System.Drawing.Point(400, 130)
    $btnNo.BackColor = [System.Drawing.Color]::DarkRed
    $btnNo.ForeColor = [System.Drawing.Color]::White
    $form.Controls.Add($btnNo)

    $btnYes.Add_Click({
        [System.Windows.Forms.MessageBox]::Show('Oui détecté. Lancement de l''application principale.', 'Info', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
        $form.Close()
        Show-MainForm
    })
    $btnNo.Add_Click({
        $form.Close()
        Show-BadAnswerLoop
    })

    [void]$form.ShowDialog()
}

Show-Welcome
