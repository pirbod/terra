###################################
# ALB Security Group
###################################
resource "aws_security_group" "alb_sg" {
  name        = "challenge-alb-sg"
  description = "Allow inbound HTTP/HTTPS from the internet, outbound to web servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP in"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Uncomment this block if you want to allow HTTPS
  # ingress {
  #   description = "Allow HTTPS in"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    description = "Outbound to web servers on HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # Since web servers are in the same VPC, we can limit to the VPC CIDR or use "0.0.0.0/0"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name = "challenge-alb-sg"
  }
}

###################################
# EC2 Security Group
###################################
resource "aws_security_group" "web_sg" {
  name        = "challenge-web-sg"
  description = "Allow inbound from ALB only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "Allow HTTP from ALB"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "challenge-web-sg"
  }
}
