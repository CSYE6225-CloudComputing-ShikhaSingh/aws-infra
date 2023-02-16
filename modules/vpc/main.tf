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

