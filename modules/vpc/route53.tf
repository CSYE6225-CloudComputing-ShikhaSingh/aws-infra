resource "aws_route53_record" "route53_record" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = var.domain_name //domain name
  type    = "A"
  ttl     = "60"
  records = [aws_instance.ec2.public_ip] // EC2 instance public ip
  // Ensure the record is created before the EC2 instance
  depends_on = [aws_instance.ec2]
}
data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = false
}