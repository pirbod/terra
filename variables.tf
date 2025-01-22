variable "aws_region" {
  type    = string
  default = "us-east-1"
  description = "AWS region to deploy resources in."
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
  description = "CIDR block for the VPC."
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "List of CIDR blocks for public subnets."
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
  description = "List of CIDR blocks for private subnets."
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
  description = "EC2 instance type for the Auto Scaling Group."
}

variable "asg_min_size" {
  type    = number
  default = 2
  description = "Minimum number of EC2 instances in the Auto Scaling Group."
}

variable "asg_desired_capacity" {
  type    = number
  default = 2
  description = "Desired number of EC2 instances in the Auto Scaling Group."
}

variable "asg_max_size" {
  type    = number
  default = 4
  description = "Maximum number of EC2 instances in the Auto Scaling Group."
}
