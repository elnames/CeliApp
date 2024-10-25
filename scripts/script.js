// Importar las bibliotecas necesarias
const fs = require('fs');
const https = require('https');
const pdfParse = require('pdf-parse');
const mysql = require('mysql');
const { parse } = require('csv-parse');

// URL del PDF a descargar
const pdfUrl = "https://fundacionconvivir.cl/convivir-admin/ProductoPdf/Alimentos" ; // Reemplazar con la URL real del PDF
const pdfPath = 'temp.pdf';

// Configuración de la base de datos MySQL
const dbConfig = {
  host: '34.176.201.123',
  user: 'celiadmin',
  password: 'celiadmin',
  database: 'celidb'
};

// Función para descargar el PDF
downloadPDF(pdfUrl, pdfPath, () => {
  extractDataFromPDF(pdfPath);
});

function downloadPDF(url, dest, callback) {
  const file = fs.createWriteStream(dest);
  https.get(url, (response) => {
    response.pipe(file);
    file.on('finish', () => {
      file.close(callback);
    });
  }).on('error', (err) => {
    fs.unlink(dest, () => {});
    console.error('Error al descargar el archivo:', err.message);
  });
}

// Función para extraer datos del PDF
function extractDataFromPDF(pdfPath) {
  const pdfBuffer = fs.readFileSync(pdfPath);
  pdfParse(pdfBuffer).then(data => {
    const text = data.text;
    const rows = text.split('\n');
    const products = processRows(rows);
    insertProductsIntoDatabase(products);
  }).catch(error => {
    console.error('Error al procesar el PDF:', error);
  });
}

// Función para procesar las filas del PDF
function processRows(rows) {
  const products = [];
  let currentCategory = '';

  rows.forEach(row => {
    if (row.trim() === '' || row.toLowerCase().includes('fecha de actualización')) {
      return;
    }

    // Detectar si la línea es una categoría
    if (row.match(/^[a-zA-Z\s]+$/)) {
      currentCategory = row.trim();
    } else {
      // Caso contrario, es un producto
      const productDetails = row.split(',');
      if (productDetails.length > 1) {
        const product = {
          category: currentCategory,
          name: productDetails[0].trim(),
          brand: productDetails[1]?.trim() || ''
        };
        products.push(product);
      }
    }
  });

  return products;
}

// Función para insertar productos en la base de datos
function insertProductsIntoDatabase(products) {
  const connection = mysql.createConnection(dbConfig);

  connection.connect(err => {
    if (err) {
      console.error('Error al conectar con la base de datos:', err);
      return;
    }
    console.log('Conectado a la base de datos');

    products.forEach(product => {
      const query = `INSERT INTO productos (nombre, categoria, marca) VALUES (?, ?, ?)`;
      connection.query(query, [product.name, product.category, product.brand], (err, result) => {
        if (err) {
          console.error('Error al insertar producto:', err);
        }
      });
    });

    connection.end(() => {
      console.log('Inserción completada y conexión cerrada.');
    });
  });
}