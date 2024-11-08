const sql = require('mssql');
const config = require('./db.config');

const poolPromise = new sql.ConnectionPool(config)
  .connect()
  .then(pool => {
    console.log('Conexión a la base de datos establecida');
    return pool;
  })
  .catch(err => console.log('Error al crear el pool de conexiones:', err));

module.exports = {
  poolPromise,
  sql
}; 