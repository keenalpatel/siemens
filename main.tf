# Create a private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = data.aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24" # Change this if the CIDR block is in use
  availability_zone = "ap-south-1a" # Change this if needed

  tags = {
    Name = "private-subnet"
  }
}

# Create a route table for the private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = data.aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = data.aws_nat_gateway.nat.id
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

# Create the Lambda function
resource "aws_lambda_function" "lambda" {
  function_name = "devops-exam-lambda"
  role          = data.aws_iam_role.lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      SUBNET_ID = aws_subnet.private_subnet.id
      NAME      = "Keenal Vishnubhai Patel" # Replace with your full name
      EMAIL     = "keenalpatel143@gmail.com" # Replace with your email
    }
  }
}