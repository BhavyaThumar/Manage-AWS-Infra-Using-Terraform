# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }


provider "aws" {
  region     = "ap-south-1"
  access_key = ""
  secret_key = ""
}

# resource "aws_instance" "my-first-server" {
#   ami           = "ami-007020fd9c84e18c7"
#   instance_type = "t2.micro"
#   tags = {
#     Name = "Terraform"
#   }
# }

# resource "aws_vpc" "terraform_VPC" {
#   cidr_block = "10.0.0.0/16"
#   tags = {
#     Name = "Terraform"
#   }
# }

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.terraform_VPC.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Terraform-Subnet"
  }
}

# Small practice project

resource "aws_vpc" "terraform_VPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Terraform"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.terraform_VPC.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.terraform_VPC.id

  route {
    cidr_block = "0.0.0.0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "example"
  }
}

resource "aws_subnet" "project" {
  vpc_id = aws_vpc.terraform_VPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.project.id
  route_table_id = aws_route_table.example.id
}

resource "aws_security_group" "allow_traffic" {
  name        = "allow_traffic"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.terraform_VPC.id

  tags = {
    Name = "allow_traffic"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  description = "HTTPS"
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv4         = aws_vpc.terraform_VPC.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  description = "HTTP"
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv4         = aws_vpc.terraform_VPC.cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  description = "SSH"
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv4         = aws_vpc.terraform_VPC.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_traffic.id]
}

resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [ aws_internet_gateway.gw ]
}

resource "aws_instance" "web-server-instance" {
  ami           = "ami-007020fd9c84e18c7"
  instance_type = "t2.micro"
  tags = {
    Name = "Terraform_Project"
  }
  availability_zone = "ap-south-1a"
  key_name = "mykey"
  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo your very first web server > /var/www/html/index.html'
                EOF
}

resource "aws_network_interface" "ni1" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.0.50"]
  security_groups = [aws_security_group.allow_traffic.id]

  attachment {
    instance     = aws_instance.web-server-instance.id
    device_index = 0
    
  }

}
