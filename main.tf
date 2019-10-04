# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = var.apiName
}

resource "aws_api_gateway_resource" "resource" {
  path_part   = "lucky"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "demo" {
  depends_on = ["aws_api_gateway_integration.integration"]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "demo"
}

# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.awsRegion}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}

locals {
  lambda_zip_filename = "lambda.zip"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/function.py"
  output_path = local.lambda_zip_filename
}

resource "aws_lambda_function" "lambda" {
  filename         = local.lambda_zip_filename
  function_name    = var.lambdaName
  role             = aws_iam_role.role.arn
  handler          = "function.lambda_handler"
  runtime          = "python3.7"
  source_code_hash = data.archive_file.lambda.output_base64sha256
}

# IAM
resource "aws_iam_role" "role" {
  name = "myrole"

  assume_role_policy = <<POLICY
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
POLICY

}

