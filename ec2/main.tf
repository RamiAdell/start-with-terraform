# Security Group
data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] 
}

resource "aws_security_group" "sg-public-ec2" {
  vpc_id = var.my_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "web-sg" }
}


resource "aws_security_group" "sg-private-ec2" {
  vpc_id = var.my_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.sg-public-ec2.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.sg-public-ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    
  }

  tags = { Name = "web-sg" }
}

resource "aws_security_group" "sg-private-load_balancer" {
  vpc_id = var.my_vpc_id

  ingress {
    description = "Allow HTTP traffic from public instances"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.sg-public-ec2.id]
  }
  
  ingress {
    description = "Allow HTTP traffic from within VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    
    
  }

  tags = { Name = "web-sg" }
}


# Public EC2 (Nginx)
resource "aws_instance" "nginx" {
  count         = 2
  ami           = data.aws_ami.amazon_linux.id # Amazon Linux 2 us-east-1
  instance_type = "t2.micro"
  subnet_id     = var.public_subnet_ids[count.index]
  security_groups = [aws_security_group.sg-public-ec2.id]
  key_name = "rami-key2"

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install nginx -y
              echo '<h1>Hello from Public Nginx $HOSTNAME </h1>' > /usr/share/nginx/html/index.html
              # sudo systemctl enable nginx
              # sudo systemctl restart nginx
              EOF
  
  provisioner "local-exec" {
    command = "echo 'Public Instance ${count.index} - ${self.public_ip}' >> ../instances_info.txt"
  }


  tags = { Name = "nginx-public-${count.index}" }
}

# Private EC2 (Apache)
resource "aws_instance" "apache" {
  count         = 2
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.sg-public-ec2.id]
  associate_public_ip_address = false
  key_name = "rami-key2"

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              echo '<h1>Hello from Private Apache $HOSTNAME </h1>' > /var/www/html/index.html
              sudo systemctl enable httpd
              sudo systemctl start httpd
              EOF
  
  provisioner "local-exec" {
    command = "echo 'Private Instance ${count.index} - ${self.private_ip}' >> ../instances_info.txt"
  }

  tags = { Name = "apache-private-${count.index}" }
}




