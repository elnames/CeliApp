# CeliApp

**CeliApp** es una aplicación creada para personas celíacas que deben convivir con una dieta sin gluten. Su principal objetivo es facilitar la búsqueda y compra de productos libres de gluten, así como la consulta de información sobre alimentos y medicamentos seguros. Además, permite a los usuarios identificar tiendas cercanas que ofrecen estos productos, y compartir recomendaciones con la comunidad.

## Funcionalidades

1. **Inicio Personalizado**: Al iniciar sesión, el usuario es saludado y presentado con una página de inicio que muestra productos recomendados y locales cercanos.

2. **Búsqueda de Productos y Tiendas**: Los usuarios pueden buscar locales y productos sin gluten utilizando la barra de búsqueda.

3. **Mapa de Tiendas Cercanas**: Utilizando Google Maps, la aplicación muestra la ubicación de tiendas cercanas que venden productos sin gluten.

4. **Recomendaciones de Comida**: Productos recomendados para una dieta sin gluten se muestran en la pantalla de inicio, con opciones para ver detalles o guardar como favorito.

5. **Escaneo de Códigos de Barras**: La app permite escanear el código de barras de un producto para verificar si es libre de gluten.

6. **Sistema de Favoritos**: Los usuarios pueden marcar tiendas y productos como favoritos para acceder rápidamente en el futuro.

7. **Publicación de Información**: Los usuarios pueden inscribir tiendas o emprendimientos y publicar comidas recomendadas.

## Requisitos para Ser Ejecutado

1. **Sistema Operativo**: Windows, macOS o Linux.
2. **Flutter SDK**: Versión 3.0 o superior.
3. **JDK**: Java Development Kit versión 17 o superior.
4. **Android Studio o Visual Studio Code**: Para la edición del código y la emulación de la aplicación.
5. **API Key de Google Maps**: Necesaria para el uso de la funcionalidad de mapas.

## Aplicaciones y Dependencias Necesarias

1. **Flutter**: Para el desarrollo multiplataforma. link
3. **Dart**: Lenguaje de programación para desarrollar la aplicación.
4. **Google Maps Flutter**: Plugin para mostrar mapas de Google en la aplicación.
5. **Firebase**: Para la autenticación de usuarios y almacenamiento de datos.
6. **provider**: Manejo del estado de la aplicación.

Asegúrate de incluir las siguientes dependencias en el archivo `pubspec.yaml`:

```yaml
  dependencies:
    flutter:
      sdk: flutter
    google_maps_flutter: ^2.0.6
    firebase_auth: ^4.0.0
    cloud_firestore: ^3.0.3
    provider: ^6.0.1
```

## Paso a Paso para Ejecutar la Aplicación

1. **Instalar Flutter SDK**: Descarga e instala Flutter desde [flutter.dev](https://flutter.dev/docs/get-started/install). Sigue las instrucciones para configurar el `PATH` del sistema.

2. **Configurar JDK**: Instala JDK 17 y configura la variable de entorno `JAVA_HOME` apuntando al directorio de instalación.

4. **Clonar el Repositorio**: Abre la terminal y ejecuta:
   ```sh
   git clone https://github.com/elnames/CeliApp.git
   cd celiapp
   ```

5. **Instalar Dependencias**: Navega al directorio del proyecto y ejecuta el siguiente comando para instalar las dependencias necesarias:
   ```sh
   flutter pub get
   ```

6. **Configurar Google Maps API Key**:
   - Navega al archivo `android/app/src/main/AndroidManifest.xml`.
   - Agrega tu API Key de Google Maps en el siguiente campo:
     ```xml
     <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="TU_API_KEY_AQUI"/>
     ```

7. **Conectar Firebase**: Configura el proyecto con Firebase siguiendo las instrucciones en la consola de Firebase. Asegúrate de agregar los archivos `google-services.json` y `GoogleService-Info.plist` en las carpetas correspondientes para Android e iOS.

8. **Ejecutar la Aplicación**: Conecta un dispositivo físico o inicia un emulador desde Android Studio, luego ejecuta el siguiente comando:
   ```sh
   flutter run
   ```

9. **Solucionar Problemas Comunes**:
   - **Error de Versiones de Java**: Asegúrate de tener configurado JDK 17.
   - **Problemas de Conexión con Firebase**: Verifica la configuración y los archivos de Google Services.
   - **Mapa no Carga**: Verifica la clave de la API de Google Maps y los permisos necesarios en el manifest.


Comandos para inicializar correctamente:
  ```sh
    flutter clean
    flutter pub get
    flutter run
   ```


*Si hay algun problema iniciar con "flutter run -v" para revisar el log e identificar el error*
