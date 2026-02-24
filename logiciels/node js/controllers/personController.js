const personModel = require('../models/personModel');

function listPersons(req, res) {
  const persons = personModel.getAllPersons();
  res.render('index', { persons });
}

module.exports = {
  listPersons,
};
