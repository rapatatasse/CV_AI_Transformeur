# Partie PYTHON


objectif: traiter automatiquement des fichiers PDF et de générer un JSON centralisé exploitable pour Hugo. 



1. **Réception des fichiers PDF**  
   Les utilisateurs importent un ou plusieurs fichiers PDF.

2. **Conversion en texte**  
   Chaque PDF est lu et transformé en texte.

3. **Traitement par Mathyas**  
   Pour chaque fichier texte, des calculs ou analyses sont effectués avec Mathyas.

4. **Envoi à LMStudio**  
   Le texte traité est envoyé à LMStudio, qui renvoie un JSON structuré.

5. **Centralisation des résultats**  
   Tous les JSON obtenus sont regroupés dans un seul fichier.

6. **Interface utilisateur**  
   Une interface permet de :
   - Suivre l’avancement du traitement
   - Choisir quels fichiers envoyer à LMStudio
   - Visualiser les résultats étape par étape

---

### ⚙️ Fonctionnalités principales

- Conversion PDF → texte  
- Traitement du texte avec MathAS  
- Communication avec LMStudio pour obtenir des JSON  
- Centralisation de tous les résultats dans un fichier unique  
- Interface pour suivre et contrôler le processus  

---

### importants

- L’utilisateur peut choisir quels fichiers traiter et envoyer.  
- Chaque étape est visible dans l’interface pour plus de transparence.  
- Le projet est pensé pour être modulaire et extensible, afin de s’adapter à de futurs besoins.