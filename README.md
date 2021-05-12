# aws-lambda-apigw
An AWS lambda module that

## Usage

```hcl
module "compute_lambda_test_s3" {
    providers = {
        aws.dst       = aws.prod
    }
    source  = "../modules/lambda-basic"

    lambda_function_name            = "hello-lambda"
    lambda_code_path                = "../../lambdas/hello"
    lambda_handler                  = "lambda_function.lambda_handler"
    lambda_runtime                  = "python3.8"
    lambda_description              = "Example lambda"
    lambda_policy_arn               = [aws_iam_policy.compute_policy_logs.arn]
    lambda_timeout                  = 30
    lambda_memory_size              = 256
    tags = {
        State       = "terraform managed"
        Environment = "prod"
    }
    environment = {
        variables = {
            var1        = "value1"
        }
    }
}
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:------:|:-----:|
| lambda\_function\_name| A name for the lambda | string | `-` | yes |
| lambda\_description| Some description for your lambda | string | `"Some description for your lambda"` | no |
| lambda\_lambda\_code\_path | The path to your lamda code and packages | string | `-` | yes |
| lambda\_dependencies\_code\_path | The path to your dependencies path | string | "" | no |
| lambda\_handler| Lambda handler, e.g: `lambda_function.lambda_handler` | string | `-` | yes |
| lambda\_runtime| Lambda runtime, e.g: `python3.8` | string | `-` | yes |
| lambda\_policy\_arn| A list of policie's arn to attach to your lambda role | list(string) | `-` | yes |
| lambda\_layers| Dictionary of lambda layers arns | list | `null` | no |
| cw\_logs\_retention\_days | Number of retention days of the lambda log group in Cloudwatch | number | 14 | no |
| environment | `aws_lambda_function` environment block, that allows to set variables | object | `null` | no |
| tags | Tags to attach to your function | map | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| lambda\_arn | ARN of the lambda |
| lambda\_role\_arn | ARN of the lambda role|
| lambda\_role\_id | ID of the lambda role|
| lambda\_role\_name | Name of the lambda role|
| lambda\_name | Name of the lambda|
| lambda\_invoke\_uri\_arn | ARN of the lambda invoke uri ARN|
