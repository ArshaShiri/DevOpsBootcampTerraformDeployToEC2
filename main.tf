provider "aws" {
  region = "eu-west-3"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
      # dev-vpc, staging-vpc...
      Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
      Name = "${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "myapp-igw" {
	vpc_id = aws_vpc.myapp-vpc.id
    
    tags = {
     Name = "${var.env_prefix}-internet-gateway"
   }
}

resource "aws_default_route_table" "main-rtb" {
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name = "${var.env_prefix}-main-rtb"
    }
}

# resource "aws_route_table" "myapp-route-table" {
#    vpc_id = aws_vpc.myapp-vpc.id
# 
#    route {
#      cidr_block = "0.0.0.0/0"
#      gateway_id = aws_internet_gateway.myapp-igw.id
#    }
# 
#    # default route, mapping VPC CIDR block to "local", created implicitly and cannot be specified.
# 
#    tags = {
#      Name = "${var.env_prefix}-route-table"
#    }
#  }
# 
# # Associate subnet with Route Table
# resource "aws_route_table_association" "a-rtb-subnet" {
#   subnet_id = aws_subnet.myapp-subnet-1.id
#   route_table_id = aws_route_table.myapp-route-table.id
# }

# resource "aws_security_group" "myapp-sg" {
#   name   = "myapp-sg"
#   vpc_id = aws_vpc.myapp-vpc.id
# 
#   # Ingress for Incoming traffic (ssh, browser etc)
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = [var.my_ip]
#   }
# 
#   ingress {
#     from_port   = 8080
#     to_port     = 8080
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# 
#   # Egress for exiting traffic (installation or fetching docker images)
#   egress {
#     # We let the access for any configurations
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     cidr_blocks     = ["0.0.0.0/0"]
#     prefix_list_ids = []
#   }
# 
#   tags = {
#     Name = "${var.env_prefix}-sg"
#   }
# }

resource "aws_default_security_group" "default-sg" {
    vpc_id = aws_vpc.myapp-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name = "${var.env_prefix}-default-sg"
    }
}

