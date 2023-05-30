resource "aws_api_gateway_rest_api" "example" {
    name = "devRandomStore"
    tags = {
        Project = "RandomStore"
        Environment = "Dev"
    }
    endpoint_configuration {
        types = ["REGIONAL"]
    }
}

resource "aws_api_gateway_resource" "getStoreResource" {
    rest_api_id = aws_dynamodb_table.devRandomStore.id
    parent_id = aws_dynamodb_table.devRandomStore.root_resource_id
    path_part = "getStore"
}

resource "aws_api_gateway_resource" "saveStoreResource" {
    rest_api_id = aws_dynamodb_table.devRandomStore.id
    parent_id = aws_dynamodb_table.devRandomStore.root_resource_id
    path_part = "saveStore"
}

resource "aws_api_gateway_method" "getStoreMethod" {
    rest_api_id = aws_api_gateway_rest_api.devRandomStore.id
    resource_id = aws.aws_api_gateway_resource.getStoreResource.id
    http_method = "GET"
    authorization = "None"
}

resource "aws_api_gateway_method" "saveStoreMethod" {
    rest_api_id = aws_api_gateway_rest_api.devRandomStore.id
    resource_id = aws_api_gateway_resource.saveStoreResource.id
    http_method = "POST"
    authorization = "None"
}

resource "aws_api_gateway_integration" "getStoreIntegration" {
    rest_api_id = aws_api_gateway_rest_api.devRandomStore.id
    resource_id = aws_api_gateway_resource.getStoreResource.id
    http_method = aws_api_gateway_method.getStoreMethod.http_method
    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = aws_lambda_function.devRandomStoreBackend.invoke_arn
}

resource "aws_api_gateway_integration" "saveStoreIntegration" {
    rest_api_id = aws_api_gateway_rest_api.devRandomStore.id
    resource_id = aws_api_gateway_resource.saveStoreResource.id
    http_method = aws_api_gateway_method.saveStoreMethod.http_method
    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = aws_lambda_function.devRandomStoreBackend.invoke_arn
}

