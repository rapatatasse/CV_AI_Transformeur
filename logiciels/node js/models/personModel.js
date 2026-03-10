const fs = require('fs');
const path = require('path');

const dataPath = path.join(__dirname, '..', 'BD.json');
const importPath = path.join(__dirname, '..', 'import.json');

function getAllPersons() {
  const raw = fs.readFileSync(dataPath, 'utf8');
  return JSON.parse(raw);
}

function importFromImportFile() {
  // Lire les données à importer
  const importData = JSON.parse(fs.readFileSync(importPath, 'utf8'));
  const bdData = getAllPersons();
  
  // Créer un Set des emails existants
  const existingEmails = new Set(bdData.map(person => person.email));
  
  // Filtrer les doublons et ajouter le champ selected
  const newEntries = importData
    .filter(person => !existingEmails.has(person.email))
    .map(person => ({
      ...person,
      selected: false
    }));
  
  const duplicates = importData.filter(person => existingEmails.has(person.email));
  
  // Ajouter les nouvelles entrées
  const updatedBD = [...bdData, ...newEntries];
  
  // Sauvegarder les changements
  fs.writeFileSync(dataPath, JSON.stringify(updatedBD, null, 2), 'utf8');
  fs.writeFileSync(importPath, JSON.stringify([], null, 2), 'utf8');
  
  return {
    imported: newEntries.length,
    duplicates: duplicates.length,
    total: importData.length
  };
}

module.exports = {
  getAllPersons,
  importFromImportFile,
};
