#------------------------------------------------
# Import des librairies
#------------------------------------------------
import os
import re
import time
from pypdf import PdfReader
import ctypes  # Pour afficher une popup Windows

#------------------------------------------------
# Fonctions
#------------------------------------------------

def nettoyer_cv(texte):
    """Nettoie le texte : supprime lignes vides multiples, espaces inutiles, met titres en majuscules"""
    texte = re.sub(r'\r', '', texte)           # Supprime retours chariot
    texte = re.sub(r'\n+', '\n', texte)       # Supprime lignes vides multiples
    texte = texte.strip()
    
    # Majuscules pour les titres fréquents
    titres = ["PROFIL", "EXPERIENCES", "COORDONNEES", "BOITE DE COMPETENCES"]
    for t in titres:
        texte = re.sub(t, t.upper(), texte, flags=re.IGNORECASE)
    
    return texte

def lire_fichier_cv(chemin_pdf):
    """Lit un PDF et renvoie son texte"""
    texte = ""
    try:
        reader = PdfReader(chemin_pdf)
        for page in reader.pages:
            contenu = page.extract_text()
            if contenu:
                texte += contenu + "\n"
    except Exception as e:
        print(f"Erreur lors de la lecture du fichier : {chemin_pdf}\n{e}")
    return texte

def barre_progression(index, total, debut):
    """Affiche la barre de progression"""
    progression = index / total
    taille_barre = int(40 * progression)
    temps_ecoule = time.time() - debut
    temps_restant = int((temps_ecoule / index) * (total - index)) if index > 0 else 0

    print(
        f"\rProgression : [{'#' * taille_barre}{'-' * (40 - taille_barre)}] {index}/{total} | "
        f"Temps restant estimé : {temps_restant}s",
        end=""
    )

def confirmer_popup(message):
    """Affiche une popup Windows Oui/Non"""
    return ctypes.windll.user32.MessageBoxW(0, message, "Confirmation", 4) == 6  # 6 = Oui

#------------------------------------------------
# Conversion
#------------------------------------------------

def convertir_dossier():
    base_dir = os.path.dirname(os.path.dirname(__file__))
    pdf_dir = os.path.join(base_dir, "CV_pdf")
    txt_dir = os.path.join(base_dir, "CV_txt")

    if not os.path.exists(txt_dir):
        os.makedirs(txt_dir)

    fichiers_pdf = [f for f in os.listdir(pdf_dir) if f.lower().endswith(".pdf")]
    total = len(fichiers_pdf)
    if total == 0:
        print("Aucun fichier PDF trouvé")
        return

    # Demande confirmation pour suppression des PDF
    if confirmer_popup("Voulez-vous supprimer les fichiers PDF après conversion ?"):
        supprimer_pdf = True
    else:
        supprimer_pdf = False

    debut = time.time()
    for i, fichier in enumerate(fichiers_pdf, 1):
        chemin_pdf = os.path.join(pdf_dir, fichier)
        contenu_cv = lire_fichier_cv(chemin_pdf)
        contenu_cv = nettoyer_cv(contenu_cv)

        nom_txt = os.path.splitext(fichier)[0] + ".txt"
        chemin_txt = os.path.join(txt_dir, nom_txt)

        with open(chemin_txt, "w", encoding="utf-8") as f:
            f.write(contenu_cv)

        # Supprimer le PDF si confirmé
        if supprimer_pdf:
            os.remove(chemin_pdf)

        barre_progression(i, total, debut)

    print("\nConversion terminée")

#------------------------------------------------
# Programme principal
#------------------------------------------------
convertir_dossier()