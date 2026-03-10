## Objectif du projet
Ce projet a pour but de créer un **environnement complet de traitement de CV** en utilisant plusieurs technologies complémentaires : **Python, Node.js, LMStudio et Powershell.**

Le travail est pensé pour être réalisé **en équipe**, avec **une personne par technologie** afin de faciliter le développement et la maintenance.

L'objectif est d'assembler plusieurs briques logicielles afin de construire une **pipeline automatisée capable de transformer une collection de CV PDF en base de données exploitable via une interface web**.

---

## Fonctionnement général

Le programme permet de transformer des **CV au format PDF** en **données structurées** grâce à une **IA fonctionnant en local**.

Le workflow du projet est le suivant :

1. **Installation et orchestration**
   - Utilisation de **PowerShell** pour :
     - installer les logiciels nécessaires
     - automatiser le lancement des différents scripts

2. **Extraction du texte**
   - Utilisation de **Python** pour :
     - convertir les fichiers **PDF en texte (.txt)**
     - envoyer ces fichiers à **LM Studio**

3. **Analyse par IA locale**
   - **LM Studio** est utilisé pour :
     - exécuter un **modèle d'IA local**
     - analyser les fichiers texte
     - transformer les informations en **données structurées CSV**

4. **Interface web**
   - Utilisation de **Node.js** pour :
     - charger et traiter le fichier **CSV**
     - afficher les données dans une **interface HTML**
     - permettre la **recherche et le filtrage des CV**

---

## Technologies utilisées

- **PowerShell** — automatisation de l'installation et du lancement
- **Python** — traitement des fichiers PDF et préparation des données
- **LM Studio** — exécution d'un modèle d'IA local
- **Node.js** — backend du site web
- **HTML / JavaScript** — interface utilisateur
- **CSV** — format de stockage des données extraites

---

##  Finalité du projet

L'objectif final est de pouvoir :

- transformer **une base de CV PDF**
- en **base de données structurée**
- consultable facilement via **une interface web dynamique**

Cela permet de **rechercher, filtrer et analyser rapidement des profils candidats** sans traitement manuel.



