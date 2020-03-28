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
  layers           = var.lambda_layers
  timeout          = var.lambda_timeout


  dynamic "environment" {
    for_each = var.environment == null ? [] : [var.environment]
    content {
      variables = environment.value.variables
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_cwgroup" {

  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
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
  
  count      = length(var.lambda_policy_arn)
  role       = aws_iam_role.lambda_role.name
  policy_arn = var.lambda_policy_arn[count.index] #element(var.lambda_policy_arn, count.index)
}

resource "null_resource" "module_is_complete" {
  depends_on = [aws_lambda_function.lambda, aws_cloudwatch_log_group.lambda_cwgroup, aws_iam_role.lambda_role, aws_iam_role_policy_attachment.lambda_iam_role_policy_attachment]

  provisioner "local-exec" {
    command = "echo Module complete"
  }
}