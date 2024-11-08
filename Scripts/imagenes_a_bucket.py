from google.cloud import storage
import pyodbc
import os

# Configuración de Google Cloud Storage
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "./celiapp-437819-d6b3a8464a3f.json"  # Reemplaza con la ruta correcta a tu archivo JSON de credenciales
storage_client = storage.Client()
bucket_name = 'celiapp-bucket'

# Configuración de la conexión a la base de datos
server = '34.176.146.237'
database = 'CeliApp'
username = 'celiadmin'
password = 'celiadmin'

# Crear la conexión con SQL Server
conn = pyodbc.connect(
    f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={server};DATABASE={database};UID={username};PWD={password}'
)
cursor = conn.cursor()

def listar_imagenes_bucket():
    """Lista todas las imágenes disponibles en el bucket de GCS."""
    try:
        bucket = storage_client.bucket(bucket_name)
        blobs = bucket.list_blobs()

        # Recopilar los nombres de los archivos que corresponden al formato "<id_producto>.jpg"
        imagenes_disponibles = set()
        for blob in blobs:
            if blob.name.endswith('.jpg'):
                imagen_id = blob.name.split('.')[0]
                imagenes_disponibles.add(imagen_id)

        return imagenes_disponibles
    except Exception as e:
        print(f"Error al listar imágenes del bucket: {e}")
        return set()

def actualizar_urls_imagenes(imagenes_disponibles):
    """Actualiza las URLs de los productos que tienen imágenes disponibles en la base de datos."""
    try:
        # Obtener todos los productos de la base de datos
        cursor.execute("SELECT id_producto FROM Productos")
        productos = cursor.fetchall()

        # Iterar por cada producto y actualizar la URL si la imagen está disponible
        for producto in productos:
            producto_id = str(producto.id_producto)
            if producto_id in imagenes_disponibles:
                url_imagen = f"https://storage.googleapis.com/{bucket_name}/{producto_id}.jpg"
                
                # Actualizar la URL en la base de datos
                update_query = """
                UPDATE Productos
                SET url_imagen = ?
                WHERE id_producto = ?
                """
                cursor.execute(update_query, url_imagen, producto_id)

        # Hacer commit a la base de datos para aplicar los cambios
        conn.commit()
        print("URLs de las imágenes actualizadas correctamente.")
    
    except Exception as e:
        print(f"Error al actualizar las URLs: {e}")
    
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    # Listar las imágenes disponibles en el bucket de GCS
    imagenes_disponibles = listar_imagenes_bucket()
    print(f"Imágenes disponibles: {len(imagenes_disponibles)}")

    # Actualizar la base de datos con las URLs de las imágenes disponibles
    actualizar_urls_imagenes(imagenes_disponibles)
