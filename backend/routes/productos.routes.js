// backend/routes/productos.routes.js

const express = require('express');
const router = express.Router();

// IMPORTACIÓN DEL CONTROLADOR
// Asegúrate de importar el controlador de productos correctamente
const productosController = require('../controllers/productos.controller');

// DEFINICIÓN DE RUTAS

// Rutas básicas
router.get('/', productosController.getProductos);
router.post('/', productosController.addProducto);
router.put('/:id_producto', productosController.updateProducto);
router.delete('/:id_producto', productosController.deleteProducto);

// Ruta para categorías
router.get('/categorias', productosController.getCategorias);

// EXPORTAR RUTAS
module.exports = router;
