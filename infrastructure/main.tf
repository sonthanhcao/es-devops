data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "template_file" "startup_script" {
  template = file("${path.module}/user-data.tpl")
  vars = {
    SPOT         = local.spot
    REGION       = local.region
    APP_NAME     = local.name
    APP_ENV      = local.app_env
    ACCOUNT_ID   = local.account_id
  }
}

data "aws_ami" "default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"]
  }
}

locals {
  name          = "sc-dev"
  region        = data.aws_region.current.name
  app_env       = "dev"
  instance_type = "m5.large"
  spot          = "true"
  spot_type     = "persistent"
  account_id    = data.aws_caller_identity.current.account_id

  vpc_sg     = [module.sg.security_group_id]
  subnet_id  = module.vpc.public_subnets[0]
  key_name  = ""

  user_data = data.template_file.startup_script.rendered

  default_tags = {
    Terraform   = "true"
    Environment = "${local.app_env}"
    Application = "sc-dev"
    Team        = "devops"
    Contact     = "devops"
  }
}

module "ec2" {
  source        = "terraform-aws-modules/ec2-instance/aws"
  version       = "5.7.0"
  name          = local.name
  ami           = data.aws_ami.default.id
  instance_type = local.instance_type
  key_name      = local.key_name

  create_spot_instance = local.spot
  spot_type            = local.spot_type

  iam_role_use_name_prefix = false
  iam_role_name            = "sc-dev-role"

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring                  = true
  vpc_security_group_ids      = local.vpc_sg
  subnet_id                   = local.subnet_id
  associate_public_ip_address = true
  # Startup script
  user_data_base64            = base64encode(local.user_data)
  user_data_replace_on_change = true 

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore         = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    AmazonSSMFullAccess                  = "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    AmazonEC2ContainerRegistryFullAccess = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    IAMFullAccess                        = "arn:aws:iam::aws:policy/IAMFullAccess",
    AmazonEC2FullAccess                  = "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
  }


  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 250
      volume_size = 50
    },
  ]

  tags = merge(
    local.default_tags,
    {
      Name = local.name
    },
  )
}
