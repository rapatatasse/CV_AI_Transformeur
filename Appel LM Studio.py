import subprocess
import time
import json
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
    
    prompt_cv = f"""

Tu es un outil d'extraction d'informations depuis des CV en .txt

Objectif :
Extraire les informations principales du CV et les transformer en JSON dans un document en .json

Colonnes obligatoires :
{json_structure}

Règles :
- Ne rien inventer
- Si une information est absente, laisser vide
- Nettoyer les retours à la ligne
- Générer uniquement le JSON
- Ne pas écrire de texte autour
-Le nom doit être mis en majuscule et le prénom doit avoir sa première lettre en majuscule

    Texte du CV :
    {texte_cv}
    """
    
    response = client.chat.completions.create(
        model=model_name,
        messages=[{"role": "user", "content": prompt_cv}],
        temperature=0.1 # Basse température pour plus de rigueur sur le JSON
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

# --- (Optionnel) ÉTAPE 3 : Nettoyage ---
# Si tu veux fermer le serveur à la fin du script
# server_process.terminate()