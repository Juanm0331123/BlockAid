#!/bin/bash

# Actualizamos paquetes
sudo apt-get update -y
sudo apt-get upgrade -y

# Instalamos Node.js y npm 
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs git

# Clonamos el proyecto blockchain básico (aún no hecho)
mkdir -p ~/blockchain-node
cd ~/blockchain-node

# Mensaje de bienvenida
echo "Nodo blockchain preparado 🚀"
