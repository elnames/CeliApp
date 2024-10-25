require('dotenv').config();
const express = require('express');
const cors = require('cors'); // Importar el paquete CORS
const productosRoutes = require('./routes/productos.routes');
const tiendasRoutes = require('./routes/tiendas.routes');
const bodyParser = require('body-parser');

const app = express();

// Middleware para habilitar CORS (permitir solicitudes de diferentes orígenes)
app.use(cors());

// Middleware para manejar JSON y URL-encoded
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Registrar rutas con diferentes prefijos para evitar conflictos
app.use('/api/productos', productosRoutes); // Rutas para productos
app.use('/api/tiendas', tiendasRoutes);     // Rutas para tiendas

// Definir el puerto desde el .env o usar 3000 por defecto
const PORT = process.env.PORT || 3000;

// Middleware
app.use(bodyParser.json());

// Levantar el servidor
app.listen(PORT, () => {
  console.log(`Servidor corriendo en el puerto ${PORT}`);
});




