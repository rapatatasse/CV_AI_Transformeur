const fs = require('fs');
const path = require('path');

const dataPath = path.join(__dirname, '..', 'BD.json');

function getAllPersons() {
  const raw = fs.readFileSync(dataPath, 'utf8');
  return JSON.parse(raw);
}

module.exports = {
  getAllPersons,
};
