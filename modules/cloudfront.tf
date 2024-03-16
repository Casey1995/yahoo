
resource "aws_cloudfront_distribution" "api_distribution" {
  origin {
    domain_name              = "${aws_apigatewayv2_api.http_api.id}.execute-api.${var.region}.amazonaws.com"
    origin_id                = aws_apigatewayv2_api.http_api.api_endpoint
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = ""

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_apigatewayv2_api.http_api.api_endpoint
    origin_request_policy_id = aws_cloudfront_origin_request_policy.api.id
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"  #Managed-CachingDisabled policy ID https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600 
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
  web_acl_id = aws_wafv2_web_acl.rate_limit.arn

  depends_on = [ aws_apigatewayv2_api.http_api ]
  tags = merge(var.map_tags, {"Name" = "CloudFront"})
}

resource "aws_cloudfront_origin_request_policy" "api" {
  name    = "Origin-request-policy"
  comment = "Origin request policy to include custom header"
  cookies_config {
    cookie_behavior = "none"
  }
  headers_config {
    header_behavior = "whitelist"
    headers {
        items = ["${data.aws_secretsmanager_secret_version.current.secret_string}"]
    }
  }
  query_strings_config {
    query_string_behavior = "none"
  }
}
