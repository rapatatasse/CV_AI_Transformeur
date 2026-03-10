const express = require('express');
const router = express.Router();

const personController = require('../controllers/personController');

router.get('/', personController.listPersons);
router.post('/import', personController.importData);

module.exports = router;
