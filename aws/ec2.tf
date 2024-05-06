locals {
  ec2_instances = {
    "ec2_instance_external" = {
      ami_id                  = "ami-0dfdc165e7af15242" # al2023-ami-2023.4.20240429.0-kernel-6.1-x86_64
      instance_type           = "t3.micro"
      key_name                = "my-ssh-key"
      disable_api_termination = false
      vpc_security_group_ids = [
        aws_security_group.this["allow_tls"].id,
        aws_security_group.this["allow_tls_bw_instances"].id
      ]
      subnet_id            = module.vpc.public_subnets[0]
      root_ebs_size        = 8
      root_ebs_volume_type = "gp3"
    }
    "ec2_instance_internal" = {
      ami_id                  = "ami-0dfdc165e7af15242" # al2023-ami-2023.4.20240429.0-kernel-6.1-x86_64
      instance_type           = "t3.micro"
      key_name                = "my-ssh-key"
      disable_api_termination = false
      vpc_security_group_ids  = [aws_security_group.this["allow_tls_bw_instances"].id]
      subnet_id               = module.vpc.private_subnets[0]
      root_ebs_size           = 8
      root_ebs_volume_type    = "gp3"
    }
  }

}
#Encryption by Default, ensuring that all new EBS volumes created in the account are encrypted.
resource "aws_ebs_encryption_by_default" "this" {
  enabled = true
}

#aws default kms key
data "aws_ebs_default_kms_key" "current" {}

resource "aws_instance" "this" {
  for_each = local.ec2_instances

  ami                     = each.value.ami_id
  instance_type           = each.value.instance_type
  key_name                = each.value.key_name
  disable_api_termination = lookup(each.value, "disable_api_termination", null)
  vpc_security_group_ids  = each.value.vpc_security_group_ids
  subnet_id               = each.value.subnet_id
  iam_instance_profile    = lookup(each.value, "iam_instance_profile", null)
  root_block_device {
    volume_type = lookup(each.value, "root_ebs_volume_type", "gp3")
    volume_size = each.value.root_ebs_size
    encrypted   = true
    kms_key_id  = lookup(each.value, "kms_key_id", data.aws_ebs_default_kms_key.current.key_arn)
    tags        = merge({ Name : each.key }, local.default_tags)
  }
  tags = merge({ Name : each.key })
}