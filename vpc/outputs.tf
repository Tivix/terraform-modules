# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${aws_vpc.this.id}"
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = "${aws_vpc.this.cidr_block}"
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = "${aws_vpc.this.default_security_group_id}"
}

output "default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = "${aws_vpc.this.default_network_acl_id}"
}

output "default_route_table_id" {
  description = "The ID of the default route table"
  value       = "${aws_vpc.this.default_route_table_id}"
}

# Subnets
output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = ["${aws_subnet.public.*.id}"]
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = ["${aws_subnet.public.*.cidr_block}"]
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = ["${aws_subnet.database.*.id}"]
}

output "database_subnets_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value       = ["${aws_subnet.database.*.cidr_block}"]
}

output "database_subnet_group" {
  description = "ID of database subnet group"
  value       = "${element(concat(aws_db_subnet_group.database.*.id, list("")), 0)}"
}

# Route tables
output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = ["${aws_route_table.public.*.id}"]
}

# Internet Gateway
output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = "${element(concat(aws_internet_gateway.this.*.id, list("")), 0)}"
}
