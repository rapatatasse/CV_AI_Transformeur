#------------------------------------------------
# Import des librairies
#------------------------------------------------

import os
import re
import time
from PyPDF2 import PdfReader


#------------------------------------------------
# Fonctions
#------------------------------------------------


# Role : Permet de nettoyer le texte extrait du CV
# Arguments : texte = string
# Renvoie/Resultat : texte nettoyé

def nettoyer_cv(texte):

    texte = re.sub(r'\n+', '\n', texte)
    texte = texte.strip()

    return texte


# Role : Permet de lire un fichier PDF et d'extraire son texte
# Arguments : chemin_pdf = string
# Renvoie/Resultat : texte contenu dans le PDF

def lire_fichier_cv(chemin_pdf):

    texte = ""

    try:

        reader = PdfReader(chemin_pdf)

        for page in reader.pages:

            contenu = page.extract_text()

            if contenu:
                texte = texte + contenu + "\n"

    except Exception as e:

        print("Erreur lors de la lecture du fichier :", chemin_pdf)

    return texte


# Role : Permet d'afficher la progression du traitement
# Arguments : index = integer, total = integer, debut = time
# Renvoie/Resultat : barre de progression affichée

def barre_progression(index, total, debut):

    progression = index / total
    taille_barre = int(40 * progression)

    temps_ecoule = time.time() - debut

    if index > 0:
        temps_restant = (temps_ecoule / index) * (total - index)
    else:
        temps_restant = 0

    print(
        "\rProgression : [" +
        "#" * taille_barre +
        "-" * (40 - taille_barre) +
        "] " +
        str(index) + "/" + str(total) +
        " | Temps restant estimé : " +
        str(int(temps_restant)) + "s",
        end=""
    )


# Role : Permet de convertir tous les fichiers PDF en TXT
# Arguments : aucun
# Renvoie/Resultat : fichiers TXT créés dans le dossier cv_txt

def convertir_dossier():

    # chemin du dossier racine
    base_dir = os.path.dirname(os.path.dirname(__file__))

    pdf_dir = os.path.join(base_dir, "CV_pdf")
    txt_dir = os.path.join(base_dir, "CV_txt")

    if not os.path.exists(txt_dir):

        os.makedirs(txt_dir)

    fichiers_pdf = []

    for fichier in os.listdir(pdf_dir):

        if fichier.lower().endswith(".pdf"):
            fichiers_pdf.append(fichier)

    total = len(fichiers_pdf)

    if total == 0:

        print("Aucun fichier PDF trouvé")
        return

    debut = time.time()

    for i, fichier in enumerate(fichiers_pdf, 1):

        chemin_pdf = os.path.join(pdf_dir, fichier)

        contenu_cv = lire_fichier_cv(chemin_pdf)

        contenu_cv = nettoyer_cv(contenu_cv)

        nom_txt = os.path.splitext(fichier)[0] + ".txt"

        chemin_txt = os.path.join(txt_dir, nom_txt)

        with open(chemin_txt, "w", encoding="utf-8") as f:

            f.write(contenu_cv)

        barre_progression(i, total, debut)

    print("\nConversion terminée")


#------------------------------------------------
# Programme principal
#------------------------------------------------

convertir_dossier()