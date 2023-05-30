resource "aws_apigatewayv2_api" "devRandomStore" {
    name = "devRandomStore"
    tags = {
        Project = "RandomStore"
        Environment = "Dev"
    }
    cors_configuration {
      allow_headers = ["*"]
      allow_methods = ["*"]
      allow_origins = local.cors_orgins
    }
    protocol_type = "HTTP"
}

resource "aws_apigatewayv2_route" "getStoreResource" {
    api_id = aws_apigatewayv2_api.devRandomStore.id
    route_key = "GET /getStore"
    authorization_type = "NONE"
    target = "integrations/${aws_apigatewayv2_integration.devRandomStoreLambdaIntegration.id}"
}

resource "aws_apigatewayv2_route" "saveStoreResource" {
    api_id = aws_apigatewayv2_api.devRandomStore.id
    route_key = "POST /saveStore"
    authorization_type = "NONE"
    target = "integrations/${aws_apigatewayv2_integration.devRandomStoreLambdaIntegration.id}"
}

resource "aws_apigatewayv2_integration" "devRandomStoreLambdaIntegration" {
    api_id = aws_apigatewayv2_api.devRandomStore.id
    integration_type = "AWS_PROXY"
    connection_type = "INTERNET"
    description = "The getStore Integration to retrieve existing shops"
    integration_method = "POST"
    passthrough_behavior      = "WHEN_NO_MATCH"
    integration_uri = aws_lambda_function.devRandomStoreBackend.invoke_arn
    payload_format_version = "2.0"
}

resource "aws_apigatewayv2_domain_name" "devRandomStoreDomainName" {
    domain_name = "api.dev.randomstore.scselvy.com"
    domain_name_configuration {
      certificate_arn = local.dev_certificate_arn
      endpoint_type = "REGIONAL"
      security_policy = "TLS_1_2"
    }   
}

resource "aws_apigatewayv2_api_mapping" "devRandomStoreAPIMapping" {
    api_id = aws_apigatewayv2_api.devRandomStore.id
    domain_name = aws_apigatewayv2_domain_name.devRandomStoreDomainName.id
    stage = aws_apigatewayv2_stage.devRSDefaultStage.id
}

resource "aws_apigatewayv2_stage" "devRSDefaultStage" {
    api_id = aws_apigatewayv2_api.devRandomStore.id
    name = "$default"
    auto_deploy = true
}

resource "aws_route53_record" "devRandomAPIDNSRecord" {
    name = aws_apigatewayv2_domain_name.devRandomStoreDomainName.domain_name
    type = "A"
    zone_id = "Z07600102Y2PN0W4J333F"

    alias {
        evaluate_target_health = false
        name = aws_apigatewayv2_domain_name.devRandomStoreDomainName.domain_name_configuration[0].target_domain_name
        zone_id = aws_apigatewayv2_domain_name.devRandomStoreDomainName.domain_name_configuration[0].hosted_zone_id
    }
}