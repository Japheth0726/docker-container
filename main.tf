provider "aws" {
  profile = "default"
  region  = "eu-west-3"
}

# RSA key of size 4096 bits
resource "tls_private_key" "keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# creating private key
resource "local_file" "keypair" {
  content         = tls_private_key.keypair.private_key_pem
  filename        = "docker.pem"
  file_permission = "600"
}
# creating ec2 keypair
resource "aws_key_pair" "keypair" {
  key_name   = "docker-keypair"
  public_key = tls_private_key.keypair.public_key_openssh
}

# security group for docker
resource "aws_security_group" "docker-sg" {
  name        = "docker-sg"
  description = "Allow Inbound Traffic"
  ingress {
    description = "application port"
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh access"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "nginx access"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "docker-sg"
  }
}

# security group for maven
resource "aws_security_group" "maven-sg" {
  name        = "maven-sg"
  description = "Allow Inbound Traffic"
  ingress {
    description = "ssh access"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "maven-sg"
  }
}

# creating ec2 for docker vault
resource "aws_instance" "docker" {
  ami                         = "ami-04a92520784b93e73" //ubuntu
  instance_type               = "t3.medium"
  vpc_security_group_ids      = [aws_security_group.docker-sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.keypair.id
  user_data                   = local.docker-script // file("./userdata.sh")
  tags = {
    Name = "docker-server"
  }
}

# creating ec2 for maven vault
resource "aws_instance" "maven" {
  ami                         = "ami-04a92520784b93e73" //ubuntu
  instance_type               = "t3.medium"
  vpc_security_group_ids      = [aws_security_group.maven-sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.keypair.id
  user_data                   = local.maven-script // file("./userdata1.sh")
  tags = {
    Name = "maven-server"
  }
}

output "Docker-ip" {
  value = aws_instance.docker.public_ip
}

output "Maven-ip" {
  value = aws_instance.maven.public_ip
}