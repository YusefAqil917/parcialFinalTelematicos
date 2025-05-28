# parcialFinalTelematicos

# 1. Clonar repo

```jsx
https://github.com/omondragon/MiniWebApp.git
```

## Cambiar /config.py
En este archivo esta para correr con Docker ya.**

```bash
class Config:
    MYSQL_HOST = 'localhost'
    MYSQL_USER = 'root'
    MYSQL_PASSWORD = 'root'
    MYSQL_DB = 'myflaskapp'
   
    SQLALCHEMY_DATABASE_URI = "mysql+mysqldb://root:root@mysql_db:3306/myflaskapp"  # Docker
```

# 2. En AWS

### ✅ **1. Actualiza el sistema**

```bash
bash
CopiarEditar
sudo apt update
sudo apt upgrade -y

```

---

### ✅ **2. Instala dependencias necesarias**

```bash
bash
CopiarEditar
sudo apt install -y ca-certificates curl gnupg lsb-release

```

---

### ✅ **3. Agrega la clave GPG oficial de Docker**

```bash
bash
CopiarEditar
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

```

---

### ✅ **4. Agrega el repositorio de Docker**

```bash
bash
CopiarEditar
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

```

---

## En /webapp

### Dockerfile

```bash
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
```

### docker-compose.yml

```bash
version: '3.8'

services:
  web:
    build: .
    container_name: flask_app
    environment:
      - FLASK_APP=run.py
      - FLASK_ENV=development
      - DB_HOST=db
      - DB_USER=root
      - DB_PASSWORD=root
      - DB_NAME=myflaskapp
    command: flask run --host=0.0.0.0
    volumes:
      - .:/app
    expose:
      - "5000"
    depends_on:
      - db

  db:
    image: mysql:5.7
    restart: always
    container_name: mysql_db
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: myflaskapp
    volumes:
      - ./home/ubuntu:/docker-entrypoint-initdb.d
    ports:
      - "3306:3306"

  nginx:
    image: nginx:1.18
    container_name: nginx_proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf
      - ./nginx/ssl:/etc/nginx/ssl
    depends_on:
      - web

volumes:
  mysql_data:
```

### ✅ **5. Actualiza los paquetes con el nuevo repositorio**

```bash
bash
CopiarEditar
sudo apt update

```

---

### ✅ **6. Instala Docker y sus componentes**

```bash
bash
CopiarEditar
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

---

### ✅ **7. Verifica la instalación**

```bash
bash
CopiarEditar
sudo docker version

```

# 3. Configuración SSL del sitio web

## Instalar certificado autofirmado

```bash
cd /home/vagrant

mkdir -p ~/certs
cd ~/certs

openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout selfsigned.key \
  -out selfsigned.crt \
  -subj "/C=US/ST=State/L=City/O=Dev/OU=Local/CN=localhost"
```
## Levantar los contenedores

```bash
docker compose up --build
```

### Borrar la carpeta /home/vagrant/webapp/nginx/default.conf y crear un archivo llamado default.conf en la misma ruta con este contenido:

```bash
server {
    listen 80;
    server_name 192.168.60.3;

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name 192.168.60.3;

    ssl_certificate     /etc/nginx/ssl/selfsigned.crt;
    ssl_certificate_key /etc/nginx/ssl/selfsigned.key;

    location / {
        proxy_pass http://web:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Si no acepta solicitudes por https: Copiar los archivos de la carpeta /certs a nginx/ssl/

```bash
sudo cp certs/selfsigned.crt /home/vagrant/webapp/nginx/ssl/
sudo cp certs/selfsigned.key /home/vagrant/webapp/nginx/ssl/
```

# 4. Montar proyecto

Crear los Dockerfile y docker-compose.yml. 

Borrar el default.conf y crear el archivo

Conectarse a la DB y pegar el contenido de `init.sql` 

```bash
 docker exec -it mysql_db mysql -u root -p
```

# 5. Prometheus y Node Exporter

### 🔹 **1. Actualiza tu sistema**

```bash
bash
CopiarEditar
sudo apt update && sudo apt upgrade -y

```

---

## 🟦 INSTALAR PROMETHEUS

### 🔹 2. Descarga y descomprime Prometheus

```bash
bash
CopiarEditar
cd /tmp
curl -LO https://github.com/prometheus/prometheus/releases/download/v2.52.0/prometheus-2.52.0.linux-amd64.tar.gz
tar -xvf prometheus-2.52.0.linux-amd64.tar.gz
sudo mv prometheus-2.52.0.linux-amd64 /opt/prometheus

```

### 🔹 3. Agrega los binarios al PATH

```bash
bash
CopiarEditar
sudo ln -s /opt/prometheus/prometheus /usr/local/bin/prometheus
sudo ln -s /opt/prometheus/promtool /usr/local/bin/promtool

```

### 🔹 4. Configura Prometheus para monitorear el host local

Edita el archivo de configuración:

```bash
bash
CopiarEditar
sudo nano /opt/prometheus/prometheus.yml

```

Y déjalo así:

```yaml
yaml
CopiarEditar
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

```

---

### 🔹 5. Ejecuta Prometheus

```bash
bash
CopiarEditar
cd /opt/prometheus
./prometheus --config.file=prometheus.yml

```

Abre en el navegador:

```
cpp
CopiarEditar
http://<TU_IP_PUBLICA>:9090

```

Si necesitas abrir el puerto 9090:

- Ve a **AWS > EC2 > Seguridad > Grupos de seguridad**.
- Edita el grupo y **agrega una regla de entrada** para permitir el puerto `9090` desde tu IP.

---

## 🟩 INSTALAR NODE EXPORTER

### 🔹 6. Descarga y configura Node Exporter

```bash
bash
CopiarEditar
cd /tmp
curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
tar -xvf node_exporter-1.8.1.linux-amd64.tar.gz
sudo mv node_exporter-1.8.1.linux-amd64 /opt/node_exporter
sudo ln -s /opt/node_exporter/node_exporter /usr/local/bin/node_exporter

```

### 🔹 7. Ejecuta Node Exporter

```bash
bash
CopiarEditar
node_exporter &

```

Se expondrá en el puerto `9100`.

---

### 🔹 8. Agrega Node Exporter a Prometheus

Edita de nuevo el archivo de configuración:

```bash
bash
CopiarEditar
sudo nano /opt/prometheus/prometheus.yml

```

Agrega esto debajo de `scrape_configs`:

```yaml
yaml
CopiarEditar
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']

```

Reinicia Prometheus:

```bash
bash
CopiarEditar
pkill prometheus
./prometheus --config.file=prometheus.yml

```

# Grafana

## 1. Instalar Grafana en Ubuntu 22.04

### 🔹 Añadir el repositorio oficial de Grafana:

```bash
bash
CopiarEditar
sudo apt install -y software-properties-common
sudo add-apt-repository "deb [arch=amd64 signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main"

```

### 🔹 Agregar clave GPG y actualizar:

```bash
bash
CopiarEditar
curl -fsSL https://packages.grafana.com/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/grafana.key
sudo apt update

```

### 🔹 Instalar Grafana:

```bash
bash
CopiarEditar
sudo apt install grafana -y

```

### 🔹 Iniciar el servicio:

```bash
bash
CopiarEditar
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

```

---

## 🌐 2. Acceder a Grafana

Abre en el navegador:

👉 `http://<TU_IP_PUBLICA>:3000`

- **Usuario**: `admin`
- **Contraseña**: `admin`
    
    (te pedirá cambiarla al ingresar)
    

> Si no carga, abre el puerto 3000 en el grupo de seguridad de AWS (como hiciste con 9090).
> 

---

## 🔧 3. Conectar Prometheus como fuente de datos

1. En la barra izquierda, haz clic en **Gear ⚙️ → Data sources**.
2. Clic en **Add data source**.
3. Selecciona **Prometheus**.
4. En el campo **URL**, escribe:
    
    ```
    arduino
    CopiarEditar
    http://localhost:9090
    
    ```
    
5. Haz clic en **Save & test**.

---

## 📊 4. Crear Paneles Básicos

### 🔸 Panel de uso de CPU

1. Ve a **Dashboards → New → New Dashboard**.
2. Clic en **Add a new panel**.
3. En el editor de métricas:

![image.png](attachment:a56e7193-4476-45fa-9d9c-77307e4ce74d:image.png)

1. Clic en **Apply** (arriba a la derecha).

### 🔸 Medidor de espacio en disco (Gauge)

1. Añade otro panel.
2. Cambia el tipo a **Gauge** (ícono de velocímetro).
3. En la consulta escribe:

![image.png](attachment:13aa93d3-261c-4d63-a0a4-b4c6a2d8193f:image.png)

1. Clic en **Apply**.

> Asegúrate de que estás viendo métricas de tu sistema — puedes ajustar {} según tu caso (interfaz, disco, etc.).
> 

---

## 📁 5. Importar un dashboard preconfigurado

### 🔹 Usa un dashboard de la librería oficial:

1. Ve a: https://grafana.com/grafana/dashboards/1860-node-exporter-full/
2. Copia el **ID del dashboard**: `1860`
3. En Grafana:
    - Ve a **Dashboards → Import**
    - Pega `1860` en "Import via grafana.com"
    - Clic en **Load**
    - En "Prometheus", selecciona la fuente que configuraste
    - Clic en **Import**

¡Y listo! Ahora tendrás un dashboard completo con métricas de CPU, RAM, disco, red, y más.
