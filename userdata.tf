locals {
  docker-script = <<-EOF
  #!/bin/bash
  sudo apt-get update -y
  sudo apt-get upgrade -y
  sudo apt-get install -y apt-utils
  sudo apt-get-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  sudo apt-get install docker-ce -y
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -aG docker ubuntu
  EOF
}