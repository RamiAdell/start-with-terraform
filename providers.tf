provider "aws" {
  region                  = var.vpc_region
  shared_config_files     = var.shared_config_file
  shared_credentials_files = var.shared_credentials_file
  profile                 = "default"
}
