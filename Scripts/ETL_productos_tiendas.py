import pdfplumber
import pandas as pd
import pymssql
import requests
import os
import hashlib
from datetime import datetime

# URL del archivo PDF en la web de Fundación Convivir
url = "https://fundacionconvivir.cl/convivir-admin/ProductoPdf/Alimentos"
pdf_path = "./LISTADO_ALIMENTOS.pdf"
output_csv = "productos.csv"
hash_file = "pdf_hash.txt"

# Descargar el archivo PDF
response = requests.get(url)
if response.status_code == 200:
    with open(pdf_path, 'wb') as f:
        f.write(response.content)
    print(f"Archivo PDF descargado: {pdf_path}")
else:
    print("Error al descargar el archivo PDF")
    exit()

# Calcular el hash del archivo PDF para verificar cambios
def calcular_hash(file_path):
    hash_md5 = hashlib.md5()
    with open(file_path, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

# Comparar hash con el anterior para determinar si hay cambios
nuevo_hash = calcular_hash(pdf_path)

if os.path.exists(hash_file):
    with open(hash_file, "r") as f:
        hash_anterior = f.read().strip()
else:
    hash_anterior = None

if nuevo_hash == hash_anterior:
    print("No se detectaron cambios en el PDF. No se procederá con la actualización.")
    os.remove(pdf_path)  # Borrar el PDF si no hay cambios
    exit()
else:
    with open(hash_file, "w") as f:
        f.write(nuevo_hash)
    print("Se detectaron cambios en el PDF. Procediendo con la actualización...")

# Definimos las categorías principales proporcionadas
categorias_principales = [
    "Bebidas y jugos",
    "Aderezos, Salsas y Aliños",
    "Harinas, almidones y premezclas",
    "Panes y productos horneados y Pastelería",
    "Queques, alfajores, productos horneados",
    "Galletas",
    "Cereales para desayuno y barras de cereal",
    "Golosinas: caramelos, gomitas, otros",
    "Chocolates y coberturas",
    "Leches",
    "Cremas",
    "Manjar o dulce de leche",
    "Mantequillas y margarinas",
    "Yogurt y leche cultivada",
    "Quesos",
    "Bebidas vegetales",
    "Pastas y fideos",
    "Frutos secos - frutas deshidratados - frutos tropicales",
    "Mermeladas y dulces",
    "Cóctel y Snacks",
    "Postres y compotas",
    "Helados",
    "Conservas dulces y saladas",
    "Cecinas",
    "Carnes",
    "Hamburguesas",
    "Comida preparada",
    "Comida para bebés",
    "Suplementos alimentarios",
    "Endulzantes y azúcares",
    "Cereales (grano) y legumbres",
    "Ingredientes para repostería y panificación",
    "Condimentos, especias y aliños",
    "Otros",
    "Cerveza y licores",
    "Galletas y colaciones",
    "Alimentos para regímenes especiales",
    "Suplemento Nutricional",
    "Té y hierbas",
    "Semillas y harinas de semillas",
    "Pastas untables",
    "Productos congelados",
    "Aceites",
    "Huevo"
]

# Inicializamos pdfplumber para leer el archivo PDF
all_data = []
current_category = None

with pdfplumber.open(pdf_path) as pdf:
    for page in pdf.pages:
        table = page.extract_table()
        if table:
            headers = table[0]
            data_rows = table[1:]

            for row in data_rows:
                if len(row) >= 3:
                    posible_categoria = row[0].strip() if row[0] else 'NN'
                    producto = row[1].strip() if row[1] else 'NN'
                    empresa = row[2].strip() if row[2] else 'NN'

                    if posible_categoria == "ALIMENTOS" and producto == "PRODUCTO" and empresa == "EMPRESA":
                        continue

                    if posible_categoria in categorias_principales:
                        current_category = posible_categoria
                        continue

                    if current_category and producto != 'NN' and empresa != 'NN':
                        codigo_barras = 'NN'
                        prod_celiaco = True
                        descripcion = posible_categoria
                        fecha_creacion = pd.Timestamp.now().strftime('%Y-%m-%d')

                        all_data.append([
                            current_category,
                            producto,
                            descripcion,
                            empresa,
                            prod_celiaco,
                            codigo_barras,
                            fecha_creacion
                        ])

df = pd.DataFrame(all_data, columns=[
    "CATEGORIA", "PRODUCTO", "DESCRIPCION", "EMPRESA_TIENDA", "PROD_CELIACO", "CODIGO_BARRAS", "FECHA_CREACION"
])

df.to_csv(output_csv, index=False, sep=';', encoding='utf-8-sig')
print(f"Datos extraídos y guardados en {output_csv}")

try:
    conn = pymssql.connect(
        server='34.176.146.237',
        user='celiadmin',
        password='celiadmin',
        database='CeliApp'
    )
    cursor = conn.cursor()
    print("Conexión exitosa a la base de datos en GCP.")

    for index, row in df.iterrows():
        cursor.execute("""
            SELECT COUNT(*) FROM Productos
            WHERE nombre = %s AND empresa_tienda = %s
        """, (row['PRODUCTO'], row['EMPRESA_TIENDA']))
        existe = cursor.fetchone()[0]

        if existe > 0:
            cursor.execute("""
                UPDATE Productos SET
                    descripcion = %s,
                    prod_celiaco = %s,
                    codigo_barras = %s,
                    creado = %s,
                    categoria = %s
                WHERE nombre = %s AND empresa_tienda = %s
            """, (
                row['DESCRIPCION'],
                row['PROD_CELIACO'],
                row['CODIGO_BARRAS'],
                row['FECHA_CREACION'],
                row['CATEGORIA'],
                row['PRODUCTO'],
                row['EMPRESA_TIENDA']
            ))
            print(f"Producto '{row['PRODUCTO']}' actualizado.")
        else:
            cursor.execute("""
                INSERT INTO Productos (nombre, descripcion, empresa_tienda, prod_celiaco, codigo_barras, creado, categoria)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (
                row['PRODUCTO'],
                row['DESCRIPCION'],
                row['EMPRESA_TIENDA'],
                row['PROD_CELIACO'],
                row['CODIGO_BARRAS'],
                row['FECHA_CREACION'],
                row['CATEGORIA']
            ))
            print(f"Producto '{row['PRODUCTO']}' insertado.")

    conn.commit()
    print("Datos insertados o actualizados en la base de datos exitosamente.")
except pymssql.Error as e:
    print("Error al conectar o poblar la base de datos:", e)
finally:
    if 'conn' in locals():
        conn.close()
    print("Conexión a la base de datos cerrada.")

os.remove(pdf_path)
print(f"Archivo PDF {pdf_path} eliminado.")
