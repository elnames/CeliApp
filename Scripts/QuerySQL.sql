-- Desactivar temporalmente las restricciones de claves foráneas
ALTER TABLE producto_tienda NOCHECK CONSTRAINT ALL;
ALTER TABLE SolicitudProductoTienda NOCHECK CONSTRAINT ALL;
ALTER TABLE EvaluacionProducto NOCHECK CONSTRAINT ALL;
ALTER TABLE EscaneoProducto NOCHECK CONSTRAINT ALL;
ALTER TABLE Favoritos NOCHECK CONSTRAINT ALL;

-- Eliminar tablas existentes en el orden correcto para evitar conflictos de claves foráneas
DROP TABLE IF EXISTS producto_tienda;
DROP TABLE IF EXISTS SolicitudProductoTienda;
DROP TABLE IF EXISTS EvaluacionProducto;
DROP TABLE IF EXISTS EscaneoProducto;
DROP TABLE IF EXISTS Favoritos;
DROP TABLE IF EXISTS Tiendas;
DROP TABLE IF EXISTS Productos;
DROP TABLE IF EXISTS Usuarios;

-- Crear las tablas con `IDENTITY` en las columnas de ID

CREATE TABLE Usuarios (
    id_usuario BIGINT PRIMARY KEY, -- Dejar sin IDENTITY si prefieres manejar el ID manualmente
    uid_firebase NVARCHAR(255),
    estado BIT,
    nombre VARCHAR(255),
    correo NVARCHAR(255),
    clave NVARCHAR(255),
    creado DATETIME
);

CREATE TABLE Productos (
    id_producto BIGINT IDENTITY(1,1) PRIMARY KEY,
    categoria NVARCHAR(300),
    nombre NVARCHAR(255),
    descripcion NVARCHAR(300),
    empresa_tienda NVARCHAR(250),
    prod_celiaco BIT,
    codigo_barras VARCHAR(255),
    url_imagen NVARCHAR(255),
    creado DATETIME
);

CREATE TABLE Tiendas (
    id_tienda BIGINT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(255),
    direccion NVARCHAR(255),
    longitud NVARCHAR(50),
    latitud NVARCHAR(50),
    creado DATETIME
);

CREATE TABLE Favoritos (
    id_favoritos BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_us BIGINT,
    id_prod BIGINT,
    creado DATETIME,
    FOREIGN KEY (id_us) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_prod) REFERENCES Productos(id_producto)
);

CREATE TABLE EscaneoProducto (
    id_escaneo BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_usuario BIGINT,
    id_producto BIGINT,
    imagen NVARCHAR(255),
    fecha DATETIME,
    es_seguro BIT,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);

CREATE TABLE EvaluacionProducto (
    id_evaluacion BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_usuario BIGINT,
    id_producto BIGINT,
    id_tienda BIGINT,
    rating INT,
    recomendacion NVARCHAR(250),
    fecha DATETIME,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto),
    FOREIGN KEY (id_tienda) REFERENCES Tiendas(id_tienda)
);

CREATE TABLE SolicitudProductoTienda (
    id_solicitud BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_usuario BIGINT,
    tipo_solicitud VARCHAR(20) CHECK (tipo_solicitud IN ('Producto', 'Tienda')),
    nombre VARCHAR(255),
    descripcion TEXT,
    img VARCHAR(255),
    fecha DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
);

CREATE TABLE producto_tienda (
    id_producto_tienda BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_producto BIGINT,
    id_tienda BIGINT,
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto),
    FOREIGN KEY (id_tienda) REFERENCES Tiendas(id_tienda)
);

-- Usar DBCC CHECKIDENT para reiniciar los contadores si es necesario
-- Reiniciar los contadores de IDENTITY en cada tabla con columna IDENTITY
DBCC CHECKIDENT ('Productos', RESEED, 0);
DBCC CHECKIDENT ('Tiendas', RESEED, 0);
DBCC CHECKIDENT ('Favoritos', RESEED, 0);
DBCC CHECKIDENT ('EscaneoProducto', RESEED, 0);
DBCC CHECKIDENT ('EvaluacionProducto', RESEED, 0);
DBCC CHECKIDENT ('SolicitudProductoTienda', RESEED, 0);
DBCC CHECKIDENT ('producto_tienda', RESEED, 0);







-- Primero eliminamos la llave foránea
ALTER TABLE Favoritos
DROP CONSTRAINT FK__Favoritos__id_us__731B1205;

-- Luego modificamos la columna
ALTER TABLE Favoritos
ALTER COLUMN id_us VARCHAR(50) NOT NULL;

-- Si necesitas recrear la llave foránea, ya no la vincularemos con la tabla de usuarios
-- ya que los usuarios ahora están en Firebase