# Setup the DynamoDB tables.
resource "aws_dynamodb_table" "view_count" {
  name           = "${var.project}-view-count"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "Id"

  attribute {
    name = "Id"
    type = "S"
  }

  tags = {
    Project = var.project
    Environment     = var.environment
  }
}

resource "aws_dynamodb_table" "visitor" {
  name           = "${var.project}-visitor"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "IP"

  attribute {
    name = "IP"
    type = "S"
  }

  tags = {
    Project = var.project
    Environment     = var.environment
  }
}

# Setup the bucket for the Lambda function code.
data "archive_file" "app" {
  type = "zip"

  output_path = "${path.module}/../../../app.zip"
  source_dir  = "${path.module}/../../../app"
  excludes    = [
    "${path.module}/../../../app/README.md",
    "${path.module}/../../../app/.gitignore"
  ]
}

resource "aws_s3_bucket" "app" {
  bucket = "${var.project}-app"
}

resource "aws_s3_object" "app" {
  bucket = aws_s3_bucket.app.id

  key    = "app.zip"
  source = data.archive_file.app.output_path

  etag = filemd5(data.archive_file.app.output_path)
}