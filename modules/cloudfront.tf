
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

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

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

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
  web_acl_id = aws_wafv2_web_acl.rate_limit.arn

  depends_on = [ aws_apigatewayv2_api.http_api ]
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for API Gateway"
}
