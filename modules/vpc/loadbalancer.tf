
resource "aws_lb" "load-balancer" {

  name                       = "csye6225-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.load_balancer_sg.id]
  subnets                    = [for subnet in aws_subnet.public : subnet.id]
  enable_deletion_protection = false

  tags = {

    Application = "WebApp"

  }

}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.load-balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application-target-group.arn
  }
}

resource "aws_lb_target_group" "application-target-group" {
  name        = "application-target-group"
  port        = 3030
  protocol    = "HTTP"
  target_type = "instance"

  health_check {
    protocol = "HTTP"
    port     = 3030
    path     = "/"
    interval = 10
    timeout  = 5
    matcher  = "200-399"

  }
  vpc_id = aws_vpc.vpc.id
}


resource "aws_security_group" "load_balancer_sg" {
  name_prefix = "load-balancer-sg-"
  description = "Security group for load balancer to access web application"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Load Balancer Security Group"
  }
}
