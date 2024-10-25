# Utiliza la imagen oficial de Node.js como imagen base
FROM node:18

# Instala dependencias necesarias para `msnodesqlv8`
RUN apt-get update && \
    apt-get install -y curl build-essential apt-transport-https gnupg2 software-properties-common && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    add-apt-repository "$(curl -s https://packages.microsoft.com/config/debian/10/prod.list)" && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 unixodbc-dev

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /usr/src/app

# Copia el archivo de configuración package.json y package-lock.json en el contenedor
COPY package*.json ./

# Instala las dependencias
RUN npm install

# Copia el resto del código en el contenedor
COPY . .

# Expone el puerto en el que tu aplicación escucha (asegúrate de que sea el mismo puerto que usa tu aplicación)
EXPOSE 3000

# Define el comando que ejecutará la aplicación
CMD ["node", "server.js"]
