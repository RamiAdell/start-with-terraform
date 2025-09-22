module "vpc" {
  source = "./vpc"
}

module "subnets" {
  source   = "./subnets"
  my_vpc_id = module.vpc.vpc_id

}

module "ec2" {
  source             = "./ec2"
  my_vpc_id          = module.vpc.vpc_id
  public_subnet_ids  = module.subnets.public_subnet_ids
  private_subnet_ids = module.subnets.private_subnet_ids
  vpc_cidr           = module.vpc.vpc_cidr
}

output "test" {
  description = "sssssssssssssssssssssssssssssbalancer"
  value       = module.ec2.nginx_ids[0]
}

module "lb" {
  source            = "./load_balancer"
  public_subnet_ids = module.subnets.public_subnet_ids 
  nginx_ids         = module.ec2.nginx_ids
  my_vpc_id        = module.vpc.vpc_id 
  private_subnets_id = module.subnets.private_subnet_ids
  apache_ids       = module.ec2.apache_ids
  private_sg_id    = module.ec2.sg-private-ec2
  public_sg_id     = module.ec2.sg-public-ec2
}

resource "null_resource" "write_public_ips" {
  provisioner "local-exec" {
    command = <<EOT
echo "public-ip1 ${module.ec2.nginx_public_ips[0]}" > all-ips.txt
echo "public-ip2 ${module.ec2.nginx_public_ips[1]}" >> all-ips.txt
EOT
  }
}

resource "null_resource" "configure_redirect" {
  count = length(module.ec2.nginx_ids)
  depends_on = [module.ec2, module.lb]

  triggers = {
    lb_dns = module.lb.lb_dns
    instance_id = module.ec2.nginx_ids[count.index]
    force_run  = timestamp() # Force re-run on every apply
  }



  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"  
      private_key = file(var.key_path)
      host        = module.ec2.nginx_public_ips[count.index]
    }

    inline = [
      "echo 'Configuring redirect to ${module.lb.lb_dns} on instance ${count.index + 1}'",
      "sudo yum update -y",
      "sudo amazon-linux-extras install nginx1 -y",
      "sudo rm -f /etc/nginx/nginx.conf",
      "sudo tee /etc/nginx/nginx.conf > /dev/null <<EOF",
      "events {",
      "    worker_connections 1024;",
      "}",
      "http {",
      "    upstream private_lb {",
      "        server ${module.lb.lb_private_dns}:80;",
      "    }",
      "    server {",
      "        listen 80;",
      "        server_name _;",
      "        location / {",
      "            proxy_pass http://private_lb;",
      "            proxy_set_header Host \\$host;",
      "            proxy_set_header X-Real-IP \\$remote_addr;",
      "            proxy_set_header X-Forwarded-For \\$proxy_add_x_forwarded_for;",
      "            proxy_set_header X-Forwarded-Proto \\$scheme;",
      "            proxy_connect_timeout 30s;",
      "            proxy_send_timeout 30s;",
      "            proxy_read_timeout 30s;",
      "        }",
      "        location /health {",
      "            return 200 'OK from Public Instance ${count.index + 1}';",
      "            add_header Content-Type text/plain;",
      "        }",
      "    }",
      "}",
      "EOF",
      "sudo nginx -t",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "sudo systemctl status nginx",
      "echo 'Nginx reverse proxy configured successfully on instance ${count.index + 1}'"
    ]
  }
}