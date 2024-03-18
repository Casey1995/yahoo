resource "aws_dynamodb_table" "rate_limit" {
  name           = "RateLimitTable"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "ipAddress"
  range_key      = "currenttime"
  attribute {
    name = "ipAddress"
    type = "S"
  }
  attribute {
    name = "currenttime"
    type = "N"
  }
  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
  tags = merge(var.map_tags, {"Name" = "RateLimitTable"})
}

resource "aws_cloudwatch_metric_alarm" "rate_limit_exceed_alarm" {
  alarm_name          = "rateLimitExceededAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "RateLimitExceeded"
  namespace           = "MyAPIGatewayUsage"
  period              = 300
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Alarm when a specific IP exceeds the rate limit"
  actions_enabled     = true
  dimensions = {
    FunctionName = aws_lambda_function.auth.function_name
  }
  alarm_actions = [aws_sns_topic.rate_limit_alarm_topic.arn]
  tags = merge(var.map_tags, {"Name" = "RateLimitExceededAlarm"})
}