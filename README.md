# CeliApp

**CeliApp** es una aplicación móvil desarrollada con **Flutter** que tiene como objetivo ayudar a las personas con intolerancia al gluten a encontrar productos sin gluten, localizar tiendas cercanas que ofrezcan estos productos y gestionar su consumo de una manera sencilla y eficiente. La aplicación incluye funcionalidades como el registro de tiendas y productos sin gluten, revisión de productos escaneados, y más.

## Tecnologías Utilizadas
- **Flutter**: Framework de desarrollo móvil para Android e iOS.
- **Firebase**: Servicios para autenticación y almacenamiento de información del usuario.
- **Google Cloud Platform (GCP)**: Para integración de servicios adicionales y almacenamiento de datos.
- **Firebase Firestore**: Para almacenar información sobre alimentos favoritos, tiendas favoritas y calificaciones.
- **Firebase Authentication**: Para manejar el registro e inicio de sesión de usuarios.
- **Google Maps**: Para localizar las tiendas cercanas que ofrecen productos sin gluten.

## Características Principales
- **Registro e inicio de sesión de usuarios**: Los usuarios pueden registrarse, iniciar sesión y gestionar su perfil.
- **Modo Invitado**: Se permite la navegación limitada en modo invitado, con acceso a los productos recomendados y mapas, pero con restricciones para acceder a detalles completos.
- **Alimentos y Tiendas Favoritas**: Los usuarios pueden marcar productos y tiendas como favoritos y gestionar sus preferencias.
- **Mapa de Locales Cercanos**: Visualización en mapa de los locales más cercanos con productos sin gluten.
- **Escaneo de Códigos de Barras**: Escanea productos para verificar si son aptos para personas celíacas.

## Capturas de Pantalla
*(Agrega aquí capturas de pantalla del login, pantalla principal, y otras pantallas importantes de la app para ilustrar las funcionalidades.)*

## Instalación y Configuración
Para ejecutar este proyecto en tu máquina local, sigue los siguientes pasos:

### Requisitos Previos
- **Flutter SDK**: [Instalar Flutter](https://docs.flutter.dev/get-started/install)
- **Android Studio o VS Code**: Para emulación y desarrollo.
- **Android SDK**: Para ejecutar el emulador Android.
- **Git**: Para clonar el repositorio.

### Paso a Paso
1. **Clonar el Repositorio**
   
   Abre la terminal y ejecuta:
   ```bash
   git clone https://github.com/tu_usuario/CeliApp.git
   cd CeliApp
   ```

2. **Instalar las Dependencias**
   
   Ejecuta el siguiente comando para instalar todas las dependencias necesarias que se encuentran en el archivo `pubspec.yaml`:
   ```bash
   flutter pub get
   ```

3. **Configurar Firebase**
   
   Debes configurar Firebase para Android e iOS:
   - Ve a la [Consola de Firebase](https://console.firebase.google.com/) y crea un nuevo proyecto.
   - Descarga el archivo `google-services.json` para Android y agrégalo a la carpeta `android/app` de tu proyecto.
   - Configura el proyecto para iOS siguiendo las instrucciones de Firebase si es necesario.

4. **Configurar el Mapa de Google**
   
   Para la funcionalidad del mapa de locales cercanos, necesitas obtener una API Key de [Google Maps](https://developers.google.com/maps/documentation/android-sdk/get-api-key) y configurarla:
   - Agrega la API Key en el archivo `AndroidManifest.xml`.
   - Asegúrate de habilitar la API de Maps desde la consola de Google Cloud.

5. **Ejecutar la Aplicación**
   
   Puedes ejecutar la aplicación en un dispositivo físico o un emulador.
   - Conecta un dispositivo físico con la depuración USB habilitada o ejecuta un emulador de Android.
   - Ejecuta el siguiente comando:
   ```bash
   flutter run
   ```

### Problemas Comunes
- **Error de Versión de Gradle**: Si encuentras problemas con la versión de Gradle, asegúrate de actualizar el archivo `gradle-wrapper.properties` para usar una versión compatible con Java y Flutter (por ejemplo, `distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-all.zip`).
- **Firebase No Configurado**: Verifica que los archivos de configuración `google-services.json` (Android) o `GoogleService-Info.plist` (iOS) estén correctamente ubicados.

## Uso
- **Modo Invitado**: Al abrir la aplicación sin registrarse o iniciar sesión, se accederá al home con funcionalidades limitadas.
- **Modo Usuario Registrado**: Después de iniciar sesión o registrarse, el usuario podrá acceder a todas las funcionalidades, incluyendo la gestión de favoritos, acceso a mapas completos y detalles de productos.

## Contribución
Este proyecto está abierto a contribuciones. Si quieres colaborar:
1. **Fork** el repositorio.
2. Crea una nueva **rama** con la funcionalidad o corrección:
   ```bash
   git checkout -b feature/nueva-funcionalidad
   ```
3. **Confirma** tus cambios y sube la rama:
   ```bash
   git commit -m "Agregada nueva funcionalidad"
   git push origin feature/nueva-funcionalidad
   ```
4. Abre un **Pull Request** para revisar tus cambios.

## Licencia
Este proyecto está bajo la licencia MIT. Puedes consultar el archivo [LICENSE](LICENSE) para más detalles.

## Contacto
Si tienes alguna pregunta o sugerencia, no dudes en abrir un **issue** o contactarme directamente a través de GitHub.