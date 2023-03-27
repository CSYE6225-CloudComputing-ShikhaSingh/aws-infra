//Configuration for the vpc

resource "aws_vpc" "vpc" {

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = format("%s-%s", var.vpc_name, "vpc")
  }
}

data "aws_availability_zones" "available" {
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
  cidr_block              = cidrsubnet(var.area_subnet_cidr, 4, count.index + length(data.aws_availability_zones.available.names) + 1)
  availability_zone_id    = data.aws_availability_zones.available.zone_ids[count.index % length(data.aws_availability_zones.available.zone_ids)]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index}"
    Role = "public"
    # Environment = var.environment_name
  }

}

//private subnet
resource "aws_subnet" "private" {
  count                   = var.number_of_subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.area_subnet_cidr, 4, count.index)
  availability_zone_id    = data.aws_availability_zones.available.zone_ids[count.index % length(data.aws_availability_zones.available.zone_ids)]
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-${count.index}"
    Role = "private"
    # Environment = var.environment_name
  }

}

data "aws_ami" "ec2-ami" {
  owners      = ["${var.AMIOwnerID}"]
  most_recent = true

}

resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.ec2-ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.application.id]
  subnet_id              = aws_subnet.public[0].id
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  user_data              = <<-EOF
                #!/bin/bash
                sudo touch .env\n
                sudo echo "DB_USERNAME=${aws_db_instance.database_instance.username}" >> /etc/environment
                sudo echo "DB_PASSWORD=${aws_db_instance.database_instance.password}" >> /etc/environment
                sudo echo "DB_HOSTNAME=${aws_db_instance.database_instance.address}" >> /etc/environment
                sudo echo "S3_BUCKET_NAME=${aws_s3_bucket.s3-private-bucket.bucket}" >> /etc/environment
                sudo echo "DB_ENDPOINT=${aws_db_instance.database_instance.endpoint}" >> /etc/environment
                sudo echo "DB_NAME=${aws_db_instance.database_instance.db_name}" >> /etc/environment
                suo echo "AWS_REGION=${var.AWS_REGION}" >> /etc/environment
                chown -R ec2-user:www-data /var/www
                usermod -a -G www-data ec2-user
                chmod +x /etc/environment
                source /etc/environment
                sudo systemctl daemon-reload
                sudo systemctl start webapp.service
                sudo systemctl enable webapp.service
                npx sequelize db:migrate
                sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
                -a fetch-config \
                -m ec2 \
                -c file:/opt/aws/amazon-cloudwatch-agent/bin/cloudwatch-config.json \
                -s
                EOF

  tags = {
    Name = "csye6225-ec2-instance"
  }

  # attach EBS volumes to the instance
  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_size           = 50
    volume_type           = "gp2"
    delete_on_termination = true
  }

  root_block_device {
    volume_size           = 50
    volume_type           = "gp2"
    delete_on_termination = true
  }
  disable_api_termination = false

}


resource "aws_security_group" "application" {
  name_prefix = "application_sg_"
  description = "Security group for hosting web application"
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
  # ingress {
  #   from_port   = 5432
  #   to_port     = 5432
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}

resource "aws_security_group" "database" {
  name_prefix = "database-"
  description = "Security group for RDS instances"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.application.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//policy

resource "aws_iam_policy" "WebAppS3_policy" {
  name        = "WebAppS3"
  path        = "/"
  description = "This policy will allow EC2 instances to perform S3 buckets."

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:GetObject",
          "s3:ListAllMyBuckets",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        "Effect" : "Allow",
        "Resource" : "${data.aws_s3_bucket.s3-bucket.arn}/*"

      }
    ]

  })
}

//iam role

resource "aws_iam_role" "ec2-role" {
  name = "EC2-CSYE6225"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "rds_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
  role       = aws_iam_role.ec2-role.name
}

// Attaching cloudAgent policy to ec2 instance iam role
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.ec2-role.name
}


// attachment of policy to iam role
resource "aws_iam_role_policy_attachment" "WebAppS3_policy_attachment" {
  policy_arn = aws_iam_policy.WebAppS3_policy.arn
  role       = aws_iam_role.ec2-role.name
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2-role.name
}

//generate random uuid for bucket name
resource "random_string" "bucket_name" {
  length  = 4
  special = false
  upper   = false
  lower   = true
}

//s3 bucket

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  enable_key_rotation     = true
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "s3-private-bucket" {
  bucket        = "mybucket-${random_string.bucket_name.result}-${var.environment_name}"
  acl           = "private"
  force_destroy = true


  // delete bucket even if it is not empty
  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Environment = var.environment_name
  }
}

data "aws_s3_bucket" "s3-bucket" {
  bucket = aws_s3_bucket.s3-private-bucket.bucket
}


resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.s3-private-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      //kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_public_access_block" "publicAccessBlockS3" {
  bucket             = aws_s3_bucket.s3-private-bucket.id
  ignore_public_acls = true
}


//Lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_configuration" {

  bucket = aws_s3_bucket.s3-private-bucket.id
  rule {
    id     = "storage-rule"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"

    }
    filter {
      prefix = ""
    }

    expiration {
      days = 90
    }

  }
}

# //parameter group
resource "aws_db_parameter_group" "parameter_groups" {
  name        = "postgres-parameter-group"
  family      = "postgres14"
  description = "Parameter Group for Postgres 14"

  parameter {
    name         = "max_connections"
    value        = "500"
    apply_method = "pending-reboot"

  }

  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "idle_in_transaction_session_timeout"
    value        = "60000"
    apply_method = "pending-reboot"

  }
}

//RDS instance

resource "aws_db_instance" "database_instance" {
  db_name                = var.db_name
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance
  username               = var.db_username
  password               = var.db_password
  port                   = var.db_port
  identifier             = var.identifier
  availability_zone      = var.availability_zone
  vpc_security_group_ids = [aws_security_group.database.id]
  parameter_group_name   = aws_db_parameter_group.parameter_groups.name
  apply_immediately      = true
  db_subnet_group_name   = aws_db_subnet_group.private_subnet_for_rds_instance.name
  multi_az               = false
  publicly_accessible    = false
  allocated_storage      = var.allocated_storage
  skip_final_snapshot    = true
}

data "aws_db_instance" "database_data" {
  db_instance_identifier = aws_db_instance.database_instance.name
}

output "rds_endpoint" {
  value = data.aws_db_instance.database_data.endpoint
}


resource "aws_db_subnet_group" "private_subnet_for_rds_instance" {
  name       = "private-subnet-for-rds-instances"
  subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id]

  tags = {
    //Environment = var.environment
    Name = "RDS subnet group"
  }
}












