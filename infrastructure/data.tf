data "aws_ami" "instance_ami" {
  most_recent = true
  owners      = ["self"]
  tags = {
    build_id   = var.build_id
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

