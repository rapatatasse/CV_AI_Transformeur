# Convertisseur de CV vers JSON avec LM Studio

Ce programme extrait automatiquement les informations d'un CV au format texte et les convertit en fichier JSON structuré en utilisant une IA locale via LM Studio.

## Prérequis

### 1. Installer LM Studio
- Téléchargez et installez LM Studio depuis [https://lmstudio.ai](https://lmstudio.ai)
- Lancez LM Studio une fois installé

### 2. Installer Python
- Assurez-vous d'avoir Python 3.8 ou plus
- Installez la bibliothèque OpenAI :
```bash
pip install openai
```

## Configuration

### 1. Choisir et télécharger un modèle
Dans LM Studio :
- Allez dans l'onglet "Search"
- Recherchez un modèle léger compatible (ex: `mistral`, `llama`, `phi`)
- Téléchargez un modèle recommandé :
  - `Mistral-7B-Instruct-v0.2` (bon rapport performance/poids)
  - `Phi-3-mini-4k-instruct` (très léger)
  - `Qwen2.5-3B-Instruct` (compact et efficace)

### 2. Mettre à jour le nom du modèle
Modifiez la ligne 16 du fichier `Appel LM Studio.py` :
```python
model_name = "nom_exact_du_modele_choisi" 
```
Remplacez `"ministral-3-3b-reasoning-2512"` par le nom exact du modèle que vous avez téléchargé.

### 3. Préparer votre CV
- Placez votre CV au format texte (.txt) dans le dossier du projet
- Modifiez la ligne 76 du script pour indiquer le chemin de votre fichier :
```python
chemin_cv = r"P:\CHEMIN\VERS\VOTRE_CV.txt"
```

## Utilisation

### Étape 1 : Démarrer LM Studio
1. Lancez LM Studio
2. Allez dans l'onglet "Chat"
3. Sélectionnez le modèle que vous avez téléchargé
4. Cliquez sur "Load Model"

### Étape 2 : Lancer le script
Exécutez le script Python :
```bash
python "Appel LM Studio.py"
```

### Étape 3 : Résultat
Le script va :
1. Charger le modèle IA
2. Démarrer le serveur local
3. Extraire les informations du CV
4. Créer un fichier `resultat_cv.json` avec les données structurées

## Structure du JSON de sortie

```json
{
  "nom": "NOM",
  "prénom": "Prénom",
  "email": "email@example.com",
  "téléphone": "0612345678",
  "ville": "Paris",
  "poste_recherche": "Développeur Python",
  "compétences": ["Python", "JavaScript", "SQL"],
  "expérience": ["Poste 1 - Entreprise A", "Poste 2 - Entreprise B"],
  "formation": ["Diplôme 1 - École X", "Diplôme 2 - Université Y"]
}
```

## Dépannage

### Erreur "Failed to load model"
- Vérifiez que le modèle est bien téléchargé dans LM Studio
- Vérifiez que le nom du modèle dans le script correspond exactement
- Essayez avec un modèle plus léger si vous avez des problèmes de RAM

### Erreur "Server connection failed"
- Assurez-vous que LM Studio est bien lancé
- Vérifiez que le port 1234 n'est pas utilisé par une autre application
- Redémarrez LM Studio si nécessaire

### Erreur JSON invalide
- Vérifiez que votre CV est bien au format texte simple
- Essayez avec un modèle plus performant pour une meilleure extraction

### Problèmes de performance
- Fermez les autres applications si votre ordinateur manque de RAM
- Utilisez un modèle plus léger (3B paramètres ou moins)
- Réduisez la longueur de votre CV texte

## Notes importantes

- Le script nécessite une connexion internet pour le premier téléchargement du modèle
- Le traitement peut prendre plusieurs minutes selon la puissance de votre ordinateur
- Le serveur LM Studio reste actif après l'exécution du script
- Pour arrêter le serveur manuellement : fermez LM Studio ou décommentez la dernière ligne du script