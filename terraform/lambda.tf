resource "aws_iam_role" "random-store-backend-lambda" {
    name = "random-store-backend-lambda"
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
            "arn:aws:dynamodb:us-east-1:950094899988:table/RandomStore"
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
            "arn:aws:logs:us-east-1:950094899988:log-group:/aws/lambda/random_store_backend:*"
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
  function_name    = "devRandomStoreBackend"
  filename         = "${path.module}/../output/function.zip"
  source_code_hash = filebase64sha256("${path.module}/../output/function.zip")
  role             = aws_iam_role.random-store-backend-lambda.arn
  runtime          = "go1.x"
  handler          = "Handler"
  tags = {
    Project = "RandomStore"
    Environment = "Dev"
  }
}