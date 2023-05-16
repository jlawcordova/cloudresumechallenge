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

resource "random_pet" "project" {
  length = 2
}

module "app" {
  source = "./modules/app"

  environment = "development"
  project = "cloud-resume-challenge-${random_pet.project.id}"
}

# resource "aws_s3_bucket" "app-bucket" {
#   bucket = "jlawcordova-cloudresumechallenge-development-app"
# }

# data "archive_file" "add-view-count-archive" {
#   type = "zip"

#   output_path = "${path.module}/../app.zip"
#   excludes    = [
#     "${path.module}/../app/README.md",
#     "${path.module}/../app/.gitignore"
#   ]

#   source_dir  = "${path.module}/../app"
# }

# resource "aws_s3_object" "add-view-count-object" {
#   bucket = aws_s3_bucket.app-bucket.id

#   key    = "app.zip"
#   source = data.archive_file.add-view-count-archive.output_path

#   etag = filemd5(data.archive_file.add-view-count-archive.output_path)
# }

# resource "aws_iam_role" "add-view-count-role" {
#   name = "add-view-count-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy" "add-view-count-policy" {
#   name = "AddViewCount"
#   role = aws_iam_role.add-view-count-role.id

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid: "GetItemViewCount",
#         Effect: "Allow",
#         Action: "dynamodb:GetItem",
#         Resource: aws_dynamodb_table.view-count-table.arn
#       },
#       {
#         Sid: "UpdateItemViewCount",
#         Effect: "Allow",
#         Action: "dynamodb:UpdateItem",
#         Resource: aws_dynamodb_table.view-count-table.arn
#       },
#       {
#         Sid: "GetItemVisitor",
#         Effect: "Allow",
#         Action: "dynamodb:GetItem",
#         Resource: aws_dynamodb_table.visitor-table.arn
#       },
#       {
#         Sid: "PutItemVisitor",
#         Effect: "Allow",
#         Action: "dynamodb:PutItem",
#         Resource: aws_dynamodb_table.visitor-table.arn
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "lambda_policy" {
#   role       = aws_iam_role.add-view-count-role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

# resource "aws_lambda_function" "add-view-count-function" {
#   function_name = "addViewCount"

#   s3_bucket = aws_s3_bucket.app-bucket.id
#   s3_key    = aws_s3_object.add-view-count-object.key

#   runtime = "nodejs18.x"
#   handler = "index.handler"

#   source_code_hash = data.archive_file.add-view-count-archive.output_base64sha256

#   role = aws_iam_role.add-view-count-role.arn
# }

# resource "aws_cloudwatch_log_group" "add-view-count-log-group" {
#   name = "/aws/lambda/${aws_lambda_function.add-view-count-function.function_name}"

#   retention_in_days = 30
# }

# resource "aws_apigatewayv2_api" "cloud-resume-challenge-api" {
#   name          = "cloud-resume-challenge"
#   protocol_type = "HTTP"
#   cors_configuration {
#     allow_methods = ["PATCH"]
#     allow_origins = ["*"]
#   }
# }

# resource "aws_apigatewayv2_stage" "default-stage" {
#   api_id = aws_apigatewayv2_api.cloud-resume-challenge-api.id
#   name   = "$default"
#   auto_deploy = true

#   access_log_settings {
#     destination_arn = aws_cloudwatch_log_group.cloud-resume-challenge-log-group.arn

#     format = jsonencode({
#       requestId               = "$context.requestId"
#       sourceIp                = "$context.identity.sourceIp"
#       requestTime             = "$context.requestTime"
#       protocol                = "$context.protocol"
#       httpMethod              = "$context.httpMethod"
#       resourcePath            = "$context.resourcePath"
#       routeKey                = "$context.routeKey"
#       status                  = "$context.status"
#       responseLength          = "$context.responseLength"
#       integrationErrorMessage = "$context.integrationErrorMessage"
#       }
#     )
#   }

#   default_route_settings {
#     throttling_burst_limit  = 5000
#     throttling_rate_limit  = 10000
#   }
# }

# resource "aws_apigatewayv2_integration" "add-view-count-integration" {
#   api_id = aws_apigatewayv2_api.cloud-resume-challenge-api.id

#   integration_uri    = aws_lambda_function.add-view-count-function.invoke_arn
#   integration_type   = "AWS_PROXY"
#   integration_method = "POST"

#   payload_format_version = "2.0"
# }

# resource "aws_apigatewayv2_route" "add-view-count-route" {
#   api_id = aws_apigatewayv2_api.cloud-resume-challenge-api.id

#   route_key = "PATCH /view-count"
#   target    = "integrations/${aws_apigatewayv2_integration.add-view-count-integration.id}"
# }

# resource "aws_cloudwatch_log_group" "cloud-resume-challenge-log-group" {
#   name = "/aws/api_gw/${aws_apigatewayv2_api.cloud-resume-challenge-api.name}"

#   retention_in_days = 30
# }

# resource "aws_lambda_permission" "cloud-resume-challenge-lambda-permission" {
#   statement_id  = "AllowExecutionFromAPIGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.add-view-count-function.function_name
#   principal     = "apigateway.amazonaws.com"

#   source_arn = "${aws_apigatewayv2_api.cloud-resume-challenge-api.execution_arn}/*/*/view-count"
# }

# resource "aws_sns_topic" "cloud_resume_challenge_cloudwatch_alarms_topic" {
#   name = "cloud_resume_challenge_cloudwatch_alarms_topic"
# }

# resource "aws_sns_topic_subscription" "ucloud_resume_challenge_cloudwatch_alarms_target" {
#   topic_arn = aws_sns_topic.cloud_resume_challenge_cloudwatch_alarms_topic.arn
#   protocol  = "email"
#   endpoint  = "jlaw.cordova@gmail.com"
# }

# resource "aws_cloudwatch_metric_alarm" "api_gateway_latency_alarm" {
#   alarm_name                = "api_gateway_latency_alarm"
#   comparison_operator       = "GreaterThanThreshold"
#   evaluation_periods        = 1
#   metric_name               = "Latency"
#   namespace                 = "AWS/ApiGateway"
#   period                    = 300
#   statistic                 = "Average"
#   threshold                 = 3000
#   alarm_description         = "Project: Cloud Resume Challenge\nEnvironment: Production\n\nThe HTTP API Gateway for the Cloud Resume Challenge has had a sudden increase in latency for the past 5 minutes. You may need to check the HTTP API Gateway and determine the cause of the error."
#   insufficient_data_actions = []

#   dimensions = {
#     ApiName = aws_apigatewayv2_api.cloud-resume-challenge-api.name
#     Stage = aws_apigatewayv2_stage.default-stage.name
#   }

#   alarm_actions = [aws_sns_topic.cloud_resume_challenge_cloudwatch_alarms_topic.arn]
# }

# resource "aws_cloudwatch_metric_alarm" "api_gateway_call_count_alarm" {
#   alarm_name                = "api_gateway_call_count_alarm"
#   comparison_operator       = "GreaterThanThreshold"
#   evaluation_periods        = 1
#   metric_name               = "Count"
#   namespace                 = "AWS/ApiGateway"
#   period                    = 300
#   statistic                 = "Sum"
#   threshold                 = 100
#   alarm_description         = "Project: Cloud Resume Challenge\nEnvironment: Production\n\nThe HTTP API Gateway for the Cloud Resume Challenge has encountered a sudden amount of API calls for the last 5 minutes. You may need to check the API calls made and determine if this is a DDoS attack or just a sudden influx of users."
#   insufficient_data_actions = []

#   dimensions = {
#     ApiName = aws_apigatewayv2_api.cloud-resume-challenge-api.name
#     Stage = aws_apigatewayv2_stage.default-stage.name
#   }

#   alarm_actions = [aws_sns_topic.cloud_resume_challenge_cloudwatch_alarms_topic.arn]
# }

# resource "aws_cloudwatch_metric_alarm" "lambda_error_count_alarm" {
#   alarm_name                = "lambda_error_count_alarm"
#   comparison_operator       = "GreaterThanThreshold"
#   evaluation_periods        = 1
#   metric_name               = "Errors"
#   namespace                 = "AWS/Lambda"
#   period                    = 3600
#   statistic                 = "Sum"
#   threshold                 = 5
#   alarm_description         = "Project: Cloud Resume Challenge\nEnvironment: Production\n\nThe Lambda function addViewCount has encountered a sudden amount of errors for the past hour. You may need to check the lambda function and determine the cause of the error."
#   insufficient_data_actions = []

#   dimensions = {
#     FunctionName = aws_lambda_function.add-view-count-function.function_name
#   }

#   alarm_actions = [aws_sns_topic.cloud_resume_challenge_cloudwatch_alarms_topic.arn]
# }

# module "web_build_files" {
#   source = "hashicorp/dir/template"

#   base_dir = "${path.module}/../web/build"
# }

# resource "aws_s3_bucket" "web_bucket" {
#   bucket = "jlawcordova-cloudresumechallenge-development-web"
# }

# resource "aws_s3_bucket_website_configuration" "web_website_configuration" {
#   bucket = aws_s3_bucket.web_bucket.id

#   index_document {
#     suffix = "index.html"
#   }
# }

# resource "aws_s3_bucket_public_access_block" "web_public_access_block" {
#   bucket = aws_s3_bucket.web_bucket.id

#   block_public_acls       = false
#   block_public_policy     = false
#   ignore_public_acls      = false
#   restrict_public_buckets = false
# }

# resource "aws_s3_bucket_policy" "web_bucket_policy" {
#   bucket = aws_s3_bucket.web_bucket.id

#   policy = templatefile("${path.module}/templates/s3-public-policy.json", { bucket = aws_s3_bucket.web_bucket.id })
# }

# resource "aws_s3_object" "web-object" {
#   bucket = aws_s3_bucket.web_bucket.id

#   for_each = module.web_build_files.files

#   key          = each.key

#   # The template_files module guarantees that only one of these two attributes
#   # will be set for each file, depending on whether it is an in-memory template
#   # rendering result or a static file on disk.
#   source  = each.value.source_path
#   content = each.value.content
#   content_type = each.value.content_type

#   # Unless the bucket has encryption enabled, the ETag of each object is an
#   # MD5 hash of that object.
#   etag = each.value.digests.md5
# }

# resource "aws_cloudfront_distribution" "s3_distribution" {
#   origin {
#     domain_name              = aws_s3_bucket_website_configuration.web_website_configuration.website_endpoint
#     origin_id                = aws_s3_bucket_website_configuration.web_website_configuration.website_endpoint
#     custom_origin_config {
#       http_port              = "80"
#       https_port             = "443"
#       origin_protocol_policy = "http-only"
#       origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
#     }
#   }

#   enabled             = true
#   price_class = "PriceClass_100"

#   default_cache_behavior {
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD", "OPTIONS"]
#     target_origin_id = aws_s3_bucket_website_configuration.web_website_configuration.website_endpoint

#     forwarded_values {
#       query_string = false

#       cookies {
#         forward = "none"
#       }
#     }

#     viewer_protocol_policy = "redirect-to-https"
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }
# }