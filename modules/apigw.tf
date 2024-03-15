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

resource "aws_apigatewayv2_api" "http_api" {
  name          = "yahoo-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.latest.invoke_arn
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /recent-object"
  target    = "integrations/${aws_apigatewayv2_integration.integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id = aws_apigatewayv2_api.http_api.id
  name   = "default"
  auto_deploy = true
}

resource "aws_lambda_permission" "allow_api_gateway_to_call_recent_object" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.latest.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}