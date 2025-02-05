# Fetch the existing VPC
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["my-vpc"]  # Change to your VPC Name
  }
}

# Fetch the public subnet for NAT Gateway
data "aws_subnet" "public_subnet" {
  filter {
    name   = "tag:Name"
    values = ["public-subnet"]  # Change to your public subnet name
  }
}

# Create a private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = data.aws_vpc.vpc.id
  cidr_block        = cidrsubnet(data.aws_vpc.vpc.cidr_block, 8, 10) # Ensure valid CIDR
  availability_zone = "ap-south-1a"  # Change as per your region

  tags = {
    Name = "private-subnet"
  }
}

# Create an Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# Create a NAT Gateway for private subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = data.aws_subnet.public_subnet.id

  tags = {
    Name = "nat-gateway"
  }
}

# Create a route table for the private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = data.aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Associate the route table with the private subnet
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# Create a security group for the Lambda function
resource "aws_security_group" "lambda_sg" {
  vpc_id = data.aws_vpc.vpc.id

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lambda-security-group"
  }
}

# Fetch the IAM Role for Lambda Execution
data "aws_iam_role" "lambda" {
  name = "lambda-execution-role" # Change to your IAM Role name
}

# Create the Lambda function
resource "aws_lambda_function" "lambda" {
  function_name = "devops-exam-lambda"
  role          = data.aws_iam_role.lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      SUBNET_ID = aws_subnet.private_subnet.id
      NAME      = "Keenal Vishnubhai Patel"
      EMAIL     = "keenalpatel143@gmail.com"
    }
  }
}

# Output the private subnet ID
output "subnet_id" {
  value = aws_subnet.private_subnet.id
}
