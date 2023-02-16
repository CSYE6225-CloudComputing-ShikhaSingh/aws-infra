<<<<<<< HEAD
# aws-infra
This repository is for AWS setup
=======
Terraform Infrastructure Setup Guide

This guide provides instructions for setting up your infrastructure using Terraform. Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently.

Prerequisites
Before starting, you need to have the following:

Terraform installed on your local machine.
An account on a cloud platform such as AWS, Azure, or Google Cloud.
Access to the cloud platform's command line interface (CLI) or API credentials.

Setting Up the Environment

1. Install the terraform in local machine using the below commands
2. Change into the Terraform configuration directory:
cd <repo>
3. Initialize Terraform:
terraform init
This will download the necessary plugins for the cloud platform you are using.
4. Set up the cloud platform provider by adding the following to the provider.tf file:
   
provider "aws" {
  region = "us-east-1"
}

Replace aws with the appropriate provider (e.g., azurerm for Azure, google for Google Cloud) and the region with the desired region.


Providing access key and id using profile in aws:

We can provide our access key and access ID to Terraform using an AWS profile stored in your AWS credentials file. Here's how we can set it up:

Create a new profile in your AWS credentials file. The credentials file is typically located at ~/.aws/credentials:

[terraform]
aws_access_key_id = ACCESS_KEY
aws_secret_access_key = SECRET_KEY

Replace ACCESS_KEY and SECRET_KEY with your actual access key and secret access key, respectively.

In your Terraform configuration file, specify the provider using the profile:

provider "aws" {
  profile = "terraform"
  region  = "us-east-1"
}

This will use the credentials from the terraform profile in the AWS credentials file.

When you run Terraform, it will automatically use the credentials from the specified profile.

By using an AWS profile, you can keep sensitive information such as access keys and secret keys separate from your Terraform configuration, making it easier to manage and more secure. Additionally, you can have multiple profiles in your AWS credentials file, allowing you to switch between different AWS accounts or roles easily.



Creating Infrastructure

1. Run the following command to see a preview of the changes Terraform will make:
   
    terraform plan

2. If the output is as expected, apply the changes by running the following command:
   
   terraform apply

   This will create the infrastructure as specified in the main.tf file.

Updating Infrastructure
To update your infrastructure, make the desired changes to the main.tf file and run the following commands:

terraform plan
terraform apply

Destroying Infrastructure
To destroy the infrastructure, run the following command:

terraform destroy

This will remove all resources created by Terraform.


Conclusion
This guide provided instructions for setting up our infrastructure using Terraform. By following these steps, we can easily manage your infrastructure, making changes and updates with confidence.



  


>>>>>>> b0400b2 (Adding the readme file)
