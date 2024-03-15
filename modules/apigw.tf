resource "aws_sns_topic" "rate_limit_alarm_topic" {
  name = "rate-limit-alarm-topic"
}

resource "aws_sns_topic_subscription" "rate_limit_alarm_email" {
  topic_arn = aws_sns_topic.rate_limit_alarm_topic.arn
  protocol  = "email"
  endpoint  = "okcnduka@gmail.com"
}

resource "aws_cloudwatch_metric_alarm" "rate_limit_exceeded_alarm" {
  alarm_name          = "RateLimitExceeded"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "BlockedRequests" #"RateBasedRuleMatchedRequests" #
  namespace           = "AWS/WAFV2"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Alarm when rate limit is exceeded"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.rate_limit_alarm_topic.arn]
  treat_missing_data  = "notBreaching"
  dimensions = {
    Rule = "YourRateBasedRuleID" ##########
    WebACL = aws_wafv2_web_acl.rate_limit.id
    Region = "us-east-1"
    # Ensure these dimension names and values match your setup
  }
}
##########################################################################
## API Gateway
##########################################################################

#API resource
resource "aws_apigatewayv2_api" "http_api" {
  name          = "yahoo-http-api"
  protocol_type = "HTTP"
}

# resource "aws_api_gateway_rest_api" "rest_api" {
#   name = "S3-Bucket-API"
# }

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
  function_name = aws_lambda_function.latest.function_name #or arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

#GET routes
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "$default" #"GET"  #Path to S3 objects
  target    = "integrations/${aws_apigatewayv2_integration.integration.id}"
}

resource "aws_apigatewayv2_deployment" "deploy" {
  api_id      = aws_apigatewayv2_api.http_api.id
  description = "API deployment"

  lifecycle {
    create_before_destroy = true
  }
}

#Default stage
resource "aws_apigatewayv2_stage" "stage" {
  api_id = aws_apigatewayv2_api.http_api.id
  name   = "$default"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_log.arn
    format          = "{\"requestId\":\"$context.requestId\",\"ip\":\"$context.identity.sourceIp\",\"requestTime\":\"$context.requestTime\",\"httpMethod\":\"$context.httpMethod\",\"status\":\"$context.status\",\"protocol\":\"$context.protocol\",\"responseLength\":\"$context.responseLength\"}"
    #format = jsondecode({"requestID" : "$context.requestID", "IP" : "$context.identity.sourceIP", "httpMethod" : "$context.httpMethod", "routeKey" : "$context.routeKey", "status" : "$context.status"})
  }
}

#CloudWatch logging
resource "aws_cloudwatch_log_group" "api_log" {
  name = "/aws/apigateway/fetchs3object"
  retention_in_days = 7
}
##################################
# #API resource
# resource "aws_api_gateway_rest_api" "api" {
#   name = "S3ObjectAPI"
# }

# resource "aws_api_gateway_resource" "resource" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   parent_id   = aws_api_gateway_rest_api.api.root_resource_id
#   path_part   = "fetch"
# }

# resource "aws_api_gateway_method" "method" {
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   resource_id   = aws_api_gateway_resource.resource.id
#   http_method   = "GET"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "integration" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   resource_id = aws_api_gateway_resource.resource.id
#   http_method = aws_api_gateway_method.method.http_method

#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = aws_lambda_function.latest.invoke_arn
# }

# resource "aws_api_gateway_deployment" "deployment" {
#   depends_on = [
#     aws_api_gateway_integration.integration,
#   ]
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# # API Gateway Stage resource
# resource "aws_api_gateway_stage" "stage" {
#   deployment_id = aws_api_gateway_deployment.api_deployment.id
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   stage_name    = "prod"

#   # Example of enabling logging and setting the log level
#   access_log_settings {
#     destination_arn = aws_cloudwatch_log_group.api_log.arn
#     format          = "{\"requestId\":\"$context.requestId\",\"ip\":\"$context.identity.sourceIp\",\"requestTime\":\"$context.requestTime\",\"httpMethod\":\"$context.httpMethod\",\"status\":\"$context.status\",\"protocol\":\"$context.protocol\",\"responseLength\":\"$context.responseLength\"}"
#   }

#   # Adjust these values as needed for your specific requirements
#   xray_tracing_enabled = true

#   # Example of setting stage variables (optional)
#   variables = {
#     "environment" = "production"
#   }
# }

# #CloudWatch logging
# resource "aws_cloudwatch_log_group" "api_log" {
#   name = "/aws/apigateway/S3ObjectAPI"
#   retention_in_days = 7
# }

# #Lambda permissions
# resource "aws_lambda_permission" "invoke" {
#   statement_id  = "AllowExecutionFromAPIGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.latest.function_name  #or ARN
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
# }