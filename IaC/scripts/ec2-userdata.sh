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

# NGINX config
cat <<EOF | sudo tee /etc/nginx/conf.d/custom.conf
client_max_body_size 30000M;
client_body_buffer_size 200000k;
EOF

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
