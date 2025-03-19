# Create CloudFront distribution
resource "aws_cloudfront_distribution" "distribution" {
  provider = aws.east
  origin {
    domain_name = "your-bun-function.up.railway.app"
    origin_id   = "railway-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true

  # Aliases for the custom domain
  aliases = ["yourdomain.tld"]

  # Viewer certificate using ACM
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # Default cache behavior
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "railway-origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    # Add Lambda@Edge association
    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_function.edge_function.qualified_arn
      include_body = false
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 3600
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  depends_on = [aws_acm_certificate.cert]
}
