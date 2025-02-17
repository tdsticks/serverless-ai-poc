resource "aws_vpc" "serverless_ai_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "serverless-ai-vpc"
    Environment = "demo"
    Project     = "serverless-ai"
  }
}

resource "aws_subnet" "serverless_ai_public_subnet" {
  vpc_id                  = aws_vpc.serverless_ai_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "serverless-ai-public-subnet"
    Environment = "demo"
    Project     = "serverless-ai"
  }
}

resource "aws_subnet" "serverless_ai_private_subnet" {
  vpc_id            = aws_vpc.serverless_ai_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name        = "serverless-ai-private-subnet"
    Environment = "demo"
    Project     = "serverless-ai"
  }
}

resource "aws_security_group" "serverless_ai_lambda_sg" {
  vpc_id = aws_vpc.serverless_ai_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "serverless-ai-lambda-sg"
    Environment = "demo"
    Project     = "serverless-ai"
  }
}

resource "aws_security_group" "serverless_ai_rds_sg" {
  vpc_id = aws_vpc.serverless_ai_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    # cidr_blocks = ["10.0.0.0/16"]
    security_groups = [aws_security_group.serverless_ai_lambda_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "serverless-ai-rds-sg"
    Environment = "demo"
    Project     = "serverless-ai"
  }
}

resource "aws_internet_gateway" "serverless_ai_igw" {
  vpc_id = aws_vpc.serverless_ai_vpc.id

  tags = {
    Name        = "serverless-ai-igw"
    Environment = "demo"
    Project     = "serverless-ai"
  }
}

resource "aws_route_table" "serverless_ai_public_rt" {
  vpc_id = aws_vpc.serverless_ai_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.serverless_ai_igw.id
  }

  tags = {
    Name        = "serverless-ai-public-rt"
    Environment = "demo"
    Project     = "serverless-ai"
  }
}

resource "aws_route_table_association" "serverless_ai_public_rt_association" {
  subnet_id      = aws_subnet.serverless_ai_public_subnet.id
  route_table_id = aws_route_table.serverless_ai_public_rt.id
}

resource "aws_eip" "serverless_ai_nat_eip" {
  tags = {
    Name        = "serverless-ai-nat-eip"
    Environment = "demo"
    Project     = "serverless-ai"
  }
}

resource "aws_nat_gateway" "serverless_ai_nat_gateway" {
  allocation_id = aws_eip.serverless_ai_nat_eip.id
  subnet_id     = aws_subnet.serverless_ai_public_subnet.id

  tags = {
    Name        = "serverless-ai-nat-gateway"
    Environment = "demo"
    Project     = "serverless-ai"
  }
}

resource "aws_route_table" "serverless_ai_private_rt" {
  vpc_id = aws_vpc.serverless_ai_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.serverless_ai_nat_gateway.id
  }

  tags = {
    Name        = "serverless-ai-private-rt"
    Environment = "demo"
    Project     = "serverless-ai"
  }
}

resource "aws_route_table_association" "serverless_ai_private_rt_association_a" {
  subnet_id      = aws_subnet.serverless_ai_private_subnet_a.id
  route_table_id = aws_route_table.serverless_ai_private_rt.id
}

resource "aws_route_table_association" "serverless_ai_private_rt_association_b" {
  subnet_id      = aws_subnet.serverless_ai_private_subnet_b.id
  route_table_id = aws_route_table.serverless_ai_private_rt.id
}
