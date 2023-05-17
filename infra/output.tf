output "app_url" {
  description = "The URL for Cloud Resume Challenge API Gateway."

  value = module.app.url
}

# output "add_view_count_function_name" {
#   description = "Name of the addViewCount Lambda function."

#   value = aws_lambda_function.add-view-count-function.function_name
# }

# output "cloud_resume_challenge_base_url" {
#   description = "Base URL for Cloud Resume Challenge API Gateway."

#   value = aws_apigatewayv2_stage.default-stage.invoke_url
# }

# output "website_endpoint" {
#   value = aws_s3_bucket_website_configuration.web_website_configuration.website_endpoint
# }
