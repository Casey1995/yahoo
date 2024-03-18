#SNS Topic for Notification
resource "aws_sns_topic" "rate_limit_alarm_topic" {
  name = "rate-limit-alarm-topic"
}

resource "aws_sns_topic_subscription" "rate_limit_alarm_email" {
  topic_arn = aws_sns_topic.rate_limit_alarm_topic.arn
  protocol  = "email"
  endpoint  = "okcnduka@gmail.com" #var.sns_endpoint #
}

##########################################################################
## API Gateway
##########################################################################

#API resource
resource "aws_apigatewayv2_api" "http_api" {
  name          = "CloudFrontOriginHTTPAPI"
  protocol_type = "HTTP"
  tags = merge(var.map_tags, {"Name" = "APIGateway"})
}

#Lambda integration
resource "aws_apigatewayv2_integration" "integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.latest.invoke_arn
  payload_format_version = "2.0"
}

#Lambda permissions
resource "aws_lambda_permission" "invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.latest.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

#Lambda permissions
resource "aws_lambda_permission" "auth" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

#GET routes
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.integration.id}"
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.auth.id
}

resource "aws_apigatewayv2_deployment" "deploy" {
  api_id      = aws_apigatewayv2_api.http_api.id
  description = "API deployment"

#   lifecycle {
#     create_before_destroy = true
#   }
}

#Default stage
resource "aws_apigatewayv2_stage" "stage" {
  api_id = aws_apigatewayv2_api.http_api.id
  name   = "$default"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_log.arn
    format          = "{\"requestId\":\"$context.requestId\",\"ip\":\"$context.identity.sourceIp\",\"requestTime\":\"$context.requestTime\",\"httpMethod\":\"$context.httpMethod\",\"status\":\"$context.status\",\"protocol\":\"$context.protocol\",\"responseLength\":\"$context.responseLength\"}"
  }
  # default_route_settings {
  #   throttling_burst_limit = 1000
  #   throttling_rate_limit  = 1260
  # }
}

#CloudWatch logging
resource "aws_cloudwatch_log_group" "api_log" {
  name = "/aws/apigateway/fetchs3object"
  retention_in_days = 7
}

resource "aws_apigatewayv2_authorizer" "auth" {
  api_id                            = aws_apigatewayv2_api.http_api.id
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = aws_lambda_function.auth.invoke_arn
  identity_sources                  = ["$context.identity.sourceIp"]
  name                              = "lambda-authorizer"
  authorizer_payload_format_version = "2.0"
  authorizer_result_ttl_in_seconds  = 0
}
