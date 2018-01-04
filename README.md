terraform-modules
=================


Set of terraform modules for basic AWS infra. Some modules comes from _offcial_ terraform modules with modifications for our case. 

Branch master suppose to be stable but in generall it is work in progress.

For complete _base_ project using these modules go to https://github.com/Tivix/terraform-base

Examples
--------

VPC
---
```
module "vpc" {
  source = "github.com/Tivix/terraform-modules/vpc"
  cidr   = "10.10.0.0/16"

  name = "${format("%s@%s", var.project_name, var.env)}"
  env  = "${var.env}"

  azs            = ["eu-west-1a"]
  public_subnets = ["10.10.10.0/24"]

  create_database_subnet_group = false

  tags = {
    Owner       = "${var.owner}"
    Environment = "${var.env}"
  }
}```

EC2
---
```
module "ec2" {
  source = "github.com/Tivix/terraform-modules/ec2"

  env = "${var.env}"

  name                        = "${format("%s@%s", var.project_name, var.env)}"
  key_name                    = "${var.masterkey}"
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${element(module.vpc.public_subnets, 0)}"
  vpc_security_group_ids      = "${module.security_group.this_security_group_id}"
  associate_public_ip_address = true
}```