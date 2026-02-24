# Structuration du projet Node.js MVC

## Objectif

Application Node.js en architecture MVC affichant la liste des personnes contenues dans `BD.json` dans une vue unique avec filtres et barre de recherche via DataTables.

## Arborescence

- `app.js`
  - Point d'entrée de l'application Express.
  - Configure le moteur de vue EJS, les fichiers statiques et les routes.

- `package.json`
  - Métadonnées du projet.
  - Dépendances principales :
    - `express` : framework HTTP.
    - `ejs` : moteur de templates pour les vues.

- `BD.json`
  - Fichier de données contenant la liste des personnes.

- `models/`
  - `personModel.js`
    - Lit le fichier `BD.json` et renvoie la liste des personnes.

- `controllers/`
  - `personController.js`
    - Récupère les données depuis le modèle.
    - Passe les personnes à la vue `index`.

- `routes/`
  - `personRoutes.js`
    - Route `GET /` qui appelle le contrôleur `listPersons`.

- `views/`
  - `index.ejs`
    - Vue principale.
    - Affiche un tableau HTML des personnes.
    - Intègre DataTables (via CDN) pour la recherche, le tri et la pagination.

- `public/`
  - `css/styles.css`
    - Styles de base pour la page et le tableau.
  - `js/main.js`
    - Fichier prévu pour du JavaScript additionnel côté client si nécessaire.

## Fonctionnement

1. L'utilisateur accède à `http://localhost:3000/`.
2. La route `/` est gérée par `personRoutes.js`.
3. Le contrôleur `personController.js` appelle `personModel.getAllPersons()`.
4. Le modèle lit `BD.json` et renvoie un tableau d'objets.
5. Le contrôleur rend la vue `index.ejs` avec la liste des personnes.
6. DataTables (JS côté client) ajoute la barre de recherche, les filtres (tri, pagination) sur le tableau.

## Installation et exécution

Dans le dossier `logiciels/node js` :

```bash
npm install
npm start
```

Puis ouvrir le navigateur sur :

```text
http://localhost:3000/
```
