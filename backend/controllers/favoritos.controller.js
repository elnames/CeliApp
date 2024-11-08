const config = require('../config/db.config');
const sql = require('mssql');

// Función para conectar a la base de datos
async function getConnection() {
    try {
        const pool = await sql.connect(config);
        return pool;
    } catch (error) {
        console.error('Error al conectar con la base de datos:', error);
        throw error;
    }
}

const favoritosController = {
  // Obtener todos los favoritos de un usuario
  getFavoritosByUser: async (req, res) => {
    try {
      const pool = await getConnection();
      const { userId } = req.params;
      const result = await pool.request()
        .input('userId', sql.VarChar, userId)
        .query(`
          SELECT p.* 
          FROM dbo.Favoritos f 
          JOIN dbo.Productos p ON f.id_prod = p.id_producto 
          WHERE f.id_us = @userId
        `);
      res.json(result.recordset);
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: "Error al obtener favoritos" });
    }
  },

  // Verificar si un producto es favorito
  checkFavorito: async (req, res) => {
    try {
      const pool = await getConnection();
      const { userId, productId } = req.params;
      const result = await pool.request()
        .input('userId', sql.VarChar, userId)
        .input('productId', sql.Int, productId)
        .query('SELECT * FROM dbo.Favoritos WHERE id_us = @userId AND id_prod = @productId');
      res.json(result.recordset.length > 0);
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: "Error al verificar favorito" });
    }
  },

  // Agregar a favoritos
  addFavorito: async (req, res) => {
    try {
      const pool = await getConnection();
      const { id_us, id_prod } = req.body;
      
      const existingFavorite = await pool.request()
        .input('userId', sql.VarChar, id_us)
        .input('productId', sql.Int, id_prod)
        .query('SELECT * FROM dbo.Favoritos WHERE id_us = @userId AND id_prod = @productId');

      if (existingFavorite.recordset.length > 0) {
        return res.status(400).json({ message: "Ya está en favoritos" });
      }

      await pool.request()
        .input('userId', sql.VarChar, id_us)
        .input('productId', sql.Int, id_prod)
        .query('INSERT INTO dbo.Favoritos (id_us, id_prod, creado) VALUES (@userId, @productId, GETDATE())');
      
      res.status(201).json({ message: "Agregado a favoritos" });
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: "Error al agregar favorito" });
    }
  },

  // Eliminar de favoritos
  removeFavorito: async (req, res) => {
    try {
      const pool = await getConnection();
      const { userId, productId } = req.params;
      await pool.request()
        .input('userId', sql.VarChar, userId)
        .input('productId', sql.Int, productId)
        .query('DELETE FROM dbo.Favoritos WHERE id_us = @userId AND id_prod = @productId');
      res.json({ message: "Eliminado de favoritos" });
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: "Error al eliminar favorito" });
    }
  }
};

module.exports = favoritosController; 