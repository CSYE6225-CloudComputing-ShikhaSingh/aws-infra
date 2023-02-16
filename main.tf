
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
  region = var.region
  profile = var.profile
}

module "vpc" {
  source            = "./modules/vpc"
  vpc_cidr          = var.vpc_cidr
  number_of_subnets = var.number_of_subnets
  region            = var.region
}

variable "vpc_name" {
  type    = string
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
