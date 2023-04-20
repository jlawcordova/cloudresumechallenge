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

resource "aws_apigatewayv2_api" "cloud-resume-challenge-api" {
  name          = "cloud-resume-challenge"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default-stage" {
  api_id = aws_apigatewayv2_api.cloud-resume-challenge-api.id
  name   = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.cloud-resume-challenge-log-group.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "add-view-count-integration" {
  api_id = aws_apigatewayv2_api.cloud-resume-challenge-api.id

  integration_uri    = aws_lambda_function.add-view-count-function.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"

  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "add-view-count-route" {
  api_id = aws_apigatewayv2_api.cloud-resume-challenge-api.id

  route_key = "PATCH /view-count"
  target    = "integrations/${aws_apigatewayv2_integration.add-view-count-integration.id}"
}

resource "aws_cloudwatch_log_group" "cloud-resume-challenge-log-group" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.cloud-resume-challenge-api.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "cloud-resume-challenge-lambda-permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.add-view-count-function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.cloud-resume-challenge-api.execution_arn}/*/*/view-count"
}