terraform {
  required_version = ">= 0.10.3" # introduction of Local Values configuration language feature
}

######
# VPC
######
resource "aws_vpc" "this" {
  cidr_block           = "${var.cidr}"
  instance_tenancy     = "${var.instance_tenancy}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"

  tags = "${merge(var.tags, var.vpc_tags, map("Name", format("%s", var.name)))}"
}

###################
# Internet Gateway
###################
resource "aws_internet_gateway" "this" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}

################
# Publiс routes
################
resource "aws_route_table" "public" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id           = "${aws_vpc.this.id}"
  propagating_vgws = ["${var.public_propagating_vgws}"]

  tags = "${merge(var.tags, var.public_route_table_tags, map("Name", format("%s-public", var.name)))}"
}

resource "aws_route" "public_internet_gateway" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"
}

################
# Public subnet
################
resource "aws_subnet" "public" {
  count = "${length(var.public_subnets)}"

  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "${var.public_subnets[count.index]}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags = "${merge(var.tags, var.public_subnet_tags, map("Name", format("%s-public-%s", var.name, element(var.azs, count.index))))}"
}

##################
# Database subnet
##################
resource "aws_subnet" "database" {
  count = "${length(var.database_subnets)}"

  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${var.database_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(var.tags, var.database_subnet_tags, map("Name", format("%s-db-%s", var.name, element(var.azs, count.index))))}"
}

resource "aws_db_subnet_group" "database" {
  count = "${length(var.database_subnets) > 0 && var.create_database_subnet_group ? 1 : 0}"

  name        = "${var.name}"
  description = "Database subnet group for ${var.name}"
  subnet_ids  = ["${aws_subnet.database.*.id}"]

  tags = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}

##########################
# Route table association
##########################
resource "aws_route_table_association" "database" {
  count = "${length(var.database_subnets)}"

  subnet_id = "${element(aws_subnet.database.*.id, count.index)}"
}

resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnets)}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
