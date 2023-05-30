resource "aws_cloudwatch_log_group" "devRSLogGroup" {
  name              = "/aws/lambda/${local.lambda_name}"
  retention_in_days = 3
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_iam_role" "devRandomStoreBackendLambda" {
    name = "devRandomStoreBackendLambda"
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
    inline_policy {
      name = "randomstore_backend_access"
      policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
        "Action": [
            "dynamodb:GetItem",
            "dynamodb:DescribeTable",   
            "dynamodb:Scan",
            "dynamodb:UpdateItem",
            "dynamodb:DeleteItem",
            "dynamodb:Query",
            "dynamodb:PutItem",
            "dynamodb:UpdateTimeToLive"
        ],
        "Resource": [
            "${aws_dynamodb_table.devRandomStore.arn}"
        ],
        "Effect": "Allow"
    },
    {
        "Action": [
            "logs:CreateLogGroup"
        ],
        "Resource": [
            "arn:aws:logs:us-east-1:950094899988:*"
        ],
        "Effect": "Allow"
    },
    {
        "Action": [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": [
            "arn:aws:logs:us-east-1:950094899988:log-group:/aws/lambda/${local.lambda_name}:*"
        ],
        "Effect": "Allow"
    }
]
}
EOF
    }
    tags = {
        Project = "RandomStore"
    }
}

resource "aws_lambda_function" "devRandomStoreBackend" {
  function_name    = local.lambda_name
  filename         = "${path.module}/../output/function.zip"
  source_code_hash = filebase64sha256("${path.module}/../output/function.zip")
  role             = aws_iam_role.devRandomStoreBackendLambda.arn
  depends_on = [aws_cloudwatch_log_group.devRSLogGroup]
  runtime          = "go1.x"
  handler          = "main"
  tags = {
    Project = "RandomStore"
    Environment = "Dev"
  }
  environment {
    variables = {
        RSTableName = aws_dynamodb_table.devRandomStore.id
        RSSiteName = "https://dev.randomstore.scselvy.com"
    }
  }
}

resource "aws_lambda_permission" "devRSAPIGatewayPermsSave" {
    statement_id = "devRSAPIGatewayPermsSave"
    action = "lambda:InvokeFunction"
    function_name = local.lambda_name
    principal = "apigateway.amazonaws.com"
    source_arn = "${aws_apigatewayv2_api.devRandomStore.execution_arn}/*/*/saveStore"
}

resource "aws_lambda_permission" "devRSAPIGatewayPermsGet" {
    statement_id = "devRSAPIGatewayPermsGet"
    action = "lambda:InvokeFunction"
    function_name = local.lambda_name
    principal = "apigateway.amazonaws.com"
    source_arn = "${aws_apigatewayv2_api.devRandomStore.execution_arn}/*/*/getStore"
}