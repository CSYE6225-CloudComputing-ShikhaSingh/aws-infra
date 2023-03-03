
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.16 , <5.0"

    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

module "vpc" {
  source            = "./modules/vpc"
  vpc_cidr          = var.vpc_cidr
  number_of_subnets = var.number_of_subnets
  region            = var.region
  vpc_name          = var.vpc_name
  // ami_id            = var.ami_id
  instance_type     = var.instance_type
  db_username       = var.db_username
  db_password       = var.db_password
  db_name           = var.db_name
  db_instance       = var.db_instance
  db_engine         = var.db_engine
  db_engine_version = var.db_engine_version
  db_port           = var.db_port
  allocated_storage = var.allocated_storage
  availability_zone = var.availability_zone
  identifier        = var.identifier

}


variable "vpc_name" {
  type = string
}

variable "number_of_subnets" {
  type = number
}

variable "vpc_cidr" {
  type        = string
  description = "The IP range to use for the vpc"
}
variable "region" {
  type = string

}

variable "profile" {
  type = string

}

# variable "ami_id" {
#   type = string
# }

variable "instance_type" {
  type = string
}


variable "db_username" {
  type = string
}

variable "db_password" {
  type = string

}

variable "db_name" {
  type = string

}
variable "db_engine" {
  type = string
}
variable "db_engine_version" {
  type = number
}
variable "db_instance" {
  type    = string
  default = "db.t3.micro"
}
variable "db_port" {
  type    = number
  default = "5432"
}

variable "allocated_storage" {
  type    = number
  default = "10"
}
variable "identifier" {
  type = string
}
variable "availability_zone" {
  type    = string
  default = "us-east-1a"
}