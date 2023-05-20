# Prepare the build for S3 upload.
# This is need to specify the content-type for each object.
# See https://stackoverflow.com/a/46921393/6811810
module "web_build" {
  source   = "hashicorp/dir/template"
  base_dir = "${path.module}/../../../web/build"
}

# Setup the S3 bucket. Set it to static web hosting.
resource "aws_s3_bucket" "web" {
  bucket = "${var.project}-web"

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_s3_bucket_website_configuration" "web" {
  bucket = aws_s3_bucket.web.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "web" {
  bucket = aws_s3_bucket.web.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "web" {
  bucket = aws_s3_bucket.web.id

  policy = templatefile("${path.module}/templates/s3-public-policy.json", { bucket = aws_s3_bucket.web.id })
}

resource "aws_s3_object" "web" {
  bucket = aws_s3_bucket.web.id

  for_each = module.web_build.files

  key = each.key

  # The template_files module guarantees that only one of these two attributes
  # will be set for each file, depending on whether it is an in-memory template
  # rendering result or a static file on disk.
  source       = each.value.source_path
  content      = each.value.content
  content_type = each.value.content_type

  # Unless the bucket has encryption enabled, the ETag of each object is an
  # MD5 hash of that object.
  etag = each.value.digests.md5
}
