#!/bin/bash

# Actualizar el sistema
sudo yum update -y

# Instalar dependencias
sudo yum install -y docker

# Iniciar y habilitar el servicio Docker
sudo systemctl start docker
sudo systemctl enable docker

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Crear un directorio para los archivos de configuración de Docker Compose
mkdir ~/odoo-docker
cd ~/odoo-docker

# Crear un archivo docker-compose.yml con el contenido proporcionado
echo "version: '3.1'
services:
  web:
    image: odoo:16.0
    depends_on:
      - db
    ports:
      - '8069:8069'
  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=postgres
      - POSTGRES_PASSWORD=odoo
      - POSTGRES_USER=odoo
" > docker-compose.yml

# Iniciar los contenedores con Docker Compose sin solicitar confirmación
sudo docker-compose up -d

# Instalar Nginx
sudo yum install -y nginx

# Configurar Nginx en el sistema host
echo "server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://localhost:8069;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}" | sudo tee /etc/nginx/conf.d/odoo.conf > /dev/null

# Reiniciar Nginx para aplicar los cambios
sudo systemctl restart nginx