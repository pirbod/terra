###################################
# Launch Template
###################################
resource "aws_launch_template" "web_lt" {
  name_prefix   = "challenge-web-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # Script to install and start a simple web server
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Terraform EC2 in ASG - \$(hostname)</h1>" > /var/www/html/index.html
              EOF

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "challenge-web-server"
    }
  }
}

###################################
# Auto Scaling Group
###################################
resource "aws_autoscaling_group" "web_asg" {
  name                = "challenge-web-asg"
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  desired_capacity    = var.asg_desired_capacity
  vpc_zone_identifier = aws_subnet.private[*].id
  health_check_type   = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  # Ensures Terraform re-creates ASG properly
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "challenge-web-server"
    propagate_at_launch = true
  }
}

# Optional: Wait for instances to be healthy in the target group
#resource "aws_autoscaling_attachment" "asg_attachment" {
#  autoscaling_group_name = aws_autoscaling_group.web_asg.name
#  alb_target_group_arn   = aws_lb_target_group.app_tg.arn
#}
