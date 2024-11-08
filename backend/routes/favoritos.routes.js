const express = require('express');
const router = express.Router();
const favoritosController = require('../controllers/favoritos.controller');

// Obtener todos los favoritos de un usuario
router.get('/:userId', favoritosController.getFavoritosByUser);

// Verificar si un producto es favorito
router.get('/:userId/:productId', favoritosController.checkFavorito);

// Agregar un favorito
router.post('/', favoritosController.addFavorito);

// Eliminar un favorito
router.delete('/:userId/:productId', favoritosController.removeFavorito);

module.exports = router; 