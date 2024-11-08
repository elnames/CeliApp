import os
import time
import requests
import pyodbc
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
import time
# Datos de conexión a la base de datos
DB_SERVER = "34.176.146.237"
DB_DATABASE = "CeliApp"
DB_USER = "celiadmin"
DB_PASSWORD = "celiadmin"

# Conexión a la base de datos
def obtener_productos():
    conexion = pyodbc.connect(
        f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={DB_SERVER};DATABASE={DB_DATABASE};UID={DB_USER};PWD={DB_PASSWORD}'
    )
    cursor = conexion.cursor()
    cursor.execute("SELECT id_producto, nombre, empresa_tienda FROM Productos")
    productos = cursor.fetchall()
    conexion.close()
    
    return productos
# Crear una carpeta para guardar las imágenes descargadas
output_dir = './imagenes_productos_faltantes'
os.makedirs(output_dir, exist_ok=True)

def create_webdriver():
    options = webdriver.ChromeOptions()
    options.add_argument('--headless')  # Ejecutar sin interfaz gráfica
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-blink-features=AutomationControlled')
    options.add_argument('user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36')
    
    # En lugar de service, usar executable_path como ruta explícita al driver instalado
    driver = webdriver.Chrome(executable_path=ChromeDriverManager().install(), options=options)
    driver.set_page_load_timeout(60)  # Aumentar el timeout de carga de página a 60 segundos
    return driver
# Verificar si la imagen ya existe
def imagen_ya_existe(producto_id):
    return os.path.exists(os.path.join(output_dir, f"{producto_id}.jpg"))

# Función para realizar la búsqueda de imágenes en Bing
def buscar_imagen_bing(producto_id, nombre_producto, empresa_tienda):
    if imagen_ya_existe(producto_id):
        print(f"Imagen para el producto con ID {producto_id} ya existe. No se realizará la búsqueda.")
        return

    consulta_busqueda = f"{nombre_producto} {empresa_tienda}"
    driver = create_webdriver()
    image_url = None

    try:
        print(f"Navegando a Bing Images para buscar: {consulta_busqueda}")
        driver.get("https://www.bing.com/images")

        # Esperar hasta que la barra de búsqueda esté disponible
        time.sleep(3)
        search_box = driver.find_element(By.NAME, "q")
        search_box.send_keys(consulta_busqueda)
        search_box.send_keys(Keys.RETURN)

        # Esperar hasta que se carguen los resultados de la búsqueda
        time.sleep(5)
        image_elements = driver.find_elements(By.XPATH, "//a[@class='iusc']")

        # Intentar extraer la URL de una de las primeras imágenes relevantes
        used_urls = set()

        for image_element in image_elements[:5]:  # Intentar con las primeras 5 imágenes
            mjson = image_element.get_attribute('m')
            temp_image_url = mjson.split('"murl":"')[1].split('"')[0]  # Extraer la URL de la imagen
            if temp_image_url not in used_urls:
                image_url = temp_image_url
                used_urls.add(temp_image_url)
                break

        # Descargar y guardar la imagen directamente desde la URL
        if image_url:
            response = requests.get(image_url)
            if response.status_code == 200:
                # Guardar la imagen con el ID del producto en formato JPG
                image_path = os.path.join(output_dir, f"{producto_id}.jpg")
                with open(image_path, 'wb') as file:
                    file.write(response.content)
                print(f"Imagen guardada para '{consulta_busqueda}' en {image_path}")
            else:
                print(f"No se pudo descargar la imagen para '{consulta_busqueda}'")
        else:
            print(f"No se encontró una imagen adecuada para '{consulta_busqueda}'")

    except Exception as e:
        print(f"Error al navegar a Bing Images para '{consulta_busqueda}': {e}")

    finally:
        driver.quit()

# Obtener la lista de productos de la base de datos
productos = obtener_productos()

# Realizar scraping solo para las imágenes faltantes
for producto in productos:
    producto_id, nombre_producto, empresa_tienda = producto
    buscar_imagen_bing(producto_id, nombre_producto, empresa_tienda)
    time.sleep(2)  # Agregar un descanso de 2 segundos entre cada solicitud para evitar sobrecarga

print("Scraping completado.")
