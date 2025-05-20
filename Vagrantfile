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