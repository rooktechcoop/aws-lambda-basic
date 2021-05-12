variable "lambda_function_name" {
  description = "A name for the lambda"
}

variable "lambda_description" {
  default     = "Some description for your lambda"
  description = "Some description for your lambda"
}

variable "lambda_code_path" {
  description = "The path to your lamda code"
}

variable "lambda_dependencies_path" {
  description = "The path to your dependencies path"
  default     = ""
  type        = string
}

variable "lambda_handler" {
  description = "Lambda handler, e.g: lambda_function.lambda_handler"
}

variable "lambda_runtime" {
  description = "Runtime of the lambda, e.g: python3.8"
}

variable "lambda_timeout" {
  default = 3
}

variable "lambda_memory_size" {
  default = 128
}

variable "lambda_policy_arn" {
  description = "The ARNs of the policies to attach to the lambda role"
  type        = list(string)
}

variable "environment" {
  type = object({
    variables = map(string)
  })
  default = null
}

variable "tags" {
  type    = map(string)
  default = null
}

variable "lambda_layers" {
  description = "The ARNs of lambda layers"
  type        = list(string)
  default     = null
}

variable "module_dependency" {
  default = ""
}

variable "cw_logs_retention_days" {
  description = "Number of retention days of the lambda log group in Cloudwatch"
  default     = 14
}
