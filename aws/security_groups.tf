locals {
  security_groups = {
    allow_tls = {
      description = "Allow TLS inbound traffic"
      ingress = {
        all_tls = {
          from_port   = 443
          to_port     = 443
          ip_protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
    allow_all_bw_instances = {
      description = "Allow All inbound traffic bw instances"
      ingress = {
        self_tls = {
          from_port = 0
          to_port   = 0
          protocol  = "-1"
          self      = true
        }
      }
    }
  }
}

resource "aws_security_group" "this" {
  for_each    = local.security_groups
  name        = each.key
  description = each.value.description
  vpc_id      = module.vpc.vpc_id
  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.ip_protocol
      self        = try(ingress.value.self, false)
      cidr_blocks = try(ingress.value.cidr_blocks, [])
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  tags = {
    Name = each.key
  }
}
