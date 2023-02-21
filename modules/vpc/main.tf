//Configuration for the vpc

resource "aws_vpc" "vpc" {

      cidr_block           = var.vpc_cidr
      enable_dns_hostnames = true
      tags = {
        Name = format("%s-%s", var.vpc_name, "vpc")
      }
  
}

data "aws_availability_zones" "available"{
      state = "available"
     filter { # Only fetch Availability Zones (no Local Zones)
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }

} 

//public subnet 
resource "aws_subnet" "public" {
  count                   = var.number_of_subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.area_subnet_cidr, 4, count.index + length(data.aws_availability_zones.available.names) + 1)
  availability_zone_id = data.aws_availability_zones.available.zone_ids[count.index % length(data.aws_availability_zones.available.zone_ids)]

  map_public_ip_on_launch = true

  tags = {
    Name        = "public-subnet-${count.index}"
    Role        = "public"
    Environment = var.environment_name
  }

}

//private subnet
resource "aws_subnet" "private" {
  count      = var.number_of_subnets
  vpc_id     = aws_vpc.vpc.id
  cidr_block           = cidrsubnet(var.area_subnet_cidr, 4, count.index)
  availability_zone_id = data.aws_availability_zones.available.zone_ids[count.index % length(data.aws_availability_zones.available.zone_ids)]
  map_public_ip_on_launch = false

  tags = {
    Name        = "private-subnet-${count.index}"
    Role        = "private"
    Environment = var.environment_name
  }

}

resource "aws_instance" "ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.application.id]
  subnet_id = aws_subnet.public[0].id
  # other instance configuration parameters go here

  # attach EBS volumes to the instance
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 50
    volume_type = "gp2"
    delete_on_termination = true
  }

  root_block_device {
    volume_size = 50
    volume_type = "gp2"
    delete_on_termination = true
  }
  disable_api_termination = false
  tags = {
    Name = "ec2-instance"
  }


}


resource "aws_security_group" "application" {
  name_prefix = "application_sg_"
  description = "Security group for hosting web applications"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    from_port   = 3030
    to_port     = 3030
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 3030
    to_port     = 3030
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


