const sql = require('mssql');
const config = require('../config/db.config');

// Obtener todas las tiendas
async function getTiendas(req, res) {
  try {
    let pool = await sql.connect(config);
    let result = await pool.request().query("SELECT * FROM Tiendas");
    res.json(result.recordset);
  } catch (err) {
    console.error("Error en getTiendas: ", err);
    res.status(500).send("Error al obtener las tiendas");
  }
}

// Agregar una nueva tienda
const addTienda = async (req, res) => {
  try {
    const { nombre, direccion, longitud, latitud } = req.body;
    const pool = await sql.connect(config);

    await pool.request()
      .input('Nombre', sql.NVarChar, nombre)
      .input('Direccion', sql.NVarChar, direccion)
      .input('Longitud', sql.Float, longitud)
      .input('Latitud', sql.Float, latitud)
      .query(`
        INSERT INTO Tiendas (nombre, direccion, longitud, latitud)
        VALUES (@Nombre, @Direccion, @Longitud, @Latitud)
      `);

    res.status(201).send("Tienda agregada exitosamente.");
  } catch (error) {
    console.error("Error en addTienda:", error);
    res.status(500).send("Error al agregar tienda");
  }
};

// Actualizar una tienda existente
const updateTienda = async (req, res) => {
  try {
    const { id_tienda } = req.params;
    const { nombre, direccion, longitud, latitud } = req.body;

    let pool = await sql.connect(config);
    let result = await pool.request()
      .input('id_tienda', sql.BigInt, id_tienda)
      .input('nombre', sql.NVarChar, nombre)
      .input('direccion', sql.NVarChar, direccion)
      .input('longitud', sql.Float, longitud)
      .input('latitud', sql.Float, latitud)
      .query(`
        UPDATE Tiendas
        SET nombre = @nombre,
            direccion = @direccion,
            longitud = @longitud,
            latitud = @latitud
        WHERE id_tienda = @id_tienda
      `);

    if (result.rowsAffected[0] > 0) {
      res.status(200).send("Tienda actualizada exitosamente.");
    } else {
      res.status(404).send("Tienda no encontrada. Verifica el ID");
    }
  } catch (err) {
    console.error("Error en updateTienda: ", err);
    res.status(500).send("Error al actualizar tienda");
  }
};

// Eliminar una tienda
const deleteTienda = async (req, res) => {
  try {
    const { id_tienda } = req.params;

    let pool = await sql.connect(config);
    let result = await pool.request()
      .input('id_tienda', sql.BigInt, id_tienda)
      .query('DELETE FROM Tiendas WHERE id_tienda = @id_tienda');

    if (result.rowsAffected[0] > 0) {
      res.status(200).send("Tienda eliminada exitosamente.");
    } else {
      res.status(404).send("Tienda no encontrada. Verifica el ID.");
    }
  } catch (err) {
    console.error("Error en deleteTienda: ", err);
    res.status(500).send("Error al eliminar tienda");
  }
};

module.exports = {
  getTiendas,
  addTienda,
  updateTienda,
  deleteTienda,
};
