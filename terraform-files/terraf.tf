########### AWS Provider Configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  # Configuration options
  profile = "aws" #local profile configured aws cli
  region  = "us-east-1"
}

########### Locals

locals {
  region = "us-east-1"

  tags = {
    Created     = var.created
    Environment = var.environment
    Project     = var.project
  }
}

########### VPC Community Module

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "digital-riptides-labs"
  cidr = "172.16.0.0/16"

  azs                 = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets     = ["172.16.0.0/19", "172.16.32.0/19", "172.16.64.0/19"]
  public_subnets      = ["172.16.96.0/19", "172.16.128.0/19", "172.16.160.0/19"]


  enable_nat_gateway = false
  enable_vpn_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  map_public_ip_on_launch = true

  tags = {
    Created     = var.created
    Environment = var.environment
    Project     = var.project
  }
}

########### HTTP IN Security Group

resource "aws_security_group" "allow_http" {
  name        = "allow_http_https"
  description = "Allow HTTP inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Referring to the OUTPUT (not the attribute)
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "allow_https"
    Created     = var.created
    Environment = var.environment
    Project     = var.project
  }
}

########### EC2 Instance Module

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "single-instance-${var.project}"

  ami                    = "ami-06767d4c1bae2d694" #Personal AMI with running copy of FLASK app  
  instance_type          = "t2.micro"
  key_name               = "digitalriptideslabs"
  monitoring             = true
  availability_zone           = element(module.vpc.azs, 0)
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  subnet_id              =  element(module.vpc.public_subnets, 0) #Referencing the OUTPUT, which is a list, using the element function
  associate_public_ip_address = true

  tags = {
    Created     = var.created
    Environment = var.environment
    Project     = var.project
  }
}