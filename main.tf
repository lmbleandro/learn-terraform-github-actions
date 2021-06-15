terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.26.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
  }
  required_version = "~> 0.14"

  backend "remote" {
    organization = "gh-actions-demo"

    workspaces {
      name = "gh-actions-demo"
    }
  }
}


provider "aws" {
  region = "us-east-1"
}



resource "random_pet" "sg" {}


resource "aws_instance" "web" {
  ami                    = "ami-0dbd8c88f9060cf71"
  instance_type          = "t3.medium"
  vpc_security_group_ids = ["sg-0318e8365e2eb2bf8"]
  subnet_id = "subnet-02209f26178602a99"

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"
  vpc_id      = "vpc-0cce9ff1d20494f61"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "web-address" {
  value = "${aws_instance.web.public_dns}:8080"
}