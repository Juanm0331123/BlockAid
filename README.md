# 🎯 BlockAid

[![Node.js](https://img.shields.io/badge/Node.js-v18.x-green)](https://nodejs.org/)  
[![MySQL](https://img.shields.io/badge/MySQL-8.x-blue)](https://www.mysql.com/)  
[![Vagrant](https://img.shields.io/badge/Vagrant-v2.x-blueviolet)](https://www.vagrantup.com/)

**Implementación de una red P2P basada en Blockchain para gestión en desastres naturales**  
Coordina gobierno, ONGs y ciudadanos con total trazabilidad, resiliencia y transparencia.

---

## 📋 Tabla de contenidos

1. [Descripción](#-descripción)
2. [Tecnologías](#-tecnologías)
3. [Requisitos Previos](#-requisitos-previos)
4. [Estructura del Proyecto](#-estructura-del-proyecto)
5. [Configuración con Vagrant](#-configuración-con-vagrant)
6. [Provisionamiento de Nodos](#-provisionamiento-de-nodos)
7. [Arranque de la Red P2P](#-arranque-de-la-red-p2p)
8. [Servidor Central de Datos](#-servidor-central-de-datos)
9. [Uso y Pruebas](#-uso-y-pruebas)
10. [Contribuir](#-contribuir)
11. [Licencia](#-licencia)

---

## 🔍 Descripción

BlockAid es una plataforma distribuida que implementa un **blockchain ligero** y una **red peer-to-peer** para gestionar operaciones y coordinar ayudas tras un desastre natural.  
Cada nodo (Gobierno, ONG, Ciudadano) mantiene su copia de la cadena, se sincroniza vía WebSockets P2P y reporta nuevos bloques a un **Servidor-Data** central con MySQL.

---

## 🛠 Tecnologías

- **Node.js v18.x** + **Express**
- **WebSocket** (ws) para capa P2P
- **Vagrant** + **VirtualBox** para VMs
- **MySQL 8.x** para almacenamiento centralizado
- **Bootstrap_nodo.sh** para aprovisionamiento rápido

---

## 💻 Requisitos Previos

- Git
- Vagrant & VirtualBox
- Docker (opcional para MySQL)
- Acceso a Internet para `apt-get` y `npm`

---

## 📂 Estructura del Proyecto

````text
BlockAid/
├── Vagrantfile
├── scripts/
│   └── bootstrap_nodo.sh
├── servidor-node/            # código común a nodos P2P
│   ├── server.js
│   ├── blockchain.js
│   ├── package.json
│   └── public/
│       ├── index.html
│       ├── style.css
│       └── script.js
└── servidor-data/            # nodo central MySQL
    ├── servidor-data.js
    └── README-data.md


---

## ⚙️ Configuración con Vagrant

En la raíz del proyecto (`BlockAid/`), crea un `Vagrantfile` con el siguiente contenido:

```ruby
Vagrant.configure("2") do |config|
  # Box base
  config.vm.box = "ubuntu/focal64"

  # Definición de nodos y sus IPs
  NODOS = [
    { nombre: "nodo-gobierno",   ip: "192.168.56.11" },
    { nombre: "nodo-ong",         ip: "192.168.56.12" },
    { nombre: "nodo-ciudadano",   ip: "192.168.56.13" },
    { nombre: "servidor-data",    ip: "192.168.56.14" }
  ]

  NODOS.each do |nodo|
    config.vm.define nodo[:nombre] do |node|
      node.vm.hostname = nodo[:nombre]
      node.vm.network  "private_network", ip: nodo[:ip]

      node.vm.provider "virtualbox" do |vb|
        vb.name   = nodo[:nombre]
        vb.memory = 1024
        vb.cpus   = 1
      end

      # Shell provisioner
      node.vm.provision "shell", path: "scripts/bootstrap_nodo.sh"
    end
  end
end
````
