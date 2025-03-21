# lfglance.dev zone
resource "aws_route53_zone" "zone" {
  name = "yourdomain.tld"
}

resource "aws_route53_record" "apex" {
    zone_id = aws_route53_zone.zone.zone_id
    name    = ""
    type    = "A"

    alias {
      name = aws_cloudfront_distribution.distribution.domain_name
      zone_id = aws_cloudfront_distribution.distribution.hosted_zone_id
      evaluate_target_health = false
    }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "yourdomain.tld"
  validation_method = "DNS"
  provider         = aws.east

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.zone.zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  provider = aws.east
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

