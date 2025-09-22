variable "vpc_region" {
  type = string
}

variable "shared_config_file" {
  type = list(string)
}

variable "shared_credentials_file" {
  type = list(string)
}

variable "key_path" {
  description = "The path to the private key file for SSH access"
  type        = string
  default     = "~/.aws/rami-key2.pem"
}