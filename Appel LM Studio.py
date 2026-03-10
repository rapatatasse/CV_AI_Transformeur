import subprocess
import time
import json
import os
import re
from openai import OpenAI

def run_lms_command(command):
    """Exécute une commande lms et affiche la sortie."""
    print(f"Exécution : {command}...")
    result = subprocess.run(command, shell=True, capture_output=True, text=True, encoding='utf-8', errors='replace')
    if result.returncode != 0:
        print(f"Erreur : {result.stderr}")
    return result.stdout

# --- ÉTAPE 1 : Configuration du modèle et du serveur ---
# Remplace 'ton-modele' par le nom exact affiché dans 'lms ls'
model_name = "ministral-3-3b-reasoning-2512" 

# Charger le modèle en mémoire
print(f"Chargement du modèle {model_name}...")
load_result = run_lms_command(f"lms load {model_name}")
if "insufficient system resources" in load_result.lower() or "overload" in load_result.lower():
    print("Attention: Le modèle n'a pas pu être chargé en raison de ressources insuffisantes.")
    print("Essayez avec un modèle plus léger ou ferrez d'autres applications.")

# Démarrer le serveur (on utilise Popen car le serveur doit rester ouvert en arrière-plan)
print("Démarrage du serveur local...")
server_process = subprocess.Popen("lms server start", shell=True)

# Laisser le temps au serveur de s'initialiser (2-3 secondes suffisent généralement)
time.sleep(3)

# --- ÉTAPE 2 : Communication avec l'IA ---
client = OpenAI(base_url="http://localhost:1234/v1", api_key="lm-studio")

def extraire_cv(texte_cv):
    json_structure = '''{
  "nom": "",
  "prénom": "",
  "email": "",
  "téléphone": "",
  "ville": "",
  "poste_recherche": "",
  "compétences": [],
  "expérience": [],
  "formation": []
}'''
    
    prompt_cv = f"""Tu es un extracteur de données STRICT. Retourne EXACTEMENT ce JSON avec les informations du CV. PAS DE TEXTE AUTOUR.

{json_structure}

INSTRUCTIONS IMPÉRATIVES :
1. Utilise EXACTEMENT cette structure, ne change AUCUN nom de champ
2. Si information absente → "" (chaîne vide)
3. Compétences : liste de strings simples ["comp1", "comp2"]
4. Expérience : liste d'objets avec "année" et "description"
5. Formation : liste de strings ["formation1"]
6. Nom en MAJUSCULE, Prénom avec majuscule première lettre
7. RETOURNE UNIQUEMENT LE JSON - NI EXPlications NI SALUTATIONS

CV à traiter :
{texte_cv}

JSON requis :"""
    
    response = client.chat.completions.create(
        model=model_name,
        messages=[{"role": "user", "content": prompt_cv}],
        temperature=0 # Basse température pour plus de rigueur sur le JSON
    )
    return response.choices[0].message.content

# --- LECTURE DU FICHIER CV ---
def lire_fichier_cv(chemin_fichier):
    """Lit le contenu d'un fichier CV."""
    with open(chemin_fichier, 'r', encoding='utf-8') as f:
        return f.read()

# Remplacez "votre_cv.txt" par le chemin de votre fichier
chemin_cv = r"P:\PROFIL.txt"  # METTRE VOTRE CHEMIN ICI
contenu_cv = lire_fichier_cv(chemin_cv)
resultat = extraire_cv(contenu_cv)
print("\nRésultat de l'extraction :")
print(resultat)

# Sauvegarder le résultat dans un fichier JSON
try:
    # Nettoyer le résultat pour ne garder que le JSON pur
    resultat_clean = resultat.strip()
    
    # 1. Enlever toutes les balises markdown
    resultat_clean = re.sub(r'```json\s*', '', resultat_clean)
    resultat_clean = re.sub(r'```\s*', '', resultat_clean)
    
    # 2. Enlever les explications avant/après le JSON
    # Chercher le début du JSON
    debut_json = resultat_clean.find('{')
    if debut_json != -1:
        resultat_clean = resultat_clean[debut_json:]
    
    # 3. Reconstruire le JSON proprement en comptant les accolades
    if resultat_clean.startswith('{'):
        niveau = 0
        fin_json = -1
        
        for i, char in enumerate(resultat_clean):
            if char == '{':
                niveau += 1
            elif char == '}':
                niveau -= 1
                if niveau == 0:
                    fin_json = i
                    break
        
        if fin_json != -1:
            resultat_clean = resultat_clean[:fin_json + 1]
    
    # 4. Nettoyage final des caractères problématiques
    resultat_clean = resultat_clean.strip()
    
    # 5. Corriger les erreurs JSON courantes
    # Remplacer les guillemets simples par des guillemets doubles
    resultat_clean = re.sub(r"'([^']*)':", r'"\1":', resultat_clean)
    resultat_clean = re.sub(r": '([^']*)'", r': "\1"', resultat_clean)
    
    # Enlever les virgules avant les fermetures
    resultat_clean = re.sub(r',(\s*[}\]])', r'\1', resultat_clean)
    
    # Afficher ce qui va être sauvegardé pour vérification
    print("🔍 JSON nettoyé qui va être sauvegardé :")
    print("--- Début du JSON nettoyé ---")
    print(resultat_clean)
    print("--- Fin du JSON nettoyé ---")
    
    # Parser le JSON pour valider qu'il est correct
    try:
        donnees_json = json.loads(resultat_clean)
        print("✅ JSON valide, parsing réussi")
    except json.JSONDecodeError as json_err:
        print(f"❌ Erreur de parsing JSON : {json_err}")
        print("Position de l'erreur :", json_err.pos if hasattr(json_err, 'pos') else "inconnue")
        # Afficher le caractère autour de l'erreur
        if hasattr(json_err, 'pos') and json_err.pos < len(resultat_clean):
            start = max(0, json_err.pos - 20)
            end = min(len(resultat_clean), json_err.pos + 20)
            print(f"Contexte de l'erreur : ...{resultat_clean[start:end]}...")
        raise  # Relancer l'erreur pour aller dans le bloc except principal
    
    # Écrire dans un fichier JSON avec chemin absolu
    nom_fichier_sortie = r"P:\CV_AI_Transformeur\resultat_cv.json"
    print(f"Tentative de sauvegarde dans : {nom_fichier_sortie}")
    
    with open(nom_fichier_sortie, 'w', encoding='utf-8') as f:
        json.dump(donnees_json, f, ensure_ascii=False, indent=2)
    
    print(f"✅ Résultat sauvegardé avec succès dans : {nom_fichier_sortie}")
    print(f"📁 Taille du fichier : {os.path.getsize(nom_fichier_sortie)} octets")
    
except json.JSONDecodeError as e:
    print(f"\n❌ Erreur JSON : {e}")
    print("Contenu brut reçu :", repr(resultat))
    
    # Sauvegarder le contenu brut quand même pour débogage
    nom_fichier_debug = r"P:\CV_AI_Transformeur\debug_brut.txt"
    with open(nom_fichier_debug, 'w', encoding='utf-8') as f:
        f.write(resultat)
    print(f"📝 Contenu brut sauvegardé dans : {nom_fichier_debug}")
    
except Exception as e:
    print(f"\n❌ Erreur inattendue : {e}")
    print("Type d'erreur :", type(e).__name__)

# --- (Optionnel) ÉTAPE 3 : Nettoyage ---
# Si tu veux fermer le serveur à la fin du script
server_process.terminate()