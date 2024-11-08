const sql = require('mssql');
const config = require('../config/db.config');

// Obtener todos los usuarios
async function getUsuarios(req, res) {
  try {
    let pool = await sql.connect(config);
    let result = await pool.request()
      .query(`
        SELECT id_usuario, nombre, email, rol, estado_suscripcion, 
               fecha_registro, ultima_actualizacion
        FROM Usuarios
        ORDER BY fecha_registro DESC
      `);
    res.json(result.recordset);
  } catch (err) {
    console.error("Error en getUsuarios: ", err);
    res.status(500).send("Error al obtener usuarios.");
  }
}

// Actualizar usuario
const updateUsuario = async (req, res) => {
  try {
    const { id_usuario } = req.params;
    const { nombre, email, rol, estado_suscripcion } = req.body;

    const pool = await sql.connect(config);
    let result = await pool.request()
      .input('id_usuario', sql.Int, id_usuario)
      .input('nombre', sql.NVarChar, nombre)
      .input('email', sql.NVarChar, email)
      .input('rol', sql.NVarChar, rol)
      .input('estado_suscripcion', sql.NVarChar, estado_suscripcion)
      .input('ultima_actualizacion', sql.DateTime, new Date())
      .query(`
        UPDATE Usuarios
        SET nombre = @nombre,
            email = @email,
            rol = @rol,
            estado_suscripcion = @estado_suscripcion,
            ultima_actualizacion = @ultima_actualizacion
        WHERE id_usuario = @id_usuario
      `);

    if (result.rowsAffected[0] > 0) {
      res.status(200).send("Usuario actualizado exitosamente.");
    } else {
      res.status(404).send("Usuario no encontrado.");
    }
  } catch (err) {
    console.error("Error en updateUsuario: ", err);
    res.status(500).send("Error al actualizar usuario.");
  }
};

// Eliminar usuario
const deleteUsuario = async (req, res) => {
  try {
    const { id_usuario } = req.params;

    const pool = await sql.connect(config);
    let result = await pool.request()
      .input('id_usuario', sql.Int, id_usuario)
      .query('DELETE FROM Usuarios WHERE id_usuario = @id_usuario');

    if (result.rowsAffected[0] > 0) {
      res.status(200).send("Usuario eliminado exitosamente.");
    } else {
      res.status(404).send("Usuario no encontrado.");
    }
  } catch (err) {
    console.error("Error en deleteUsuario: ", err);
    res.status(500).send("Error al eliminar usuario.");
  }
};

module.exports = {
  getUsuarios,
  updateUsuario,
  deleteUsuario
}; 