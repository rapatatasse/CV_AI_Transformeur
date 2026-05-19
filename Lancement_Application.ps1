# Script : Lancement_Application.ps1
# Objectif : Interface fixe, claire et modifiable pour structurer un CV en JSON

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Show-MainForm {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Lancement Application - Modification propre du CV'
    $form.Size = New-Object System.Drawing.Size(850, 720)
    $form.StartPosition = 'CenterScreen'
    $form.TopMost = $true
    $form.FormBorderStyle = 'FixedSingle'
    $form.MaximizeBox = $false

    # --- BOUTONS ---
    $btnChoosePdf = New-Object System.Windows.Forms.Button
    $btnChoosePdf.Text = 'Choisir le PDF'
    $btnChoosePdf.Size = New-Object System.Drawing.Size(150, 40)
    $btnChoosePdf.Location = New-Object System.Drawing.Point(25, 20)
    $btnChoosePdf.BackColor = [System.Drawing.Color]::FromArgb(0, 128, 255)
    $btnChoosePdf.ForeColor = [System.Drawing.Color]::White
    $form.Controls.Add($btnChoosePdf)

    $btnImport = New-Object System.Windows.Forms.Button
    $btnImport.Text = 'Extraire les données'
    $btnImport.Size = New-Object System.Drawing.Size(220, 50)
    $btnImport.Location = New-Object System.Drawing.Point(190, 15)
    $btnImport.BackColor = [System.Drawing.Color]::FromArgb(60, 120, 215)
    $btnImport.ForeColor = [System.Drawing.Color]::White
    $form.Controls.Add($btnImport)

    $lblPdfPath = New-Object System.Windows.Forms.Label
    $lblPdfPath.AutoSize = $true
    $lblPdfPath.Location = New-Object System.Drawing.Point(25, 75)
    $lblPdfPath.Text = 'PDF sélectionné : aucun'
    $form.Controls.Add($lblPdfPath)

    # --- ENCADRÉ FORMULAIRE (CHAMPS FIXES ET ALIGNÉS) ---
    $groupFields = New-Object System.Windows.Forms.GroupBox
    $groupFields.Text = ' Informations Essentielles Extrayables et Modifiables '
    $groupFields.Location = New-Object System.Drawing.Point(25, 110)
    $groupFields.Size = New-Object System.Drawing.Size(780, 480)
    $form.Controls.Add($groupFields)

    # Nom
    $lblNom = New-Object System.Windows.Forms.Label
    $lblNom.Text = "Nom / Prénom :"
    $lblNom.Location = New-Object System.Drawing.Point(20, 35)
    $lblNom.Size = New-Object System.Drawing.Size(120, 25)
    $groupFields.Controls.Add($lblNom)

    $txtNom = New-Object System.Windows.Forms.TextBox
    $txtNom.Location = New-Object System.Drawing.Point(160, 32)
    $txtNom.Size = New-Object System.Drawing.Size(590, 25)
    $groupFields.Controls.Add($txtNom)

    # Email
    $lblEmail = New-Object System.Windows.Forms.Label
    $lblEmail.Text = "Adresse Email :"
    $lblEmail.Location = New-Object System.Drawing.Point(20, 75)
    $lblEmail.Size = New-Object System.Drawing.Size(120, 25)
    $groupFields.Controls.Add($lblEmail)

    $txtEmail = New-Object System.Windows.Forms.TextBox
    $txtEmail.Location = New-Object System.Drawing.Point(160, 72)
    $txtEmail.Size = New-Object System.Drawing.Size(590, 25)
    $groupFields.Controls.Add($txtEmail)

    # Téléphone
    $lblTel = New-Object System.Windows.Forms.Label
    $lblTel.Text = "Téléphone :"
    $lblTel.Location = New-Object System.Drawing.Point(20, 115)
    $lblTel.Size = New-Object System.Drawing.Size(120, 25)
    $groupFields.Controls.Add($lblTel)

    $txtTel = New-Object System.Windows.Forms.TextBox
    $txtTel.Location = New-Object System.Drawing.Point(160, 112)
    $txtTel.Size = New-Object System.Drawing.Size(590, 25)
    $groupFields.Controls.Add($txtTel)

    # Compétences
    $lblSkills = New-Object System.Windows.Forms.Label
    $lblSkills.Text = "Compétences :"
    $lblSkills.Location = New-Object System.Drawing.Point(20, 155)
    $lblSkills.Size = New-Object System.Drawing.Size(120, 25)
    $groupFields.Controls.Add($lblSkills)

    $txtSkills = New-Object System.Windows.Forms.TextBox
    $txtSkills.Location = New-Object System.Drawing.Point(160, 152)
    $txtSkills.Size = New-Object System.Drawing.Size(590, 100)
    $txtSkills.Multiline = $true
    $txtSkills.ScrollBars = 'Vertical'
    $groupFields.Controls.Add($txtSkills)

    # Texte Brut
    $lblRaw = New-Object System.Windows.Forms.Label
    $lblRaw.Text = "Texte Brut Complet :"
    $lblRaw.Location = New-Object System.Drawing.Point(20, 270)
    $lblRaw.Size = New-Object System.Drawing.Size(120, 25)
    $groupFields.Controls.Add($lblRaw)

    $txtRaw = New-Object System.Windows.Forms.TextBox
    $txtRaw.Location = New-Object System.Drawing.Point(160, 267)
    $txtRaw.Size = New-Object System.Drawing.Size(590, 190)
    $txtRaw.Multiline = $true
    $txtRaw.ScrollBars = 'Vertical'
    $groupFields.Controls.Add($txtRaw)

    # --- BOUTON SAUVEGARDE ---
    $btnSaveJson = New-Object System.Windows.Forms.Button
    $btnSaveJson.Text = 'Enregistrer en fichier JSON'
    $btnSaveJson.Size = New-Object System.Drawing.Size(250, 45)
    $btnSaveJson.Location = New-Object System.Drawing.Point(555, 605)
    $btnSaveJson.BackColor = [System.Drawing.Color]::FromArgb(46, 139, 87)
    $btnSaveJson.ForeColor = [System.Drawing.Color]::White
    $btnSaveJson.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
    $btnSaveJson.Enabled = $false
    $form.Controls.Add($btnSaveJson)

    # --- BARRE DE STATUT ---
    $status = New-Object System.Windows.Forms.Label
    $status.AutoSize = $true
    $status.Location = New-Object System.Drawing.Point(25, 655)
    $status.ForeColor = [System.Drawing.Color]::Blue
    $status.Text = 'Statut : Prêt.'
    $form.Controls.Add($status)

    $global:SelectedPdfPath = ''

    # --- ACTIONS DES BOUTONS ---
    
    # 1. Clic Choisir le PDF
    $btnChoosePdf.Add_Click({
        $dialog = New-Object System.Windows.Forms.OpenFileDialog
        $dialog.Filter = 'Fichier PDF (*.pdf)|*.pdf'
        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $global:SelectedPdfPath = $dialog.FileName
            $lblPdfPath.Text = "PDF sélectionné : " + $global:SelectedPdfPath
            $status.Text = 'Fichier chargé. Cliquez sur Extraire.'
        }
    })

    # 2. Clic Extraire les données
    $btnImport.Add_Click({
        if ([string]::IsNullOrEmpty($global:SelectedPdfPath)) { return }
        $status.Text = 'Extraction en cours par Python...'

        $pythonExe = (Get-Command python.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source)
        if (-not $pythonExe -or $pythonExe -match "WindowsApps") {
            $checkLocal = Get-ChildItem -Path "$env:LOCALAPPDATA\Programs\Python\Python*" -Filter "python.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($checkLocal) { $pythonExe = $checkLocal.FullName } else { $pythonExe = "python" }
        }

        $pyCode = @"
import sys
import json
from pypdf import PdfReader

sys.stdout.reconfigure(encoding='utf-8')
reader = PdfReader(sys.argv[1])
full_text = ''
for page in reader.pages:
    full_text += page.extract_text() or ''

lines = [l.strip() for l in full_text.splitlines() if l.strip()]
data = {'raw': full_text.strip(), 'email': '', 'telephone': '', 'nom': '', 'competences': []}

for l in lines:
    low = l.lower()
    if '@' in l and not data['email']: data['email'] = l
    if any(x in low for x in ['tel', 'tél', 'phone']) and not data['telephone']: data['telephone'] = l
    if any(x in low for x in ['compétence', 'skills', 'connaissances', 'savoir-faire']): data['competences'].append(l)
    if not data['nom'] and any(x in low for x in ['mr', 'mme', 'm.', 'madame', 'monsieur']): data['nom'] = l

if not data['nom'] and lines: data['nom'] = lines[0]
print(json.dumps(data, ensure_ascii=False))
"@
        
        $scriptPath = Join-Path $env:TEMP 'extract_pdf.py'
        Set-Content -Path $scriptPath -Value $pyCode -Encoding UTF8
        $rawOutput = & $pythonExe $scriptPath $global:SelectedPdfPath 2>&1
        Remove-Item -Path $scriptPath -Force -ErrorAction SilentlyContinue

        try {
            $cleanLine = ($rawOutput -split "`r`n")[-1]
            $cv = ConvertFrom-Json $cleanLine

            # Remplissage des zones de texte blanches (Modifiables)
            $txtNom.Text = $cv.nom
            $txtEmail.Text = $cv.email
            $txtTel.Text = $cv.telephone
            $txtRaw.Text = $cv.raw
            
            if ($cv.competences) {
                $txtSkills.Text = [string]::Join("`r`n", @($cv.competences))
            } else {
                $txtSkills.Text = ""
            }

            $status.ForeColor = [System.Drawing.Color]::DarkGreen
            $status.Text = 'Succès ! Les champs sont modifiables avant sauvegarde.'
            $btnSaveJson.Enabled = $true
        } catch {
            $status.ForeColor = [System.Drawing.Color]::Red
            $status.Text = 'Erreur lors du traitement du JSON.'
            $txtRaw.Text = $rawOutput
        }
    })

    # 3. Clic Sauvegarder en JSON
    $btnSaveJson.Add_Click({
        $saveDialog = New-Object System.Windows.Forms.SaveFileDialog
        $saveDialog.Filter = 'Fichier JSON (*.json)|*.json'
        
        $nameDefault = "cv_output.json"
        if ($txtNom.Text) { $nameDefault = ($txtNom.Text -replace '[^a-zA-Z0-9]', '_') + "_cv.json" }
        $saveDialog.FileName = $nameDefault

        if ($saveDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $finalObj = New-Object PSObject
            $finalObj | Add-Member -MemberType NoteProperty -Name "nom" -Value $txtNom.Text
            $finalObj | Add-Member -MemberType NoteProperty -Name "email" -Value $txtEmail.Text
            $finalObj | Add-Member -MemberType NoteProperty -Name "telephone" -Value $txtTel.Text
            $finalObj | Add-Member -MemberType NoteProperty -Name "competences" -Value ($txtSkills.Text -split "`r`n" | Where-Object { $_.Trim() -ne "" })
            $finalObj | Add-Member -MemberType NoteProperty -Name "raw" -Value $txtRaw.Text

            $jsonString = ConvertTo-Json $finalObj -Depth 5
            Set-Content -Path $saveDialog.FileName -Value $jsonString -Encoding UTF8
            
            $status.Text = "Enregistré avec succès !"
            [System.Windows.Forms.MessageBox]::Show("Fichier JSON créé !", 'Succès', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
        }
    })

    [void]$form.ShowDialog()
}

Show-MainForm