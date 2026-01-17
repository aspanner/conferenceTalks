# 1. AWS Provider - Singapore
provider "aws" {
  region = "ap-southeast-1"
}

# 2. Network Infrastructure (VPC, IGW, Subnet, Routes)
resource "aws_vpc" "fedora_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "fedora-metal-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.fedora_vpc.id
}

resource "aws_subnet" "fedora_subnet" {
  vpc_id                  = aws_vpc.fedora_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  # Metal instances are only available in specific Availability Zones
  availability_zone       = "ap-southeast-1a" 
  tags                    = { Name = "fedora-subnet" }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.fedora_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.fedora_subnet.id
  route_table_id = aws_route_table.rt.id
}

# 3. Security Group
resource "aws_security_group" "fedora_sg" {
  name   = "fedora-metal-sg"
  vpc_id = aws_vpc.fedora_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. Modern SSH Key Management
resource "tls_private_key" "generated_key" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "fedora_key" {
  key_name   = "fedora-key-metal"
  public_key = tls_private_key.generated_key.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.generated_key.private_key_pem
  filename        = "${path.module}/fedora-key-auto.pem"
  file_permission = "0600"
}

# 5. The 20 Bare Metal Fedora Servers
resource "aws_instance" "fedora_nodes" {
  count         = 2
  ami           = "ami-0bf87ec5c4b4e5041" # Fedora 42
  
  # BARE METAL INSTANCE TYPE
  instance_type = "c5.metal" 
  
  key_name               = aws_key_pair.fedora_key.key_name
  subnet_id              = aws_subnet.fedora_subnet.id
  vpc_security_group_ids = [aws_security_group.fedora_sg.id]

  root_block_device {
    volume_size = 50 # Larger disk for MicroShift + VMs
    volume_type = "gp3"
  }

  user_data = <<-EOF
    #cloud-config
    growpart:
      mode: auto
      devices: ['/']
    users:
      - default
      - name: redhat
        groups: wheel
        sudo: ALL=(ALL) NOPASSWD:ALL
        lock_passwd: false
    chpasswd:
      list: |
        redhat:redhat
      expire: False
    ssh_pwauth: True
  EOF

  tags = {
    Name        = "Fedora-Metal-${count.index + 1}"
    Role        = "fedora-server"
    ServerIndex = "${count.index + 1}"
  }
}

output "instance_ips" {
  value = {
    for i in aws_instance.fedora_nodes : i.tags.Name => i.public_ip
  }
}