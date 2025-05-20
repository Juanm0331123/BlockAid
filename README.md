# 🎯 BlockAid

[![Node.js](https://img.shields.io/badge/Node.js-v18.x-green)](https://nodejs.org/)  
[![MySQL](https://img.shields.io/badge/MySQL-8.x-blue)](https://www.mysql.com/)  
[![Vagrant](https://img.shields.io/badge/Vagrant-v2.x-blueviolet)](https://www.vagrantup.com/)

**Implementación de una red P2P basada en Blockchain para gestión en desastres naturales**  
Coordina gobierno, ONGs y ciudadanos con total trazabilidad, resiliencia y transparencia.

---

## 📋 Tabla de Contenidos

1. [Descripción](#descripción)  
2. [Tecnologías](#tecnologías)  
3. [Requisitos Previos](#requisitos-previos)  
4. [Estructura del Proyecto](#estructura-del-proyecto)  
5. [Configuración con Vagrant](#configuración-con-vagrant)  
6. [Provisionamiento de Nodos](#provisionamiento-de-nodos)  
7. [Arranque de la Red P2P](#arranque-de-la-red-p2p)  
8. [Servidor Central de Datos](#servidor-central-de-datos)  
9. [Uso y Pruebas](#uso-y-pruebas)  
10. [Contribuir](#contribuir)  
11. [Licencia](#licencia)  

---

## 🔍 Descripción

BlockAid es una plataforma distribuida que implementa:

- Un **blockchain ligero** (JavaScript + SHA-256)  
- Una **red peer-to-peer** (WebSockets)  
- Un **servidor central** con MySQL

para gestionar operaciones tras un desastre natural.  
Los nodos Gobierno, ONG y Ciudadano mantienen su propia copia de la cadena, se sincronizan entre sí y además replican bloques en un servidor central de datos.

---

## 🛠 Tecnologías

- **Node.js v18.x** + **Express**, **ws**, **Axios**  
- **Vagrant v2.x** + **VirtualBox**  
- **MySQL 8.x** (o Docker MySQL)  
- **Bash** (bootstrap script)  

---

## 💻 Requisitos Previos

- Git  
- Vagrant & VirtualBox  
- MySQL (o Docker)  
- Conexión a Internet para `apt-get` y `npm`

---

## 📂 Estructura del Proyecto

```text
BlockAid/
├── Vagrantfile
├── scripts/
│   └── bootstrap_nodo.sh
├── servidor-node/            # código de nodos P2P
│   ├── server.js
│   ├── blockchain.js
│   ├── package.json
│   └── public/
│       ├── index.html
│       ├── style.css
│       └── script.js
└── servidor-data/            # servidor central MySQL
    └── servidor-data.js
```

## ⚙️ Configuración con Vagrant

Define cuatro VMs en Vagrantfile:

```ruby
Vagrant.configure("2") do |config|
  # Configuración general para todas las máquinas
  config.vm.box = "ubuntu/focal64"

  NODOS = [
    { :nombre => "nodo-gobierno", :ip => "192.168.56.11" },
    { :nombre => "nodo-ong", :ip => "192.168.56.12" },
    { :nombre => "nodo-ciudadano", :ip => "192.168.56.13" },
    { :nombre => "servidor-data", :ip => "192.168.56.14" },
  ]

  NODOS.each do |nodo|
    config.vm.define nodo[:nombre] do |node|
      node.vm.hostname = nodo[:nombre]
      node.vm.network "private_network", ip: nodo[:ip]
      node.vm.provider "virtualbox" do |vb|
        vb.name = nodo[:nombre]
      end

      node.vm.provision "shell", path: "scripts/bootstrap_nodo.sh"
    end
  end
end
```

## 🔧 scripts/bootstrap_nodo.sh

```bash
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
```

## 🚀 Provisionamiento de Nodos

Inicializar VMs:

```bash
cd BlockAid
vagrant up
```

SSH a cada nodo:

```bash
vagrant ssh nodo-gobierno
```

Copiar código y dependencias:

```bash
mkdir -p ~/blockchain-node
cp -r /vagrant/servidor-node/* ~/blockchain-node/
cd ~/blockchain-node
npm install express ws axios
```

## 🏁 Arranque de la Red P2P

En cada nodo, dentro de ~/blockchain-node:

```bash
# Nodo 1 (Gobierno)
HTTP_PORT=3001 P2P_PORT=6001 node server.js

# Nodo 2 (ONG)
HTTP_PORT=3002 P2P_PORT=6002 PEERS=ws://192.168.56.11:6001 node server.js

# Nodo 3 (Ciudadano)
HTTP_PORT=3003 P2P_PORT=6003 PEERS=ws://192.168.56.12:6002 node server.js
```

Endpoints REST:

- `GET /blocks` → devuelve la blockchain
- `POST /mine` → mina un bloque con { tipo, emisor, mensaje, ubicacion }
- `PUT /block/:index` → actualiza un bloque
- `DELETE /block/:index` → elimina un bloque

WebSockets P2P:
- Mensajes `QUERY_LATEST`, `QUERY_ALL`, `RESPONSE_BLOCKCHAIN`
- Consenso "cadena más larga"

## 🗄️ Servidor Central de Datos

En la VM servidor-data:

Instalar MySQL:

```bash
sudo apt-get install -y mysql-server
```

Configurar base de datos:

```sql
CREATE DATABASE IF NOT EXISTS blockchain_p2p;
USE blockchain_p2p;

CREATE TABLE bloques (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  indice     INT NOT NULL,
  hash       VARCHAR(255) NOT NULL,
  prev_hash  VARCHAR(255),
  timestamp  BIGINT NOT NULL,
  tipo       VARCHAR(50),
  emisor     VARCHAR(100),
  mensaje    TEXT,
  ubicacion  VARCHAR(100)
);

CREATE USER 'blockuser'@'localhost' IDENTIFIED BY 'blockpass';
GRANT ALL PRIVILEGES ON blockchain_p2p.* TO 'blockuser'@'localhost';
FLUSH PRIVILEGES;
```

Arrancar servicio:

```bash
cd /vagrant/servidor-data
npm install express mysql2
node servidor-data.js
```
– API en http://192.168.56.14:4000
- `GET /bloques` → lee bloques de MySQL
- `POST /save-block` → inserta nuevos bloques

## 🎬 Uso y Pruebas

Minar bloque:

```bash
curl -X POST http://<IP_NODO>:<PUERTO>/mine \
  -H "Content-Type: application/json" \
  -d '{"tipo":"rescate","emisor":"gobierno","mensaje":"Envio de suministros","ubicacion":"Zona A"}'
```

Ver cadena:
- Visitar http://<IP_NODO>:<PUERTO>/blocks o abrir public/index.html

Actualizar/Eliminar bloque:
- `PUT /block/2`
- `DELETE /block/2`

## 🤝 Contribuir

1. Haz un fork de este repositorio.
2. Crea una rama (`git checkout -b feature/nueva-funcionalidad`).
3. Haz commit de tus cambios (`git commit -m "Agrega ..."`) y push (`git push origin feature/...`).
4. Abre un Pull Request detallando tu aporte.

## 📄 Licencia

Este proyecto está bajo la MIT License.
© 2025 BlockAid Team
