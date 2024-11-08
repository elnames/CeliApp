const sql = require('mssql');
const config = require('../config/db.config');

// Obtener todas las tiendas
async function getTiendas(req, res) {
  try {
    let pool = await sql.connect(config);
    let result = await pool.request().query("SELECT * FROM dbo.Tiendas");
    if (result.recordset.length > 0) {
      res.json(result.recordset);
    } else {
      res.status(404).send("No se encontraron tiendas.");
    }
  } catch (err) {
    console.error("Error en getTiendas: ", err);
    res.status(500).send("Error al obtener las tiendas.");
  }
}

// Agregar una nueva tienda
const addTienda = async (req, res) => {
  try {
    const { nombre, direccion, comuna, region } = req.body;

    if (!nombre || !direccion || !comuna || !region) {
      return res.status(400).send("Todos los campos son obligatorios.");
    }

    const pool = await sql.connect(config);
    await pool.request()
      .input('nombre', sql.NVarChar, nombre)
      .input('direccion', sql.NVarChar, direccion)
      .input('comuna', sql.NVarChar, comuna)
      .input('region', sql.NVarChar, region)
      .query(`
        INSERT INTO dbo.Tiendas (nombre, direccion, comuna, region)
        VALUES (@nombre, @direccion, @comuna, @region)
      `);

    res.status(201).send("Tienda agregada exitosamente.");
  } catch (error) {
    console.error("Error en addTienda:", error);
    res.status(500).send("Error al agregar tienda.");
  }
};

// Actualizar una tienda existente
const updateTienda = async (req, res) => {
  try {
    const { id_tienda } = req.params;
    const { nombre, direccion, comuna, region } = req.body;

    if (!id_tienda || isNaN(id_tienda)) {
      return res.status(400).send("El ID de la tienda debe ser un número válido.");
    }

    const pool = await sql.connect(config);
    let result = await pool.request()
      .input('id_tienda', sql.BigInt, id_tienda)
      .input('nombre', sql.NVarChar, nombre)
      .input('direccion', sql.NVarChar, direccion)
      .input('comuna', sql.NVarChar, comuna)
      .input('region', sql.NVarChar, region)
      .query(`
        UPDATE Tiendas
        SET nombre = @nombre,
            direccion = @direccion,
            comuna = @comuna,
            region = @region
        WHERE id_tienda = @id_tienda
      `);

    if (result.rowsAffected[0] > 0) {
      res.status(200).send("Tienda actualizada exitosamente.");
    } else {
      res.status(404).send("Tienda no encontrada. Verifica el ID");
    }
  } catch (err) {
    console.error("Error en updateTienda: ", err);
    res.status(500).send("Error al actualizar tienda.");
  }
};

// Eliminar una tienda por su ID
const deleteTienda = async (req, res) => {
  try {
    const { id_tienda } = req.params;

    if (!id_tienda || isNaN(id_tienda)) {
      return res.status(400).send("El ID de la tienda debe ser un número válido.");
    }

    const pool = await sql.connect(config);
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
    res.status(500).send("Error al eliminar tienda.");
  }
};

// Obtener regiones únicas
async function getRegiones(req, res) {
  try {
    let pool = await sql.connect(config);
    const result = await pool.request()
      .query(`
        SELECT DISTINCT region 
        FROM Tiendas 
        WHERE region IS NOT NULL 
          AND region != '' 
          AND region != 'null'
        ORDER BY region
      `);
    
    const regiones = result.recordset.map(row => row.region);
    console.log('Regiones encontradas:', regiones);
    res.json(regiones);
  } catch (error) {
    console.error('Error al obtener regiones:', error);
    res.status(500).json({ error: 'Error al obtener las regiones' });
  }
}

module.exports = {
  getTiendas,
  addTienda,
  updateTienda,
  deleteTienda,
  getRegiones
};
