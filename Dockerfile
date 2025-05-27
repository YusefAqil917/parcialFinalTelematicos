# Usa una imagen oficial de Python
FROM python:3.10

# Establece el directorio de trabajo en el contenedor
WORKDIR /app

# Copia los archivos de tu aplicación al contenedor
COPY . /app

# Instala dependencias
RUN pip install --no-cache Flask flask-cors Flask-MySQLdb Flask-SQLAlchemy

# Expone el puerto que usará Flask (si usas 5000)
EXPOSE 5000

# Comando para iniciar la aplicación
CMD ["flask", "run", "--host=0.0.0.0"]