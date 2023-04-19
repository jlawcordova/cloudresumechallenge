
output "add_view_count_function_name" {
  description = "Name of the addViewCount Lambda function."

  value = aws_lambda_function.add-view-count-function.function_name
}