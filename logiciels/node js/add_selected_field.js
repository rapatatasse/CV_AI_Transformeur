const fs = require('fs');

function addSelectedField() {
    console.log("Ajout du champ 'selected' à chaque personne dans BD.json...");
    
    // Lire le fichier BD.json
    const bdData = JSON.parse(fs.readFileSync('BD.json', 'utf8'));
    
    // Ajouter le champ "selected" à chaque personne
    const updatedData = bdData.map(person => ({
        ...person,
        selected: false
    }));
    
    // Sauvegarder les modifications
    fs.writeFileSync('BD.json', JSON.stringify(updatedData, null, 2), 'utf8');
    
    console.log(`Champ 'selected' ajouté à ${updatedData.length} personnes`);
    console.log("Opération terminée!");
}

// Exécuter la fonction
addSelectedField();
