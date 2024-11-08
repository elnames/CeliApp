require('dotenv').config();
const express = require('express');
const cors = require('cors');
const errorHandler = require('./middleware/errorHandler');
const rateLimit = require('express-rate-limit');

const app = express();

// Rate Limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100 // límite de 100 peticiones por ventana
});

app.use(limiter);
app.use(cors());
app.use(express.json());

// Rutas
app.use('/api/productos', require('./routes/productos.routes'));
app.use('/api/tiendas', require('./routes/tiendas.routes'));
app.use('/api/favoritos', require('./routes/favoritos.routes'));

// Manejo de errores
app.use(errorHandler);

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Servidor corriendo en el puerto ${PORT}`);
});
