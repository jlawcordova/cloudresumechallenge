terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.4.0"
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

data "archive_file" "add-view-count-lambda" {
  type = "zip"

  output_path = "${path.module}/../app.zip"
  excludes    = [
    "${path.module}/../app/README.md",
    "${path.module}/../app/.gitignore"
  ]

  source_dir  = "${path.module}/../app"
}

resource "aws_s3_object" "add-view-count-lambda" {
  bucket = aws_s3_bucket.app-bucket.id

  key    = "app.zip"
  source = data.archive_file.add-view-count-lambda.output_path

  etag = filemd5(data.archive_file.add-view-count-lambda.output_path)
}
