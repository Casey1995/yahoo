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
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Request rate limit is exceeded on an IP address"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.rate_limit_alarm_topic.arn]
  treat_missing_data  = "notBreaching"
  dimensions = {
    Rule = aws_wafv2_web_acl.rate_limit.name ##########
    WebACL = aws_wafv2_web_acl.rate_limit.name
    # Region = var.region #"us-east-1"
    # Ensure these dimension names and values match your setup
  }
#   dimensions = {
#     MetricName = aws_wafv2_web_acl.rate_limit.rule[0].visibility_config[0].metric_name
#     WebACL     = aws_wafv2_web_acl.rate_limit.name
#   }
}
##########################################################################
## API Gateway
##########################################################################

#API resource
resource "aws_apigatewayv2_api" "http_api" {
  name          = "yahoo-http-api"
  protocol_type = "HTTP"
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
#   default_route_settings {
#     throttling_burst_limit = 210
#     throttling_rate_limit  = 1260 # 210 requests per minute (or per 10 minutes, adjust as needed)
#   }
}

#CloudWatch logging
resource "aws_cloudwatch_log_group" "api_log" {
  name = "/aws/apigateway/fetchs3object"
  retention_in_days = 7
}
