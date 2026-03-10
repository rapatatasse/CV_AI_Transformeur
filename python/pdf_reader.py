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
    """Nettoie le texte :
       - supprime lignes vides multiples
       - supprime tabulations et espaces inutiles
       - supprime symboles de puce au début des lignes (●, *, -)
       - met titres en majuscules et en gras
    """
    # Supprime retours chariot et tabulations
    texte = re.sub(r'[\r\t]', '', texte)

    # Supprime multiples espaces
    texte = re.sub(r'[ ]{2,}', ' ', texte)

    # Supprime lignes vides multiples
    texte = re.sub(r'\n+', '\n', texte)

    # Supprime les symboles de puce en début de ligne
    texte = re.sub(r'^[\s●\*\-]+', '', texte, flags=re.MULTILINE)

    texte = texte.strip()

    # Majuscules et gras pour les titres fréquents
    titres = ["PROFIL", "EXPERIENCES", "COORDONNEES", "BOITE DE COMPETENCES"]
    for t in titres:
        texte = re.sub(t, f"**{t.upper()}**", texte, flags=re.IGNORECASE)

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
    # Récupère le dossier du script
    dossier_script = os.path.dirname(os.path.abspath(__file__))  # dossier python
    base_dir = os.path.dirname(dossier_script)                   # remonte à CV_AI_Transformeur

    # Définition des dossiers PDF et TXT
    pdf_dir = os.path.join(base_dir, "CV_pdf")
    txt_dir = os.path.join(base_dir, "CV_txt")

    # Vérifie que le dossier PDF existe
    if not os.path.exists(pdf_dir):
        print(f"Dossier {pdf_dir} introuvable !")
        return

    # Création du dossier txt si besoin
    if not os.path.exists(txt_dir):
        os.makedirs(txt_dir)

    # Liste des fichiers PDF
    fichiers_pdf = [f for f in os.listdir(pdf_dir) if f.lower().endswith(".pdf")]
    total = len(fichiers_pdf)
    if total == 0:
        print("Aucun fichier PDF trouvé")
        return

    # Demande confirmation pour suppression des PDF (Windows uniquement)
    supprimer_pdf = False
    if os.name == "nt":
        supprimer_pdf = confirmer_popup("Voulez-vous supprimer les fichiers PDF après conversion ?")

    debut = time.time()
    convertis = 0

    for i, fichier in enumerate(fichiers_pdf, 1):
        nom_txt = os.path.splitext(fichier)[0] + ".txt"
        chemin_txt = os.path.join(txt_dir, nom_txt)

        # Vérifie si le fichier TXT existe déjà
        if os.path.exists(chemin_txt):
            print(f"\nLe fichier {nom_txt} existe déjà, conversion ignorée.")
            continue

        chemin_pdf = os.path.join(pdf_dir, fichier)
        contenu_cv = lire_fichier_cv(chemin_pdf)

        # Vérifie si du texte a été extrait
        if not contenu_cv:
            print(f"\nErreur : impossible d'extraire le texte de {fichier}")
            continue

        # Nettoyage du texte
        contenu_cv = nettoyer_cv(contenu_cv)

        # Création du fichier TXT
        with open(chemin_txt, "w", encoding="utf-8") as f:
            f.write(contenu_cv)

        # Supprimer le PDF si confirmé
        if supprimer_pdf:
            os.remove(chemin_pdf)

        convertis += 1
        # Affiche la barre de progression
        barre_progression(i, total, debut)

    print(f"\nConversion terminée ({convertis} nouveau(x) fichier(s) créé(s))")

#------------------------------------------------
# Programme principal
#------------------------------------------------
convertir_dossier()