
locals {
  availability_zones = data.aws_availability_zones.available.names[*]
  account_id         = data.aws_caller_identity.current.account_id
  region             = data.aws_region.current.name
  default_tags = {
    Terraform   = "true"
    Environment = "dev"
  }

}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name            = "dev"
  cidr            = "10.0.16.0/21"
  public_subnets  = ["10.0.16.0/25", "10.0.16.128/25", "10.0.17.0/25"]
  private_subnets = ["10.0.18.0/24", "10.0.19.0/24", "10.0.20.0/24"]
  azs             = local.availability_zones

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = false
  enable_dns_support     = true
}
