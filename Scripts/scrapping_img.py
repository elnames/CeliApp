import pyodbc
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
import time
import requests
import os
from concurrent.futures import ThreadPoolExecutor

# Configuración de la conexión a la base de datos SQL Server
db_config = {
    'server': '34.176.146.237',
    'database': 'CeliApp',
    'user': 'celiadmin',
    'password': 'celiadmin',
}

# Crear una carpeta para guardar las imágenes descargadas
output_dir = './imagenes_productos'
os.makedirs(output_dir, exist_ok=True)

# Configurar el navegador Chrome
def create_webdriver():
    options = webdriver.ChromeOptions()
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-blink-features=AutomationControlled')
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    driver.set_page_load_timeout(60)
    return driver

# Conectar a la base de datos y obtener los productos
def obtener_productos():
    conexion = pyodbc.connect(
        f"DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={db_config['server']};DATABASE={db_config['database']};UID={db_config['user']};PWD={db_config['password']}"
    )
    cursor = conexion.cursor()
    query = "SELECT id_producto, nombre, empresa_tienda, categoria FROM Productos"
    cursor.execute(query)
    productos = cursor.fetchall()
    cursor.close()
    conexion.close()
    return [{'id': row[0], 'nombre': row[1], 'empresa_tienda': row[2], 'categoria': row[3]} for row in productos]

# Filtrar productos para obtener solo los que faltan
def productos_faltantes(productos):
    faltantes = []
    for producto in productos:
        image_path = os.path.join(output_dir, f"{producto['id']}.jpg")
        if not os.path.exists(image_path):
            faltantes.append(producto)
    return faltantes

# Función para realizar la búsqueda de imágenes
def buscar_imagen(producto_id, nombre_producto, empresa_tienda, categoria, max_intentos=3):
    consultas_busqueda = [
        f"{nombre_producto} {empresa_tienda}",
        f"{nombre_producto} {categoria}",
        f"{nombre_producto} producto sin gluten"
    ]
    driver = create_webdriver()
    image_url = None

    try:
        for consulta in consultas_busqueda:
            for intento in range(max_intentos):
                try:
                    driver.get("https://www.bing.com/images")
                    WebDriverWait(driver, 30).until(EC.presence_of_element_located((By.NAME, "q")))
                    search_box = driver.find_element(By.NAME, "q")
                    search_box.clear()
                    search_box.send_keys(consulta)
                    search_box.send_keys(Keys.RETURN)
                    WebDriverWait(driver, 30).until(EC.presence_of_all_elements_located((By.XPATH, "//a[@class='iusc']")))
                    image_elements = driver.find_elements(By.XPATH, "//a[@class='iusc']")
                    used_urls = set()

                    for image_element in image_elements[:5]:
                        mjson = image_element.get_attribute('m')
                        temp_image_url = mjson.split('"murl":"')[1].split('"')[0]
                        if temp_image_url not in used_urls:
                            image_url = temp_image_url
                            used_urls.add(temp_image_url)
                            break

                    if image_url:
                        response = requests.get(image_url)
                        if response.status_code == 200:
                            image_path = os.path.join(output_dir, f"{producto_id}.jpg")
                            with open(image_path, 'wb') as file:
                                file.write(response.content)
                            print(f"Imagen guardada para '{consulta}' en {image_path}")
                            return producto_id, image_url
                        else:
                            print(f"No se pudo descargar la imagen para '{consulta}' - Código de estado: {response.status_code}")

                except Exception as e:
                    print(f"Error al intentar descargar la imagen para '{consulta}' en el intento {intento + 1}: {e}")
                    time.sleep(2)

        print(f"No se pudo descargar la imagen para '{nombre_producto}' después de {max_intentos * len(consultas_busqueda)} intentos.")
        registrar_fallido(producto_id, nombre_producto)
        return producto_id, "No image found"

    finally:
        driver.quit()

# Registrar los productos que no se pudieron descargar
def registrar_fallido(producto_id, nombre_producto):
    with open("productos_fallidos.txt", "a") as file:
        file.write(f"{producto_id} - {nombre_producto}\n")

# Utilizar ThreadPoolExecutor para paralelizar el scraping
def realizar_scraping_imagenes():
    productos = obtener_productos()
    productos_a_descargar = productos_faltantes(productos)
    imagenes_productos = []

    with ThreadPoolExecutor(max_workers=2) as executor:
        futures = [executor.submit(buscar_imagen, producto['id'], producto['nombre'], producto['empresa_tienda'], producto['categoria']) for producto in productos_a_descargar]
        for future in futures:
            imagenes_productos.append(future.result())
            time.sleep(2)

    return imagenes_productos

# Ejecutar el proceso completo
if __name__ == "__main__":
    imagenes_productos = realizar_scraping_imagenes()
    print("Scraping completado. Las imágenes han sido descargadas localmente.")
