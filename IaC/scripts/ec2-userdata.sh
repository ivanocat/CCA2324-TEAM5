#!/bin/bash

#Export
export db_address_ext="${db_address_ext}"

# Update the system
sudo yum update -y

# Install Git
sudo yum install -y git

# Install Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker

# Add the user to the docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Nginx
sudo yum install -y nginx

# Definir las opciones a agregar al archivo de configuración de Nginx
client_max_body_size="client_max_body_size 30000M;"
client_body_buffer_size="client_body_buffer_size 200000k;"

# Agregar las opciones al archivo de configuración de Nginx
echo "Agregando las siguientes opciones al archivo de configuración de Nginx:"
echo "$client_max_body_size"
echo "$client_body_buffer_size"
echo ""

echo "$client_max_body_size" >> /etc/nginx/nginx.conf
echo "$client_body_buffer_size" >> /etc/nginx/nginx.conf

# Create directories for Odoo configuration
mkdir -p ~/odoo-docker/config
mkdir -p ~/odoo-docker/addons
mkdir -p ~/odoo-docker/db-data

# Clone the Git repository into addons directory and unzip it
cd ~/odoo-docker/addons
git clone https://github.com/dlopezz/addon_17_odoo.git
unzip addon_17_odoo/enterprise-17.0.zip -d enterprise-17.0

# Get the RDS endpoint address from Terraform output
DB_ADDRESS=$db_address_ext

# Create Odoo configuration file
echo "[options]
admin_passwd = S7wubGONUM4DDuye
http_port = 8069
db_host = $DB_ADDRESS
db_port = 5432
db_user = odoo
db_password = MEisaPre2020++
logfile = /var/log/odoo/odoo-server.log
addons_path = /mnt/extra-addons,/mnt/extra-addons/enterprise-17.0/enterprise-17.0,/usr/lib/python3/dist-packages/odoo/addons" > ~/odoo-docker/config/odoo.conf

# Create Nginx configuration file
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

# Restart Nginx to apply the changes
sudo systemctl restart nginx

# Create Docker Compose file
echo "version: '3.1'

services:
  odoo:
    image: odoo:17
    depends_on:
      - db
    ports:
      - '8069:8069'
    volumes:
      - ~/odoo-docker/config/odoo.conf:/etc/odoo/odoo.conf
      - ~/odoo-docker/addons:/mnt/extra-addons
    environment:
      - ODOO_CONF=/etc/odoo/odoo.conf

  db:
    image: postgres:15

    volumes:
      - ~/odoo-docker/db-data:/var/lib/postgresql/data" > ~/odoo-docker/docker-compose.yml

# Run Docker Compose
cd ~/odoo-docker
sudo docker-compose up -d


sudo useradd --no-create-home node_exporter

wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
tar xzf node_exporter-1.0.1.linux-amd64.tar.gz
sudo cp node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin/node_exporter
rm -rf node_exporter-1.0.1.linux-amd64.tar.gz node_exporter-1.0.1.linux-amd64

echo "[Unit]
Description=Prometheus Node Exporter Service
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/node-exporter.service

sudo systemctl daemon-reload
sudo systemctl enable node-exporter
sudo systemctl start node-exporter
sudo systemctl status node-exporter




# NGINX config

nginx_conf="/etc/nginx/nginx.conf"

# Contenido del archivo nginx.conf
nginx_conf_content='
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  "$remote_addr - $remote_user [$time_local] \"$request\" "
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    keepalive_timeout   65;
    types_hash_max_size 4096;
    client_max_body_size 30000M;
    client_body_buffer_size 200000k;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    server {
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }

# Settings for a TLS enabled server.
#
#    server {
#        listen       443 ssl http2;
#        listen       [::]:443 ssl http2;
#        server_name  _;
#        root         /usr/share/nginx/html;
#
#        ssl_certificate "/etc/pki/nginx/server.crt";
#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
#        ssl_session_cache shared:SSL:1m;
#        ssl_session_timeout  10m;
#        ssl_ciphers PROFILE=SYSTEM;
#        ssl_prefer_server_ciphers on;
#
#        # Load configuration files for the default server block.
#        include /etc/nginx/default.d/*.conf;
#
#        error_page 404 /404.html;
#        location = /404.html {
#        }
#
#        error_page 500 502 503 504 /50x.html;
#        location = /50x.html {
#        }
#    }

}'

# Sobreescribir el contenido en el archivo nginx.conf
echo "$nginx_conf_content" | sudo tee "$nginx_conf" > /dev/null

# Reiniciar Nginx para aplicar los cambios
sudo systemctl restart nginx