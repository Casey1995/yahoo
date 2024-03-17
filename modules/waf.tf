# resource "aws_wafv2_web_acl" "rate_limit" {
#   name        = "RateLimitRule"
#   scope       = "CLOUDFRONT"
#   description = "Web ACL to limit requests per IP"

#   default_action {
#     allow {}
#   }

#   rule {
#     name     = "RateLimitRule"
#     priority = 1

#     action {
#       block {
#         custom_response {
#           response_code = 429
#         }
#       }
#     }

#     statement {
#       rate_based_statement {
#         limit              = 210
#         aggregate_key_type = "IP"
#         evaluation_window_sec = 600
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "BlockedRequests"
#       sampled_requests_enabled   = true
#     }
#   }

#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     metric_name                = "BlockedRequests"
#     sampled_requests_enabled   = true
#   }
#   tags = merge(var.map_tags, {"Name" = "RateLimitACL"})
# }

# resource "aws_cloudwatch_log_group" "waf" {
#   name = "aws-waf-logs-rate-limit"
#   tags = merge(var.map_tags, {"Name" = "WAFLogs"})
# }

# resource "aws_wafv2_web_acl_logging_configuration" "example" {
#   log_destination_configs = [aws_cloudwatch_log_group.waf.arn]
#   resource_arn            = aws_wafv2_web_acl.rate_limit.arn
# }

# resource "aws_cloudwatch_log_resource_policy" "waf" {
#   policy_document = data.aws_iam_policy_document.waf.json
#   policy_name     = "webacl-policy-rate-limit"
# }

# data "aws_iam_policy_document" "waf" {
#   version = "2012-10-17"
#   statement {
#     effect = "Allow"
#     principals {
#       identifiers = ["delivery.logs.amazonaws.com"]
#       type        = "Service"
#     }
#     actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
#     resources = ["${aws_cloudwatch_log_group.waf.arn}:*"]
#     condition {
#       test     = "ArnLike"
#       values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
#       variable = "aws:SourceArn"
#     }
#     condition {
#       test     = "StringEquals"
#       values   = [tostring(data.aws_caller_identity.current.account_id)]
#       variable = "aws:SourceAccount"
#     }
#   }
# }