const express = require('express');
const path = require('path');

const personRoutes = require('./routes/personRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Vue
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Fichiers statiques
app.use(express.static(path.join(__dirname, 'public')));

// Routes
app.use('/', personRoutes);

app.listen(PORT, () => {
  console.log(`Serveur démarré sur http://localhost:${PORT}`);
});
