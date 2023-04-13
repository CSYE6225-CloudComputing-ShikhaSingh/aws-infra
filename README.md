# aws-infra
This repository is for AWS setup
=====================================
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

Creating Route 53 and Adding Type A Records

Introduction
Amazon Route 53 is a highly scalable and reliable Domain Name System (DNS) service provided by Amazon Web Services (AWS). It can be used to manage domain registration, DNS routing, and health checking. In this README, we will go through the steps required to create a Route 53 hosted zone and add Type A records to it.

Prerequisites
Before getting started, you will need the following:

An AWS account with appropriate permissions to create Route 53 hosted zones and records.

A registered domain name that you want to use with Route 53.
The IP address of the server or resource you want to create a record for.

Creating a Route 53 Hosted Zone
Log in to the AWS Management Console and navigate to the Route 53 dashboard.
Click on "Create Hosted Zone".
Enter your domain name in the "Domain Name" field.
Choose the "Public Hosted Zone" option if you want to use Route 53 to manage DNS for a domain that is publicly accessible on the internet. Choose the "Private Hosted Zone" option if you want to use Route 53 to manage DNS for a domain that is only accessible within your VPC.
Click on "Create Hosted Zone".
Adding a Type A Record
In the Route 53 dashboard, click on the name of the hosted zone you just created.
Click on "Create Record Set".
Enter the name of the record in the "Name" field. This should be the domain name you want to create a record for (e.g. www.example.com).
Select "A - IPv4 address" from the "Type" drop-down menu.
Enter the IP address of the server or resource you want to create a record for in the "Value" field.
Optionally, set a TTL (Time To Live) value for the record. This determines how long the record will be cached by DNS resolvers.
Click on "Create Record Set".
Conclusion
By following these steps, you should now have a Route 53 hosted zone set up and a Type A record added to it. You can repeat the process to add additional records as needed. Remember to keep your DNS records up-to-date and secure to ensure smooth operation of your domain.



Creating Infrastructure
1. Run the following command to check the format of the terraform files
   
   terraform fmt
   
2. Run the following command to see a preview of the changes Terraform will make:
   
    terraform plan

3. If the output is as expected, apply the changes by running the following command:
   
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


Assignment 8 and 9:

Adding Load Balancing, Autoscaling, and Certificates using Terraform
This README file outlines the steps to use Terraform to add load balancing, autoscaling, and SSL/TLS certificates to your web application.

Load Balancing
Load balancing distributes incoming traffic across multiple servers to improve application performance and availability. Here are the general steps to add load balancing to your web application using Terraform:

Define a load balancer resource in your Terraform configuration file, specifying the load balancer type (e.g., ELB, ALB, NLB) and other relevant parameters.
Define an autoscaling group resource in your Terraform configuration file, specifying the instance type, AMI, and other relevant parameters.
Define a launch configuration resource in your Terraform configuration file, specifying the user data script to install and configure your web server software.
Configure your load balancer to distribute traffic evenly across multiple instances, using a target group resource in your Terraform configuration file.
Point your domain name to the load balancer's DNS name.
Autoscaling
Autoscaling automatically adjusts the number of servers in your application's cluster based on changes in demand. Here are the general steps to add autoscaling to your web application using Terraform:

Define an autoscaling group resource in your Terraform configuration file, specifying the minimum and maximum number of instances, scaling policies, and other relevant parameters.
Configure your load balancer to automatically add new instances to the target group as they are launched.
Certificates
SSL/TLS certificates encrypt data transmitted between your web server and clients, such as web browsers. Here are the general steps to add SSL/TLS certificates to your web application using Terraform:

Define an SSL/TLS certificate resource in your Terraform configuration file, specifying the certificate data and other relevant parameters.
Configure your load balancer to use the certificate for HTTPS connections, using a listener resource in your Terraform configuration file.
Conclusion
By following these steps, you can use Terraform to add load balancing, autoscaling, and SSL/TLS certificates to your web application. These features can help improve performance, availability, and security, respectively. Terraform allows you to manage your infrastructure as code, making it easier to provision, update, and manage your resources.


// command to import the certificate

aws iam upload-server-certificate --server-certificate-name demo_ss-csye6225_me.crt --certificate-body file://*path to your certificate file* --private-key file://*path to your private key file* --certificate-chain file://*path to your CA-bundle file*


// to verify the certificate information

aws iam get-server-certificate --server-certificate-name certificate_object_name

openssl req -new -newkey rsa:2048 -nodes -keyout server.key -out server.csr

// to generate the private key
openssl rsa -in server.key -outform PEM > server.private.pem

// to convert the certificate in pem format
openssl x509 -in demo_ss-csye6225_me.crt -out mycert.pem -outform PEM

openssl x509 -in demo_ss-csye6225_me.crt -outform PEM > mycert.pem

openssl x509 -noout -text -in ~/Desktop/yourcertificate.crt  
