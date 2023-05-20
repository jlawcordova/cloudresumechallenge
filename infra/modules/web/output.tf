output "web_url" {
  description = "The domain URL for Cloud Resume Challenge CloudFront distribution."
  value       = aws_cloudfront_distribution.web.domain_name
}
