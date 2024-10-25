import os
import requests
import tabula
import pandas as pd
import mysql.connector
from io import BytesIO
from PyPDF2 import PdfReader

# Descargar PDF desde la URL
url = "https://fundacionconvivir.cl/convivir-admin/ProductoPdf/Alimentos"  # Reemplaza esto con la URL correcta del PDF
response = requests.get(url)
response.raise_for_status()  # Verifica que la descarga fue exitosa
pdf_data = BytesIO(response.content)

# Extraer tablas usando tabula
# Utilizamos el archivo en memoria sin guardarlo localmente
tables = tabula.read_pdf(pdf_data, pages='all', multiple_tables=True, stream=True)

# Combinar todas las tablas en un solo DataFrame
combined_df = pd.concat(tables, ignore_index=True)

# Limpieza de datos
def clean_data(df):
    df.columns = df.columns.str.lower().str.replace(' ', '_')
    df = df.dropna(how='all')  # Elimina filas completamente vacías
    df = df.fillna('')  # Llena valores NaN con cadenas vacías
    return df

cleaned_df = clean_data(combined_df)

# Cargar CSV de productos existentes con categorías existentes
existing_categories_csv = 'productos_gluten_free.csv'
if not os.path.exists(existing_categories_csv):
    raise FileNotFoundError(f"El archivo {existing_categories_csv} no se encuentra disponible.")

productos_df = pd.read_csv(existing_categories_csv)

# Verificar y agregar categorías faltantes
def add_missing_categories(new_df, existing_df):
    categorias_existentes = set(existing_df['categoria'].str.lower())
    categorias_nuevas = set(new_df['categoria'].str.lower()) - categorias_existentes
    
    if categorias_nuevas:
        for cat in categorias_nuevas:
            new_row = pd.DataFrame({'categoria': [cat]})
            existing_df = pd.concat([existing_df, new_row], ignore_index=True)
            print(f"Categoría '{cat}' añadida correctamente.")
    return existing_df

productos_df = add_missing_categories(cleaned_df, productos_df)

# Guardar cambios en CSV
productos_df.to_csv(existing_categories_csv, index=False)

# Codificar las categorías
productos_df['categoria_encoded'] = productos_df['categoria'].astype('category').cat.codes

# Conectar con la base de datos MySQL y cargar los datos
mydb = mysql.connector.connect(
    host="localhost",       # Reemplaza esto por el host correcto
    user="root",            # Usuario de la base de datos
    password="password",    # Contraseña del usuario
    database="productos_db" # Nombre de la base de datos
)

cursor = mydb.cursor()

# Crear tabla en la base de datos si no existe
def create_table_if_not_exists():
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS productos (
            id INT AUTO_INCREMENT PRIMARY KEY,
            producto VARCHAR(255),
            categoria VARCHAR(255),
            empresa VARCHAR(255),
            categoria_encoded INT
        )
    """)

create_table_if_not_exists()

# Insertar los productos en la tabla
def insert_data_to_db(df):
    for _, row in df.iterrows():
        cursor.execute(
            "INSERT INTO productos (producto, categoria, empresa, categoria_encoded) VALUES (%s, %s, %s, %s)",
            (row['producto'], row['categoria'], row['empresa'], row['categoria_encoded'])
        )

insert_data_to_db(productos_df)

# Confirmar los cambios en la base de datos
mydb.commit()

# Cerrar conexión con la base de datos
cursor.close()
mydb.close()