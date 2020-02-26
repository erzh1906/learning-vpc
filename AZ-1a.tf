resource "aws_eip" "eialloc_01_1a" {
  vpc      = true
}

resource "aws_subnet" "public_01_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.16.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "1a - 172.16.1.0"
  }
}

resource "aws_subnet" "private_01_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.16.2.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "1a - 172.16.2.0"
  }
}

resource "aws_nat_gateway" "nat_gw_01_1a" {
  allocation_id = aws_eip.eialloc_01_1a.id
  subnet_id     = aws_subnet.public_01_1a.id

  tags = {
    Name = "1a - NAT"
  }
}

resource "aws_route_table" "private_01_1a_nat" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_01_1a.id
  }
}

resource "aws_route_table_association" "public_01_1a" {
  subnet_id      = aws_subnet.public_01_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_01_1a" {
  subnet_id      = aws_subnet.private_01_1a.id
  route_table_id = aws_route_table.private_01_1a_nat.id
}

resource "aws_instance" "az-1a-bastion" {
  count                  = 1
  ami                    = var.bastion_config.image_id
  instance_type          = var.bastion_config.instance_type
  availability_zone      = "eu-central-1a"
  key_name               = aws_key_pair.ansible.key_name
  subnet_id              = aws_subnet.public_01_1a.id
  root_block_device      {
    delete_on_termination = true
    volume_size           = var.bastion_config.volume_size
    volume_type           = var.bastion_config.volume_type
    encrypted             = false
  }

  vpc_security_group_ids = [
    aws_security_group.ssh.id,
    aws_vpc.main.default_security_group_id,
  ]
  tags = {
    Name = "az-1a-bastion-${count.index}"
    group = var.bastion_config.group
  }
}

resource "aws_instance" "az-1a-ingress" {
  count                  = 1
  ami                    = var.ingress_config.image_id
  instance_type          = var.ingress_config.instance_type
  availability_zone      = "eu-central-1a"
  key_name               = aws_key_pair.ansible.key_name
  subnet_id              = aws_subnet.public_01_1a.id
  root_block_device      {
    delete_on_termination = true
    volume_size           = var.ingress_config.volume_size
    volume_type           = var.ingress_config.volume_type
    encrypted             = false
  }

  vpc_security_group_ids = [
    aws_security_group.web.id,
    aws_vpc.main.default_security_group_id,
  ]
  tags = {
    Name = "az-1a-ingress-${count.index}"
    group = var.ingress_config.group
  }
}

resource "aws_instance" "az-1a-control" {
  count                  = 1
  ami                    = var.control_config.image_id
  instance_type          = var.control_config.instance_type
  availability_zone      = "eu-central-1a"
  key_name               = aws_key_pair.ansible.key_name
  subnet_id              = aws_subnet.private_01_1a.id
  root_block_device      {
    delete_on_termination = true
    volume_size           = var.control_config.volume_size
    volume_type           = var.control_config.volume_type
    encrypted             = false
  }

  vpc_security_group_ids = [
    aws_vpc.main.default_security_group_id,
  ]
  tags = {
    Name = "az-1a-control-${count.index}"
    group = var.control_config.group
  }
}

resource "aws_instance" "az-1a-worker" {
  count                  = var.worker_config.worker_count
  ami                    = var.worker_config.image_id
  instance_type          = var.worker_config.instance_type
  availability_zone      = "eu-central-1a"
  key_name               = aws_key_pair.ansible.key_name
  subnet_id              = aws_subnet.private_01_1a.id
  root_block_device      {
    delete_on_termination = true
    volume_size           = var.worker_config.volume_size
    volume_type           = var.worker_config.volume_type
    encrypted             = false
  }

  vpc_security_group_ids = [
    aws_vpc.main.default_security_group_id,
  ]
  tags = {
    Name = "az-1a-worker-${count.index}"
    group = var.worker_config.group
  }
}
