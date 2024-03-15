resource "aws_wafv2_web_acl" "rate_limit" {
  name        = "Rate-limit-web-acl"
  scope       = "REGIONAL"
  description = "Web ACL to limit requests per IP"

  default_action {
    allow {}
  }

  rule {
    name     = "RateLimitRule"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 210  #(Required) Limit on requests per 5 mins period for a single originating IP
        aggregate_key_type = "IP"
        evaluation_window_sec = 600
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockedRequests"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "RateBasedRuleMatchedRequests"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "rate_limmit" {
  resource_arn = aws_apigatewayv2_stage.default_stage.arn
  web_acl_arn  = aws_wafv2_web_acl.rate_limit.arn
}