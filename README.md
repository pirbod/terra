# Terraform AWS HA Web Infrastructure

This project creates a highly available web infrastructure on AWS using Terraform.  
It includes:

- A custom VPC with public and private subnets.
- NAT Gateways for private subnet outbound traffic.
- An Application Load Balancer (ALB) in public subnets.
- An Auto Scaling Group (ASG) of EC2 instances in private subnets.
- Security Groups restricting traffic to the necessary ports.
- Outputs that expose the ALB DNS name, allowing you to test the deployment.

## Prerequisites

1. **Terraform**: v1.0 or higher.
2. **AWS Credentials**: Configure credentials (e.g., via `aws configure`) with enough permissions to create VPCs, subnets, NAT gateways, ALBs, etc.
3. **AWS CLI** (optional): For general AWS checks.

## Usage

1. **Clone or copy** this repository to your local machine.
2. **Initialize** the project:

   ```bash
   terraform init

3. Review/modify variables in variables.tf or override them in terraform.tfvars
4. terraform plan
5. terraform apply
6. Output the ALB DNS name. Copy/paste it into your browser to test the web page:
    alb_dns_name = "<some-name>.elb.amazonaws.com"
7. terraform destroy

