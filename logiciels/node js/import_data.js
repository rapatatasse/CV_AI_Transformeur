const fs = require('fs');

// Lire les fichiers JSON
function readJSONFile(filePath) {
    try {
        const data = fs.readFileSync(filePath, 'utf8');
        return JSON.parse(data);
    } catch (error) {
        console.error(`Erreur lecture du fichier ${filePath}:`, error.message);
        return [];
    }
}

// Écrire dans un fichier JSON
function writeJSONFile(filePath, data) {
    try {
        fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf8');
        console.log(`Fichier ${filePath} mis à jour avec succès`);
    } catch (error) {
        console.error(`Erreur écriture du fichier ${filePath}:`, error.message);
    }
}

// Fonction principale d'importation
function importData() {
    console.log("Début de l'importation des données...");
    
    // Lire les données
    const importData = readJSONFile('import.json');
    const bdData = readJSONFile('BD.json');
    
    console.log(`Données à importer: ${importData.length} entrées`);
    console.log(`Données existantes dans BD: ${bdData.length} entrées`);
    
    // Créer un Set des emails existants pour détecter les doublons
    const existingEmails = new Set(bdData.map(person => person.email));
    
    // Filtrer les doublons
    const newEntries = importData.filter(person => !existingEmails.has(person.email));
    const duplicates = importData.filter(person => existingEmails.has(person.email));
    
    console.log(`Nouvelles entrées à ajouter: ${newEntries.length}`);
    console.log(`Doublons détectés: ${duplicates.length}`);
    
    if (duplicates.length > 0) {
        console.log("Doublons (emails déjà existants):");
        duplicates.forEach(person => {
            console.log(`- ${person.email} (${person.nom} ${person.prénom})`);
        });
    }
    
    // Ajouter les nouvelles entrées à la base de données
    const updatedBD = [...bdData, ...newEntries];
    
    // Mettre à jour BD.json
    writeJSONFile('BD.json', updatedBD);
    
    // Vider import.json après importation réussie
    if (importData.length > 0) {
        writeJSONFile('import.json', []);
        console.log("Fichier import.json vidé après importation réussie");
    }
    
    console.log("Importation terminée!");
}

// Exécuter la fonction
importData();
