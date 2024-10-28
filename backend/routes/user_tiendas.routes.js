const express = require('express');
const router = express.Router();
const userTiendasController = require('../controllers/user_tiendas.controller');

// Ruta para obtener tiendas para el usuario
router.get('/', userTiendasController.getTiendasUsuario);

module.exports = router;
