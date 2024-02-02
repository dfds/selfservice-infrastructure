
terraform {
  backend "s3" {
    bucket         = "selfservice-tf-state"
    encrypt        = true
    key            = "selfservice-api/terraform.tfstate" # This is the path to the state file inside the bucket. You can change it to whatever you want.
    region         = "eu-west-1"
    dynamodb_table = "terraform-locks"
  }
}


provider "aws" {
  region = "eu-west-1"
}

module "db_instance" {
  source = "git::https://github.com/dfds/terraform-aws-rds.git?ref=0.16.15"

  #     Provide a cost centre for the resource.
  #     Valid Values: .
  #     Notes: This set the dfds.cost_centre tag. See recommendations [here](https://wiki.dfds.cloud/en/playbooks/standards/tagging_policy).
  cost_centre = "ti-arch"

  #     Specify data classification.
  #     Valid Values: public, private, confidential, restricted
  #     Notes: This set the dfds.data.classification tag. See recommendations [here](https://wiki.dfds.cloud/en/playbooks/standards/tagging_policy).
  data_classification = "private"

  #     Specify the staging environment.
  #     Valid Values: "dev", "test", "staging", "uat", "training", "prod".
  #     Notes: The value will set configuration defaults according to DFDS policies.
  environment = "dev"

  #     Specify the name of the RDS instance to create.
  #     Valid Values: .
  #     Notes: .
  identifier = "selfservice-dev"

  #     Specify whether or not to enable access from Kubernetes pods.
  #     Valid Values: .
  #     Notes: Enabling this will create the following resources:
  #       - IAM role for service account (IRSA)
  #       - IAM policy for service account (IRSA)
  #       - Peering connection from EKS Cluster requires a VPC peering deployed in the AWS account.
  is_kubernetes_app_enabled = true

  #     Specify service availability.
  #     Valid Values: low, medium, high
  #     Notes: This set the dfds.service.availability tag. See recommendations [here](https://wiki.dfds.cloud/en/playbooks/standards/tagging_policy).
  service_availability = "low"

  #     Specify Username for the master DB user.
  #     Valid Values: .
  #     Notes: .
  username = "selfserviceuser"

  # default vpc and subnets of DeveloperAutomation capability
  vpc_id     = "vpc-9471aded"
  subnet_ids = ["subnet-80232ae6", "subnet-a9574fe1", "subnet-ce3f7594"]

  instance_class = "db.t3.micro"
  engine_version = "16.1"

  # Not best practice, but necessary, for now, without VPC Peering
  is_publicly_accessible     = true
  public_access_ip_whitelist = ["0.0.0.0/0"]

  instance_parameters = [
    {
      name  = "log_connections"
      value = 1
    },
    {
      name  = "log_disconnections"
      value = 1
  }]
}

output "iam_instance_profile_for_ec2" {
  description = "The name of the EC2 instance profile that is using the IAM Role that give AWS services access to the RDS instance and Secrets Manager"
  value       = try(module.db_instance.iam_instance_profile_for_ec2, null)
}
output "iam_role_arn_for_aws_services" {
  description = "The ARN of the IAM Role that give AWS services access to the RDS instance and Secrets Manager"
  value       = try(module.db_instance.iam_role_arn_for_aws_services, null)
}
output "kubernetes_serviceaccount" {
  description = "If you create this Kubernetes ServiceAccount, you will get access to the RDS through IRSA"
  value       = try(module.db_instance.kubernetes_serviceaccount, null)
}
output "peering" {
  description = "None"
  value       = try(module.db_instance.peering, null)
}
