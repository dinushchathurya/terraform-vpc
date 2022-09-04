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
resource "aws_subent" "public_subent" { 
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
resource "aws_subnet" "private_subnet" {
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

/* elastic ip for nat gateway */
resource "aws_eip" "nat_eip" {
    vpc = true
    depends_on = [aws_internet_gateway.igw]

    tags = {
        Name        = "${var.project}-nat-eip"
        Environment = "${var.environment}"
    }
}

/* nat */
resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
    depends_on    = [aws_internet_gateway.igw]

    tags = {
        Name        = "${var.project}-nat"
        Environment = "${var.environment}"
    }
}

/* security group */
resource "aws_security_group" "default" {
    name        = "${var.project}-sg"
    description = "Security group for ${var.project}"
    vpc_id      = aws_vpc.vpc.id
    depends_on  = [aws_vpc.vpc]

    ingress {    
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        self             = true
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        Name        = "${var.project}-sg"
        Environment = "${var.environment}"
    }
}