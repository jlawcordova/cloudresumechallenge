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
resource "aws_s3_bucket" "app" {
  bucket = "${var.project}-app"
}

resource "aws_s3_object" "app" {
  bucket = aws_s3_bucket.app.id

  key    = "app.zip"
  source = data.archive_file.app.output_path

  etag = filemd5(data.archive_file.app.output_path)
}

data "archive_file" "app" {
  type = "zip"

  output_path = "${path.module}/../../../app.zip"
  source_dir  = "${path.module}/../../../app"
  excludes    = [
    "${path.module}/../../../app/README.md",
    "${path.module}/../../../app/.gitignore"
  ]
}

# Setup the Lambda function.
resource "aws_lambda_function" "app" {
  function_name = "${var.project}-app"

  s3_bucket = aws_s3_bucket.app.id
  s3_key    = aws_s3_object.app.key

  runtime = "nodejs18.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.app.output_base64sha256

  role = aws_iam_role.app.arn

  environment {
    variables = {
      VIEW_COUNT_TABLE = aws_dynamodb_table.view_count.name,
      VISITOR_TABLE = aws_dynamodb_table.visitor.name,
    }
  }
}

# Setup the Lambda function roles and policies.
resource "aws_iam_role" "app" {
  name = "${var.project}-app"

  assume_role_policy = templatefile("${path.module}/templates/lambda-role-policy.json", {})
}

resource "aws_iam_role_policy_attachment" "app" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "app_dynamodb" {
  name = "${var.project}-app-dynamodb"
  role = aws_iam_role.app.id

  policy = templatefile(
    "${path.module}/templates/app-dynamodb-policy.json",
    {
      view_count = aws_dynamodb_table.view_count.arn,
      visitor = aws_dynamodb_table.visitor.arn
    }
  )
}