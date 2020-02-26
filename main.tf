variable "vpc_config" {
  type = object({
    name        = string
    public_key  = string
    allowed_ssh = list(string)
    allowed_web = list(string)
  })
  default = {
    name        = "myvpc"
    public_key  = "ssh-rsa mypublickey"
    allowed_ssh = ["0.0.0.0/0"]
    allowed_web = ["0.0.0.0/0"]
  }
}

variable "bastion_config" {
  type = object({
    image_id      = string
    instance_type = string
    volume_size   = number
    volume_type   = string
    group         = string
  })
  default = {
    image_id      = "ami-04cf43aca3e6f3de3"
    instance_type = "t2.micro"
    volume_size   = 8
    volume_type   = "gp2"
    group         = "bastion"
  }
}

variable "ingress_config" {
  type = object({
    image_id      = string
    instance_type = string
    volume_size   = number
    volume_type   = string
    group         = string
  })
  default = {
    image_id      = "ami-04cf43aca3e6f3de3"
    instance_type = "t2.micro"
    volume_size   = 30
    volume_type   = "gp2"
    group         = "ingress"
  }
}

variable "control_config" {
  type = object({
    image_id      = string
    instance_type = string
    volume_size   = number
    volume_type   = string
    group         = string
  })
  default = {
    image_id      = "ami-04cf43aca3e6f3de3"
    instance_type = "t2.micro"
    volume_size   = 80
    volume_type   = "gp2"
    group         = "control"
  }
}

variable "worker_config" {
  type = object({
    image_id      = string
    instance_type = string
    volume_size   = number
    volume_type   = string
    worker_count  = number
    group         = string
  })
  default = {
    image_id      = "ami-04cf43aca3e6f3de3"
    instance_type = "t2.micro"
    volume_size   = 160
    volume_type   = "gp2"
    worker_count  = 0
    group         = "worker"
  }
}

provider "aws" {
  version    = "~> 2.50"
  region     = "eu-central-1"
}

resource "aws_key_pair" "ansible" {
  key_name   = "ansible-key"
  public_key = var.vpc_config.public_key
}

resource "aws_vpc" "main" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_config.name
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public"
  }
}
