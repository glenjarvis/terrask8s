data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"] # Official Debian AWS account

  filter {
    name   = "name"
    values = ["debian-13-amd64-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "node" {
  count                  = length(var.subnet_ids)
  ami                    = var.ami_id != null ? var.ami_id : data.aws_ami.debian.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index]
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  tags = merge(var.tags, {
    Name        = "terrask8s-${var.environment}-node-${count.index}"
    Project     = var.project
    Environment = var.environment
  })
}

output "instance_ids" {
  value = aws_instance.node[*].id
}

output "public_ips" {
  value = aws_instance.node[*].public_ip
}

output "private_ips" {
  value = aws_instance.node[*].private_ip
}