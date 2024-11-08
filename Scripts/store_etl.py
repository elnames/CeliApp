import pandas as pd
import pyodbc

# Ruta del archivo Excel con los datos de las tiendas
excel_file_path = './etl_tiendas_celiapp.xlsx'

# Configuración de conexión a SQL Server en GCP
server = '34.176.146.237'
database = 'CeliApp'
username = 'celiadmin'
password = 'celiadmin'
driver = '{ODBC Driver 17 for SQL Server}'

# Crear la conexión a la base de datos
conn = pyodbc.connect(
    f'DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password}'
)

# Leer el archivo Excel
data = pd.read_excel(excel_file_path)

# Consulta SQL para insertar datos
insert_query = """
    INSERT INTO Tiendas (nombre, direccion, latitud, longitud, creado)
    VALUES (?, ?, ?, ?, ?)
"""

# Ejecutar inserciones para cada fila en el DataFrame
cursor = conn.cursor()
for index, row in data.iterrows():
    cursor.execute(insert_query, row['nombre'], row['direccion'], row['latitud'], row['longitud'], row['creado'])
conn.commit()

# Cerrar la conexión
cursor.close()
conn.close()
print("Datos cargados exitosamente en la base de datos.")
