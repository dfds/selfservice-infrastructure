

remote_state {
  backend = "s3"

  config = {
    encrypt        = true
    bucket         = "dfds-oxygen-selfservice-terraform-state"
    key            = "selfservice/${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "selfservice-terraform-locks"
  }
}

# Configure Terragrunt to use common var files to help you keep often-repeated variables (e.g., account ID) DRY.
# Note that even though Terraform automatically pulls in terraform.tfvars, we include it explicitly at the end of the
# list to make sure its variables override anything in the common var files.
terraform {
  extra_arguments "common_vars" {
    commands = "${get_terraform_commands_that_need_vars()}"

    optional_var_files = [
      "${get_terragrunt_dir()}/${find_in_parent_folders("account.tfvars", "skip-account-if-does-not-exist")}",
      "${get_terragrunt_dir()}/${find_in_parent_folders("region.tfvars", "skip-region-if-does-not-exist")}",
      "${get_terragrunt_dir()}/${find_in_parent_folders("env.tfvars", "skip-env-if-does-not-exist")}",
      "${get_terragrunt_dir()}/terraform.tfvars",
    ]
  }
}
