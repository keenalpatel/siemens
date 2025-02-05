# Declare input variables
variable "NAME" {
  description = "Full name"
  type        = string
  default     = "Keenal Vishnubhai Patel"
}

variable "EMAIL" {
  description = "Email address"
  type        = string
  default     = "keenalpatel143@gmail.com"
}

variable "AWS_REGION" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"  # Set this to your preferred AWS region
}

# Create a private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = data.aws_vpc.vpc.id
  cidr_block        = "10.0.40.0/24" # Hardcoded CIDR block
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

  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      SUBNET_ID = aws_subnet.private_subnet.id
      NAME      = var.NAME
      EMAIL     = var.EMAIL
    }
  }
}

# Null resource to package and upload Lambda
resource "null_resource" "lambda_package_and_upload" {
  provisioner "local-exec" {
    command = "aws lambda update-function-code --function-name devops-exam-lambda --zip-file fileb://lambda.zip --region ${var.AWS_REGION}"
  }
}

# Output the subnet ID for use in the Jenkins pipeline
output "subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "name" {
  value = var.NAME
}

output "email" {
  value = var.EMAIL
}
