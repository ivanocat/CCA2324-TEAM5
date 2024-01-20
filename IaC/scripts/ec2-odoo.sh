#!/bin/bash

# Update the system
sudo apt update -y
sudo apt upgrade -y

# Install necessary dependencies
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Configure the Docker stable repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index
sudo apt update -y

# Install Docker and Docker Compose
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose

# Start and enable the Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Create a directory for Docker Compose configuration files
mkdir ~/odoo-docker
cd ~/odoo-docker

# Create a docker-compose.yml file with the provided content
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

# Start the containers with Docker Compose without prompting for confirmation
sudo docker-compose up -d

# Configure Nginx on the host system
sudo apt install -y nginx

# Create a configuration file for Nginx
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

# Create a symbolic link to the configuration file
sudo ln -s /etc/nginx/sites-available/odoo /etc/nginx/sites-enabled/

# Restart Nginx to apply the changes
sudo systemctl restart nginx