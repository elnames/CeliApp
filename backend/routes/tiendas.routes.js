const express = require('express');
const router = express.Router();
const tiendasController = require('../controllers/tiendas.controller');

router.get('/', tiendasController.getTiendas);
router.post('/', tiendasController.addTienda);
router.put('/:id_tienda', tiendasController.updateTienda);
router.delete('/:id_tienda', tiendasController.deleteTienda);

module.exports = router;
