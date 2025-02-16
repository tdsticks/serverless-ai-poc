resource "aws_db_subnet_group" "serverless_ai_db_subnet_group" {
  name       = "serverless-ai-db-subnet-group"
  subnet_ids = [aws_subnet.serverless_ai_private_subnet_a.id, aws_subnet.serverless_ai_private_subnet_b.id]

  tags = {
    Name        = "serverless-ai-db-subnet-group"
    Environment = "demo"
    Project     = "serverless-ai"
  }
}

resource "aws_db_instance" "serverless_ai_db" {
  identifier           = "serverless-ai-db"
  engine               = "postgres"
  engine_version       = "16"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  db_name              = "serverlessai"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.postgres16"
  db_subnet_group_name = aws_db_subnet_group.serverless_ai_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.serverless_ai_rds_sg.id]
  publicly_accessible  = false
  skip_final_snapshot  = true
  storage_type         = "gp2"
  multi_az             = false

  tags = {
    Name        = "serverless-ai-db"
    Environment = "demo"
    Project     = "serverless-ai"
  }
}

variable "db_username" {}
variable "db_password" {}

resource "aws_subnet" "serverless_ai_private_subnet_a" {
  vpc_id            = aws_vpc.serverless_ai_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name        = "serverless-ai-private-subnet-a"
    Environment = "demo"
    Project     = "serverless-ai"
  }
}

resource "aws_subnet" "serverless_ai_private_subnet_b" {
  vpc_id            = aws_vpc.serverless_ai_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name        = "serverless-ai-private-subnet-b"
    Environment = "demo"
    Project     = "serverless-ai"
  }
}
