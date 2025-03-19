output "Name-Servers" {
  value = "${aws_route53_zone.zone.name_servers}"
}