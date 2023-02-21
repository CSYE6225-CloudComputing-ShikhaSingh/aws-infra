variable "environment_name" {
  type        = string
  description = "Dev environment"
  default     = "dev"
}

variable "vpc_name" {
  type    = string
}

variable "number_of_subnets" {
   type=number
 }

 variable "vpc_cidr" {
   type=string
   description = "The IP range to use for the vpc"
 }

 variable "region" {
      type=string

 }

variable "ami_id" {
  type=string
}

variable "instance_type" {
  type=string
}
 variable "area_subnet_cidr"{
    description = "The base CIDR that you are working with"
    type = string
    default="10.0.0.0/16"
}

variable "destination_cidr"{
    description = "The destination CIDR that you are working with"
    type = string
    default="0.0.0.0/0"

}
