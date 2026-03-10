data "aws_availability_zones" "available" {
  state = "available"

  # Exclude Local Zones and Wavelength Zones. Without this filter, accounts that
  # have opted into those zones will see them returned as "available", which can
  # cause subnet creation to fail due to unsupported instance types or services.
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}


locals {
  az_count = min(
    var.az_count,
    length(data.aws_availability_zones.available.names)
  )
  cidr_bits = 2 # Number of extra bits for splitting cidrsubnet
  # If az_count > 4, cidr_bits needs adjusted

}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = merge(var.tags, {
    Name        = "terrask8s-vpc"
    Project     = var.project
    Environment = var.environment
  })
}

resource "aws_subnet" "terrask8s_subnet" {
  count                   = local.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.cidr_block, local.cidr_bits, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  # Note: Nodes will have a public IP address so that we can do experiments
  #       with the nodes without VPN setup to VPC. This is **another** reason
  #       this is not an ideal production setup (Use EKS for that)

  tags = merge(var.tags, {
    Name        = "terrask8s-subnet-${count.index}"
    Project     = var.project
    Environment = var.environment
  })
}

resource "aws_route_table" "terrask8s" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, {
    Name        = "terrask8s-route-table"
    Project     = var.project
    Environment = var.environment
  })
}

resource "aws_route_table_association" "terrask8s" {
  count          = local.az_count
  subnet_id      = aws_subnet.terrask8s_subnet[count.index].id
  route_table_id = aws_route_table.terrask8s.id
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name        = "terrask8s-igw"
    Project     = var.project
    Environment = var.environment
  })
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_ids" {
  value = aws_subnet.terrask8s_subnet[*].id
}

output "subnet_azs" {
  value = aws_subnet.terrask8s_subnet[*].availability_zone
}
