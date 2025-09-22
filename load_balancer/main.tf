# Load Balancer
resource "aws_lb" "public" {
  name               = "public-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [var.public_sg_id]
}


resource "aws_lb_target_group" "tg" {
  name     = "nginx-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.my_vpc_id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.public.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_target_group_attachment" "nginx" {
  count            = length(var.nginx_ids)
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = var.nginx_ids[count.index]
  port             = 80
}


resource "aws_lb" "private" {
  name               = "private-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.private_sg_id]
  subnets            = var.private_subnets_id
  enable_deletion_protection = false

}


resource "aws_lb_target_group" "lab3_private_tg" {
  name     = "lab3-private-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.my_vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold  = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "lab3_private_tg_attachment" {
  count            = length(var.apache_ids)

  target_group_arn = aws_lb_target_group.lab3_private_tg.arn
  target_id        = var.apache_ids[count.index]
  port             = 80
  depends_on       = [ aws_lb_target_group.lab3_private_tg ]
}

resource "aws_lb_listener" "lab3_private_listener" {
  load_balancer_arn = aws_lb.private.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lab3_private_tg.arn
  }
  
}