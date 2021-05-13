resource "null_resource" "module_dependency" {
  triggers = {
    dependency = var.module_dependency
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.lambda_code_path
  output_path = "${var.lambda_function_name}.zip"

}

data "archive_file" "dependencies_zip" {
  count = length(var.lambda_dependencies_path) > 0 ? 1 : 0

  type        = "zip"
  source_dir  = var.lambda_dependencies_path
  output_path = "${var.lambda_function_name}_dependencies.zip"
}

resource "aws_lambda_layer_version" "lambda_dependencies_layer" {
  depends_on = [null_resource.module_dependency]
  count      = length(var.lambda_dependencies_path) > 0 ? 1 : 0

  filename            = "${var.lambda_function_name}_dependencies.zip"
  layer_name          = "${var.lambda_function_name}-layer"
  compatible_runtimes = [var.lambda_runtime]
  source_code_hash    = data.archive_file.dependencies_zip[0].output_base64sha256
}


resource "aws_lambda_function" "lambda" {
  depends_on = [null_resource.module_dependency]

  filename         = "${var.lambda_function_name}.zip"
  source_code_hash = filebase64sha256("${var.lambda_function_name}.zip") #data.archive_file.lambda_zip.output_base64sha256
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_role.arn
  description      = var.lambda_description
  handler          = var.lambda_handler
  runtime          = var.lambda_runtime
  tags             = var.tags
  layers           = length(var.lambda_dependencies_path) > 0 ? var.lambda_layers == null ? [aws_lambda_layer_version.lambda_dependencies_layer[0].arn] : concat(var.lambda_layers, [aws_lambda_layer_version.lambda_dependencies_layer[0].arn]) : var.lambda_layers
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size


  dynamic "environment" {
    for_each = var.environment == null ? [] : [var.environment]
    content {
      variables = environment.value.variables
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_cwgroup" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = var.cw_logs_retention_days
}


resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_function_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_iam_role_policy_attachment" {
  count = length(var.lambda_policy_arn)

  role       = aws_iam_role.lambda_role.name
  policy_arn = var.lambda_policy_arn[count.index] #element(var.lambda_policy_arn, count.index)
}

resource "null_resource" "module_is_complete" {
  depends_on = [aws_lambda_function.lambda, aws_cloudwatch_log_group.lambda_cwgroup, aws_iam_role.lambda_role, aws_iam_role_policy_attachment.lambda_iam_role_policy_attachment]

  provisioner "local-exec" {
    command = "echo Module complete"
  }
}
