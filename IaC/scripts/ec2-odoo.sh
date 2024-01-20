#!/bin/bash

# Actualizar el sistema
sudo apt update -y
sudo apt upgrade -y

# Instalar dependencias necesarias
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Agregar la clave GPG oficial de Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Configurar el repositorio estable de Docker
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Actualizar el índice de paquetes
sudo apt update -y

# Instalar Docker y Docker Compose
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose

# Iniciar y habilitar el servicio Docker
sudo systemctl start docker
sudo systemctl enable docker

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

# Configurar Nginx en el sistema host
sudo apt install -y nginx

# Crear un archivo de configuración para Nginx
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
}" | sudo tee /etc/nginx/sites-available/odoo > /dev/null

# Crear un enlace simbólico al archivo de configuración
sudo ln -s /etc/nginx/sites-available/odoo /etc/nginx/sites-enabled/

# Reiniciar Nginx para aplicar los cambios
sudo systemctl restart nginx