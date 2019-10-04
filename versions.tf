# There should be listed provider and terraform constraints
# Info: Please only use minimum required version operator (>=) or (~>) to allow portability
# https://www.terraform.io/docs/configuration/terraform.html#specifying-a-required-terraform-version


terraform {
  required_version = ">= 0.12.0"
  required_providers {
    aws   = ">= 2.0"
    local = ">= 1.2"
    null  = ">= 2.0"
  }
}
