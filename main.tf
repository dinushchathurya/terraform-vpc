resource "aws_vpc" "vpc" {

    cidr_block           = "var.vpc_cidr"
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name        = "${var.project}-vpc",
        Environment = "${var.environment}"
    }

}

/* public subent */
resource "aws_subent" "public" { 

    vpc_id     = aws.vpc_id
    count      = lenght(var.public_subnets_cidr)
    cidr_block = element(var.public_subnets_cidr, count.index) 
    availability_zone = elements(var.availability_zones, count.index)
    map_public_ip_on_launch = true
    
    tags = { 
        Name        = "${var.project}-$element(var.availability_zones, count.index)-public-subnet"
        Environment = "${var.environment}"
    }
}

/* private subnet */
resource "aws_subnet" "private" {

    vpc_id            = aws_vpc.vpc.id
    count             = length(var.private_subnets_cidr)
    cidr_block        = element(var.private_subnets_cidr, count.index)
    availability_zone = element(var.availability_zones, count.index)

    tags = {
        Name        = "${var.project}-$element(var.availability_zones, count.index)-private-subnet"
        Environment = "${var.environment}"
    }
}

/* internet gateway for public subnet */
resource "aws_internet_gateway" "igw" {

    vpc_id = aws_vpc.vpc.id

    tags = {
        Name        = "${var.project}-igw"
        Environment = "${var.environment}"
    }
    
}