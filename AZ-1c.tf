resource "aws_eip" "eialloc_01_1c" {
  vpc      = true
}

resource "aws_subnet" "public_01_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.16.5.0/24"
  availability_zone       = "eu-central-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "1c - 172.16.5.0"
  }
}

resource "aws_subnet" "private_01_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.16.6.0/24"
  availability_zone = "eu-central-1c"

  tags = {
    Name = "1c - 172.16.6.0"
  }
}

resource "aws_nat_gateway" "nat_gw_01_1c" {
  allocation_id = aws_eip.eialloc_01_1c.id
  subnet_id     = aws_subnet.public_01_1c.id

  tags = {
    Name = "1c - NAT"
  }
}

resource "aws_route_table" "private_01_1c_nat" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_01_1c.id
  }
}

resource "aws_route_table_association" "public_01_1c" {
  subnet_id      = aws_subnet.public_01_1c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_01_1c" {
  subnet_id      = aws_subnet.private_01_1c.id
  route_table_id = aws_route_table.private_01_1c_nat.id
}

resource "aws_instance" "az-1c-bastion" {
  count                  = 1
  ami                    = var.bastion_config.image_id
  instance_type          = var.bastion_config.instance_type
  availability_zone      = "eu-central-1c"
  key_name               = aws_key_pair.ansible.key_name
  subnet_id              = aws_subnet.public_01_1c.id
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
    Name = "az-1c-bastion-${count.index}"
    role = "bastion"
  }
}

resource "aws_instance" "az-1c-ingress" {
  count                  = 1
  ami                    = var.ingress_config.image_id
  instance_type          = var.ingress_config.instance_type
  availability_zone      = "eu-central-1c"
  key_name               = aws_key_pair.ansible.key_name
  subnet_id              = aws_subnet.public_01_1c.id
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
    Name = "az-1c-ingress-${count.index}"
    group = "ingress"
  }
}

resource "aws_instance" "az-1c-control" {
  count                  = 1
  ami                    = var.control_config.image_id
  instance_type          = var.control_config.instance_type
  availability_zone      = "eu-central-1c"
  key_name               = aws_key_pair.ansible.key_name
  subnet_id              = aws_subnet.private_01_1c.id
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
    Name = "az-1c-control-${count.index}"
    group = "control"
  }
}

resource "aws_instance" "az-1c-worker" {
  count                  = var.worker_config.worker_count
  ami                    = var.worker_config.image_id
  instance_type          = var.worker_config.instance_type
  availability_zone      = "eu-central-1c"
  key_name               = aws_key_pair.ansible.key_name
  subnet_id              = aws_subnet.private_01_1c.id
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
    Name = "az-1c-worker-${count.index}"
    group = "worker"
  }
}
