import os
import fitz  

def pdf_to_text(pdf_path):
    """Ouvre un PDF et extrait tout son texte."""
    doc = fitz.open(pdf_path)
    texte = ""
    for page in doc:
        texte += page.get_text()
    return texte

def parcourir_pdfs_et_extraire_texte(dossier_pdf):
    """Parcourt tous les fichiers PDF dans le dossier donné et extrait leur texte."""
    resultats = {}
    for fichier in os.listdir(dossier_pdf):
        if fichier.lower().endswith(".pdf"):
            chemin_complet = os.path.join(dossier_pdf, fichier)
            print(f"Traitement de : {fichier}")
            texte = pdf_to_text(chemin_complet)
            resultats[fichier] = texte
            print(f"Extrait (100 premiers caractères) :\n{texte[:100]}...\n")
    return resultats
    

if __name__ == "__main__":
    dossier = "CV_pdf"  # Change ce chemin selon ton dossier réel
    tous_les_textes = parcourir_pdfs_et_extraire_texte(dossier)
    print(f"Nombre total de PDF traités : {len(tous_les_textes)}")