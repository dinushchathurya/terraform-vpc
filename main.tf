resource "aws_vpc" "demo" {

    cidr_block           = "var.vpc_cidr"
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name        = "${var.project}-vpc",
        Environment = "${var.environment}"
    }
    
}
