output "vpc_id" {
    value = "${aws_vpc.vpc.id}"
}

output "public_subents_id" {
    value = "aws_subnet.public_subnets.*.id"
}

output "private_subents_id" {
    value = "aws_subnet.private_subnet.*.id"
}

output "default_sg_id" {
    value = "${aws_security_group.default.id}"
}