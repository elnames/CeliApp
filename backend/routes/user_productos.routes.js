const express = require('express');
const router = express.Router();
const userProductosController = require('../controllers/user_productos.controller');

// Ruta para obtener productos para el usuario
router.get('/', userProductosController.getProductosUsuario);

module.exports = router;
