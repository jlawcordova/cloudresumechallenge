output "url" {
  description = "The URL for Cloud Resume Challenge API Gateway."

  value = aws_apigatewayv2_stage.default.invoke_url
}