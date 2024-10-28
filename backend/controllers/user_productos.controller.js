const sql = require('mssql');
const config = require('../config/db.config');

// Obtener todos los productos para el usuario
async function getProductosUsuario(req, res) {
  try {
    let pool = await sql.connect(config);
    let result = await pool.request().query("SELECT * FROM Productos");
    res.json(result.recordset);
  } catch (err) {
    console.error("Error en getProductosUsuario:", err);
    res.status(500).send("Error al obtener los productos");
  }
}

module.exports = {
  getProductosUsuario,
};
