terraform {
  required_version = "= 1.9.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.67.0"
    }
  }

}

provider "aws" {
  region = "ap-southeast-1"
  default_tags {
    tags = local.default_tags
  }
}
