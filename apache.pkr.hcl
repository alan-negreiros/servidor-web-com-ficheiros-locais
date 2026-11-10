# 1. Bloco do Plugin: ensina o Packer a falar com o Docker
packer {
  required_plugins {
    docker = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/docker"
    }
  }
}

# 2. Bloco da Fonte: imagem base e commit do contentor como imagem final
source "docker" "ubuntu" {
  image  = "ubuntu:jammy"
  commit = true

  # Metadados aplicados à imagem final
  changes = [
    "EXPOSE 80",
    "CMD [\"apache2ctl\", \"-D\", \"FOREGROUND\"]"
  ]
}

build {
  name    = "meu-apache-packer"
  sources = ["source.docker.ubuntu"]

  # 3a. Primeiro instala o Apache: é isto que cria a pasta /var/www/html/
  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline = [
      "apt-get update",
      "apt-get install -y apache2",
      "rm -rf /var/lib/apt/lists/*"
    ]
  }

  # 3b. Só depois copia o index.html local para a pasta do Apache
  provisioner "file" {
    source      = "${path.root}/index.html"
    destination = "/var/www/html/index.html"
  }

  # 4. Bloco de Etiqueta: dá um nome legível à imagem
  post-processor "docker-tag" {
    repository = "meu-apache-packer"
    tags       = ["latest"]
  }
}
