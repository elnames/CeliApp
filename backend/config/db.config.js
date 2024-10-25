const sql = require('mssql');

const config = {
  user: 'celiadmin', // Debe ser un usuario válido en la instancia de SQL Server en GCP.
  password: 'celiadmin', // Contraseña para ese usuario.
  server: '34.176.146.237', // Dirección IP pública de tu instancia.
  database: 'CeliApp', // Nombre de tu base de datos.
  port: 1433, // El puerto predeterminado de SQL Server.
  options: {
    encrypt: true, // GCP requiere conexiones cifradas.
    trustServerCertificate: true // Solo para desarrollo. En producción, usa un certificado válido.
  }
};

module.exports = config;
