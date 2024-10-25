// backend/routes/productos.routes.js

const express = require('express');
const router = express.Router();

// IMPORTACIÓN DEL CONTROLADOR
// Asegúrate de importar el controlador de productos correctamente
const productosController = require('../controllers/productos.controller');

// DEFINICIÓN DE RUTAS

// Ruta para obtener todos los productos
router.get('/', productosController.getProductos);

// Ruta para agregar un nuevo producto
router.post('/', productosController.addProducto);

// Ruta para actualizar un producto existente
router.put('/:id_producto', productosController.updateProducto);

// Ruta para eliminar un producto por su ID
router.delete('/:id_producto', productosController.deleteProducto);

// EXPORTAR RUTAS
module.exports = router;
