terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.63.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }
  required_version = "~> 1.2"
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_dynamodb_table" "view-count-table" {
  name           = "ViewCount"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "Id"

  attribute {
    name = "Id"
    type = "S"
  }

  tags = {
    Project     = "development"
    Environment = "cloudresumechallenge"
  }
}

resource "aws_dynamodb_table" "visitor-table" {
  name           = "Visitor"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "IP"

  attribute {
    name = "IP"
    type = "S"
  }

  tags = {
    Project     = "development"
    Environment = "cloudresumechallenge"
  }
}

resource "aws_s3_bucket" "app-bucket" {
  bucket = "jlawcordova-cloudresumechallenge-development-app"
}

data "archive_file" "add-view-count-archive" {
  type = "zip"

  output_path = "${path.module}/../app.zip"
  excludes    = [
    "${path.module}/../app/README.md",
    "${path.module}/../app/.gitignore"
  ]

  source_dir  = "${path.module}/../app"
}

resource "aws_s3_object" "add-view-count-object" {
  bucket = aws_s3_bucket.app-bucket.id

  key    = "app.zip"
  source = data.archive_file.add-view-count-archive.output_path

  etag = filemd5(data.archive_file.add-view-count-archive.output_path)
}

resource "aws_iam_role" "add-view-count-role" {
  name = "add-view-count-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "add-view-count-policy" {
  name = "AddViewCount"
  role = aws_iam_role.add-view-count-role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid: "GetItemViewCount",
        Effect: "Allow",
        Action: "dynamodb:GetItem",
        Resource: aws_dynamodb_table.view-count-table.arn
      },
      {
        Sid: "UpdateItemViewCount",
        Effect: "Allow",
        Action: "dynamodb:UpdateItem",
        Resource: aws_dynamodb_table.view-count-table.arn
      },
      {
        Sid: "GetItemVisitor",
        Effect: "Allow",
        Action: "dynamodb:GetItem",
        Resource: aws_dynamodb_table.visitor-table.arn
      },
      {
        Sid: "PutItemVisitor",
        Effect: "Allow",
        Action: "dynamodb:PutItem",
        Resource: aws_dynamodb_table.visitor-table.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.add-view-count-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "add-view-count-function" {
  function_name = "addViewCount"

  s3_bucket = aws_s3_bucket.app-bucket.id
  s3_key    = aws_s3_object.add-view-count-object.key

  runtime = "nodejs18.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.add-view-count-archive.output_base64sha256

  role = aws_iam_role.add-view-count-role.arn
}

resource "aws_cloudwatch_log_group" "add-view-count-log-group" {
  name = "/aws/lambda/${aws_lambda_function.add-view-count-function.function_name}"

  retention_in_days = 30
}
