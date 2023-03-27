variable "environment_name" {
  type        = string
  description = "Dev environment"
  default     = "dev"
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

# variable "ami_id" {
#   type = string
# }

variable "instance_type" {
  type = string
}
variable "area_subnet_cidr" {
  description = "The base CIDR that you are working with"
  type        = string
  default     = "10.0.0.0/16"
}

variable "destination_cidr" {
  description = "The destination CIDR that you are working with"
  type        = string
  default     = "0.0.0.0/0"

}

variable "key_name" {
  type    = string
  default = "ec2"
}

variable "db_instance_name" {
  type    = string
  default = "postgres-database"
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
variable "AMIOwnerID" {
  type    = number
  default = "475967084164"
}

variable "zone_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "AWS_REGION" {
  type    = string
  default = "us-east-1"
}