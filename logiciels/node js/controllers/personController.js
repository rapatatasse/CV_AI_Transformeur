const personModel = require('../models/personModel');

function listPersons(req, res) {
  const persons = personModel.getAllPersons();
  res.render('index', { persons });
}

function importData(req, res) {
  try {
    const result = personModel.importFromImportFile();
    res.json({ 
      success: true, 
      message: `Importation réussie: ${result.imported} nouvelles entrées ajoutées, ${result.duplicates} doublons ignorés.`,
      result 
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Erreur lors de l\'importation: ' + error.message 
    });
  }
}

function saveSelection(req, res) {
  try {
    const { selections } = req.body;
    const result = personModel.updateSelections(selections);
    res.json({ 
      success: true, 
      message: `Sélection sauvegardée: ${result.updated} personnes mises à jour.`,
      result 
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Erreur lors de la sauvegarde: ' + error.message 
    });
  }
}

module.exports = {
  listPersons,
  importData,
  saveSelection,
};
