output "lambda_arn" {
  description = "The ARN of the lambda"
  value       = aws_lambda_function.lambda.arn
}

output "lambda_invoke_arn" {
  description = "The ARN to invoke the lambda"
  value       = aws_lambda_function.lambda.invoke_arn
}

output "lambda_role_arn" {
  description = "The ARN of your lambda role"
  value       = aws_iam_role.lambda_role.arn
}

output "lambda_role_id" {
  description = "The ARN of your lambda role"
  value       = aws_iam_role.lambda_role.id
}

output "lambda_role_name" {
  description = "The ARN of your lambda role"
  value       = aws_iam_role.lambda_role.name
}

output "lambda_name" {
  description = "The name of the lambda"
  value       = aws_lambda_function.lambda.function_name 
}

output "lambda_invoke_uri_arn" {
  value = aws_lambda_function.lambda.invoke_arn
}

output "module_complete" {
  value = "${var.module_dependency}${var.module_dependency == "" ? "" : "->"}(${null_resource.module_is_complete.id})"
}