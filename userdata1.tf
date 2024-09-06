locals {
  maven-script = <<-EOF
  #!/bin/bash
  sudo apt-get update -y
  sudo apt-get upgrade -y
  sudo apt-get install maven git -y
  # sudo su -c "git clone https://github.com/CloudHight/application-assessment-repo.git" ubuntu
  EOF
}