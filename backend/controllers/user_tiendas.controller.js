const sql = require('mssql');
const config = require('../config/db.config');

// Obtener todas las tiendas para el usuario
async function getTiendasUsuario(req, res) {
  try {
    let pool = await sql.connect(config);
    let result = await pool.request().query("SELECT * FROM Tiendas");
    res.json(result.recordset);
  } catch (err) {
    console.error("Error en getTiendasUsuario:", err);
    res.status(500).send("Error al obtener las tiendas");
  }
}

module.exports = {
  getTiendasUsuario,
};
