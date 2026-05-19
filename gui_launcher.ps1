# Script PowerShell pour l'interface graphique de CV_AI_Transformeur
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Création de la fenêtre principale
$form = New-Object System.Windows.Forms.Form
$form.Text = "CV_AI_Transformeur"
$form.Size = New-Object System.Drawing.Size(400, 400)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# Titre
$label = New-Object System.Windows.Forms.Label
$label.Text = "CV_AI_Transformeur"
$label.Font = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Bold)
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(100, 20)
$form.Controls.Add($label)

# Bouton 1 : Extraire PDF vers TXT
$buttonPDF = New-Object System.Windows.Forms.Button
$buttonPDF.Text = "Extraire PDF vers TXT"
$buttonPDF.Size = New-Object System.Drawing.Size(200, 50)
$buttonPDF.Location = New-Object System.Drawing.Point(100, 70)
$buttonPDF.Font = New-Object System.Drawing.Font("Arial", 10)

$buttonPDF.Add_Click({
    $scriptPath = Join-Path $PSScriptRoot "python\pdf_reader.py"
    if (Test-Path $scriptPath) {
        Start-Process python -ArgumentList $scriptPath -Wait -NoNewWindow
        [System.Windows.Forms.MessageBox]::Show("Extraction PDF vers TXT terminée !", "Succès", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } else {
        [System.Windows.Forms.MessageBox]::Show("Fichier pdf_reader.py introuvable !", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

$form.Controls.Add($buttonPDF)

# Bouton 2 : Transformer TXT vers JSON
$buttonJSON = New-Object System.Windows.Forms.Button
$buttonJSON.Text = "Transformer TXT vers JSON"
$buttonJSON.Size = New-Object System.Drawing.Size(200, 50)
$buttonJSON.Location = New-Object System.Drawing.Point(100, 140)
$buttonJSON.Font = New-Object System.Drawing.Font("Arial", 10)

$buttonJSON.Add_Click({
    # Chemin à configurer plus tard
    $scriptPath = "A_CONFIGURER"  # Remplacer par le chemin du script de transformation TXT vers JSON
    
    if ($scriptPath -eq "A_CONFIGURER") {
        [System.Windows.Forms.MessageBox]::Show("Le chemin du script de transformation TXT vers JSON n'est pas encore configuré.`n`nVeuillez modifier le fichier gui_launcher.ps1 et remplacer 'A_CONFIGURER' par le chemin du script.", "Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } elseif (Test-Path $scriptPath) {
        Start-Process python -ArgumentList $scriptPath -Wait -NoNewWindow
        [System.Windows.Forms.MessageBox]::Show("Transformation TXT vers JSON terminée !", "Succès", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } else {
        [System.Windows.Forms.MessageBox]::Show("Fichier de transformation introuvable !", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

$form.Controls.Add($buttonJSON)

# Bouton Quitter
$buttonQuit = New-Object System.Windows.Forms.Button
$buttonQuit.Text = "Quitter"
$buttonQuit.Size = New-Object System.Drawing.Size(80, 30)
$buttonQuit.Location = New-Object System.Drawing.Point(160, 200)
$buttonQuit.Add_Click({ $form.Close() })
$form.Controls.Add($buttonQuit)

# Afficher la fenêtre
$form.ShowDialog()
