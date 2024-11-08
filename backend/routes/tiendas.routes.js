const express = require('express');
const router = express.Router();
const tiendasController = require('../controllers/tiendas.controller');

// Ruta para obtener las regiones únicas
router.get('/regiones', tiendasController.getRegiones);

// Rutas generales
router.get('/', tiendasController.getTiendas);
router.post('/', tiendasController.addTienda);
router.put('/:id_tienda', tiendasController.updateTienda);
router.delete('/:id_tienda', tiendasController.deleteTienda);

module.exports = router;
