terraform {
  source = "git::https://github.com/dfds/infrastructure-modules.git//database/postgres?ref=0.7.12"
}

# Include all settings from the root terraform.tfvars file
include {
  path = "${find_in_parent_folders()}"
}

inputs = {
  aws_region = "eu-west-1"
  application = "confluent-gateway"
  db_name = "cgdb"
  db_master_username = "cguser"
  environment = "prod"
  engine_version = 14
  db_instance_class = "db.t3.micro"
}
