// home.routes.js

const express = require('express');
const router = express.Router();
const homeController = require('../controllers/home.controller');

// Ruta para obtener los datos del home
router.get('/data', homeController.getHomeData);

module.exports = router;
