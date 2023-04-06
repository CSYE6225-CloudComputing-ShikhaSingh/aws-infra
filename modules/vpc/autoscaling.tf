data "template_file" "user_data" {

  template = <<EOF

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

}

resource "aws_launch_template" "asg_launch_config" {
  name                    = "csye6225-webapp"
  image_id                = data.aws_ami.ec2-ami.id
  instance_type           = "t2.micro"
  key_name                = var.key_name
  user_data               = base64encode(data.template_file.user_data.rendered)
  disable_api_termination = true

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.application.id]

  }

  lifecycle {
    create_before_destroy = true
  }

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size           = 20
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  tags = {
    Name = "csye6225-instance"
  }

  #     block_device_mappings {
  #     device_name = "/dev/sdf"

  #         root {
  #         volume_size           = 50
  #         volume_type           = "gp2"
  #         delete_on_termination = true
  #     }


  #   }


  #   ebs_block_device {
  #     device_name           = "/dev/sdf"
  #     volume_size           = 50
  #     volume_type           = "gp2"
  #     delete_on_termination = true
  #   }

  #   root_block_device {
  #     volume_size           = 50
  #     volume_type           = "gp2"
  #     delete_on_termination = true
  #   }
  #   disable_api_termination = false


}

// autoscaling group

resource "aws_autoscaling_group" "asg_webapp" {

  name                = "csye6225-asg-fall2023"
  desired_capacity    = 1
  max_size            = 3
  min_size            = 1
  default_cooldown    = 60
  vpc_zone_identifier = [aws_subnet.public[0].id]

  tag {

    key = "Application"

    value = "WebApp"

    propagate_at_launch = true

  }

  launch_template {

    id      = aws_launch_template.asg_launch_config.id
    version = "$Latest"

  }

  target_group_arns = [

    aws_lb_target_group.application-target-group.arn

  ]

}

//Scale-Up Policy
resource "aws_autoscaling_policy" "WebServerScaleUpPolicy" {
  name                   = "WebServerScaleUpPolicy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.asg_webapp.name
}

//Scale-Down Policy
resource "aws_autoscaling_policy" "WebServerScaleDownPolicy" {
  name                   = "WebServerScaleDownPolicy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.asg_webapp.name
}


//Alarm for CPU High
resource "aws_cloudwatch_metric_alarm" "CPUAlarmHigh" {
  alarm_name          = "CPUAlarmHigh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "5"
  alarm_description   = "Scale-up if CPU > 5% for 300 seconds"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_webapp.name
  }

  alarm_actions = [aws_autoscaling_policy.WebServerScaleUpPolicy.arn]
}

//Alarm for CPU Low
resource "aws_cloudwatch_metric_alarm" "CPUAlarmLow" {
  alarm_name          = "CPUAlarmLow"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "3"
  alarm_description   = "Scale-down if CPU < 3% for 300 seconds"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_webapp.name
  }

  alarm_actions = [aws_autoscaling_policy.WebServerScaleDownPolicy.arn]
}

