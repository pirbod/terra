###################################
# Application Load Balancer
###################################
resource "aws_lb" "app_lb" {
  name               = "challenge-app-lb"
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.alb_sg.id]
  ip_address_type    = "ipv4"

  tags = {
    Name = "challenge-app-lb"
  }
}

###################################
# Target Group
###################################
resource "aws_lb_target_group" "app_tg" {
  name        = "challenge-app-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    protocol = "HTTP"
    path     = "/"
    port     = "80"
  }

  tags = {
    Name = "challenge-app-tg"
  }
}

###################################
# Listener
###################################
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Uncomment and adapt this block if you want HTTPS
# resource "aws_lb_listener" "https_listener" {
#   load_balancer_arn = aws_lb.app_lb.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = "<Your-ACM-Cert-ARN>"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app_tg.arn
#   }
# }
