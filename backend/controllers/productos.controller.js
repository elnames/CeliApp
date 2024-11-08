const sql = require('mssql');
const config = require('../config/db.config');

// Obtener todos los productos
async function getProductos(req, res) {
  try {
    let pool = await sql.connect(config);
    let result = await pool.request().query(`
      SELECT id_producto, categoria, nombre, descripcion, 
             empresa_tienda, prod_celiaco, codigo_barras, 
             url_imagen, creado 
      FROM dbo.Productos 
      ORDER BY id_producto
    `);
    if (result.recordset.length > 0) {
      res.json(result.recordset);
    } else {
      res.status(404).send("No se encontraron productos.");
    }
  } catch (err) {
    console.error("Error en getProductos: ", err);
    res.status(500).send("Error al obtener los productos.");
  }
}

// Agregar un nuevo producto
const addProducto = async (req, res) => {
  try {
    const { nombre, descripcion, empresa_tienda, prod_celiaco, codigo_barras } = req.body;

    if (!nombre || !descripcion || !empresa_tienda || !codigo_barras) {
      return res.status(400).send("Todos los campos son obligatorios.");
    }

    const pool = await sql.connect(config);

    await pool.request()
      .input('Nombre', sql.NVarChar, nombre)
      .input('Descripcion', sql.NVarChar, descripcion)
      .input('Empresa_tienda', sql.NVarChar, empresa_tienda)
      .input('Prod_celiaco', sql.Bit, prod_celiaco || 0)
      .input('Codigo_barras', sql.NVarChar, codigo_barras)
      .query(`
        INSERT INTO dbo.Productos (nombre, descripcion, empresa_tienda, prod_celiaco, codigo_barras)
        VALUES (@Nombre, @Descripcion, @Empresa_tienda, @Prod_celiaco, @Codigo_barras)
      `);

    res.status(201).send("Producto agregado exitosamente.");
  } catch (error) {
    console.error("Error en addProducto:", error);
    res.status(500).send("Error al agregar producto.");
  }
};

// Actualizar un producto existente
const updateProducto = async (req, res) => {
  try {
    const { id_producto } = req.params;
    const { nombre, descripcion, empresa_tienda, codigo_barras, prod_celiaco } = req.body;

    if (!id_producto || isNaN(id_producto)) {
      return res.status(400).send("El ID del producto debe ser un número válido.");
    }

    const pool = await sql.connect(config);
    let result = await pool.request()
      .input('id_producto', sql.BigInt, id_producto)
      .input('nombre', sql.NVarChar, nombre)
      .input('descripcion', sql.NVarChar, descripcion)
      .input('empresa_tienda', sql.NVarChar, empresa_tienda)
      .input('codigo_barras', sql.NVarChar, codigo_barras)
      .input('prod_celiaco', sql.Bit, prod_celiaco)
      .query(`
        UPDATE dbo.Productos
        SET nombre = @nombre,
            descripcion = @descripcion,
            empresa_tienda = @empresa_tienda,
            codigo_barras = @codigo_barras,
            prod_celiaco = @prod_celiaco
        WHERE id_producto = @id_producto
      `);

    if (result.rowsAffected[0] > 0) {
      res.status(200).send("Producto actualizado exitosamente.");
    } else {
      res.status(404).send("Producto no encontrado. Verifica el ID");
    }
  } catch (err) {
    console.error("Error en updateProducto: ", err);
    res.status(500).send("Error al actualizar producto.");
  }
};

// Eliminar un producto por su ID
const deleteProducto = async (req, res) => {
  try {
    const { id_producto } = req.params;

    if (!id_producto || isNaN(id_producto)) {
      return res.status(400).send("El ID del producto debe ser un número válido.");
    }

    const pool = await sql.connect(config);
    let result = await pool.request()
      .input('id_producto', sql.BigInt, id_producto)
      .query('DELETE FROM dbo.Productos WHERE id_producto = @id_producto');

    if (result.rowsAffected[0] > 0) {
      res.status(200).send("Producto eliminado exitosamente.");
    } else {
      res.status(404).send("Producto no encontrado. Verifica el ID.");
    }
  } catch (err) {
    console.error("Error en deleteProducto: ", err);
    res.status(500).send("Error al eliminar producto.");
  }
};

// Función para obtener categorías únicas
async function getCategorias(req, res) {
  try {
    let pool = await sql.connect(config);
    const result = await pool.request()
      .query(`
        SELECT DISTINCT categoria 
        FROM dbo.Productos 
        WHERE categoria IS NOT NULL 
          AND categoria != '' 
          AND categoria != 'null'
        ORDER BY categoria
      `);
    
    const categorias = result.recordset.map(row => row.categoria);
    console.log('Categorías encontradas:', categorias);
    res.json(categorias);
  } catch (error) {
    console.error('Error al obtener categorías:', error);
    res.status(500).json({ error: 'Error al obtener las categorías' });
  }
}

module.exports = {
  getProductos,
  addProducto,
  updateProducto,
  deleteProducto,
  getCategorias
};
