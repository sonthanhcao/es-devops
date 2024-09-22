data "aws_availability_zones" "available" {}

locals {

  vpc_cidr = "10.101.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  public_subnets = [
    "10.101.240.0/24",
    "10.101.241.0/24",
    "10.101.242.0/24",
    "10.101.48.0/20",
    "10.101.64.0/20",
    "10.101.80.0/20"
  ]
  private_subnets = [
    "10.101.0.0/20",
    "10.101.16.0/20",
    "10.101.32.0/20",
  ]

  tags = {
    Name = local.name
    Repo = ""
  }
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.9.0"
  name    = local.name
  cidr    = local.vpc_cidr

  azs             = local.azs
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  # 1 NAT Gateway per AZ
  enable_nat_gateway     = false
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  tags                   = local.tags

}
module "sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "5.1.2"
  name        = "${local.name}-sg"
  description = "Security group"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["10.101.0.0/16"]
  ingress_rules       = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8090
      protocol    = "tcp"
      description = ""
      cidr_blocks = "10.101.0.0/16"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = ""
      cidr_blocks = "10.101.0.0/16"
    }
  ]
  # Open to CIDRs blocks (rule or from_port+to_port+protocol+description)
  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

}