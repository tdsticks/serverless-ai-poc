resource "aws_vpc" "serverless_ai" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "serverless-ai-vpc"
    Environment = var.environment
    Project     = "serverless-ai"
    Owner       = var.owner
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.serverless_ai.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "serverless-ai-public-subnet"
    Environment = var.environment
    Project     = "serverless-ai"
    Owner       = var.owner
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.serverless_ai.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name        = "serverless-ai-private-subnet-a"
    Environment = var.environment
    Project     = "serverless-ai"
    Owner       = var.owner
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.serverless_ai.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name        = "serverless-ai-private-subnet-b"
    Environment = var.environment
    Project     = "serverless-ai"
    Owner       = var.owner
  }
}

resource "aws_security_group" "lambda_sg" {
  vpc_id = aws_vpc.serverless_ai.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "serverless-ai-lambda-sg"
    Environment = var.environment
    Project     = "serverless-ai"
    Owner       = var.owner
  }
}

resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.serverless_ai.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }

  tags = {
    Name        = "serverless-ai-rds-sg"
    Environment = var.environment
    Project     = "serverless-ai"
    Owner       = var.owner
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.serverless_ai.id

  tags = {
    Name        = "serverless-ai-igw"
    Environment = var.environment
    Project     = "serverless-ai"
    Owner       = var.owner
  }
}

resource "aws_eip" "nat_eip" {
  tags = {
    Name        = "serverless-ai-nat-eip"
    Environment = var.environment
    Project     = "serverless-ai"
    Owner       = var.owner
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name        = "serverless-ai-nat-gateway"
    Environment = var.environment
    Project     = "serverless-ai"
    Owner       = var.owner
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.serverless_ai.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "serverless-ai-public-rt"
    Environment = var.environment
    Project     = "serverless-ai"
    Owner       = var.owner
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.serverless_ai.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name        = "serverless-ai-private-rt"
    Environment = var.environment
    Project     = "serverless-ai"
    Owner       = var.owner
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_assoc_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rt.id
}
