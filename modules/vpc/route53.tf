resource "aws_route53_record" "route53_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = data.aws_route53_zone.selected.name
  type    = "A"
  //ttl     = "60"
  //records = [aws_instance.ec2.public_ip] // EC2 instance public ip
  // Ensure the record is created before the EC2 instance
  //depends_on = [aws_instance.ec2]

  alias {
    name                   = aws_lb.load-balancer.dns_name
    zone_id                = aws_lb.load-balancer.zone_id
    evaluate_target_health = true

  }

}
data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = false
}