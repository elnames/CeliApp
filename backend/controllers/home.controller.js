// home.controller.js

const db = require('../config/db.config'); // Asegúrate de tener configurada la conexión a la base de datos

// Obtener productos y tiendas para el Home
exports.getHomeData = async (req, res) => {
  try {
    // Consulta para obtener productos
    const [productos] = await db.execute('SELECT * FROM Productos');

    // Consulta para obtener tiendas
    const [tiendas] = await db.execute('SELECT * FROM Tiendas');

    // Enviar los datos en la respuesta
    res.status(200).json({
      productos: productos,
      tiendas: tiendas,
    });
  } catch (error) {
    console.error("Error al obtener los datos del home:", error);
    res.status(500).json({ error: 'Error al obtener los datos del home' });
  }
};
