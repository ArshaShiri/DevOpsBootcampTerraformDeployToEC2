provider "aws" {
  region = "eu-west-3"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}
variable public_key_location {}
variable private_key_location {}

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

# Querying the latest image id for AMI.
# You can check the information of AMI under EC2 AMI.
# The owner and other info are accessible there.
data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

# We can output the result of the aws_ami query here for checking.
# We can use terraform plan to check the output
output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linux-image.id
}

# Output the public IP of created EC2
output "ec2_public_ip" {
    value = aws_instance.myapp-server.public_ip
}

# resource "aws_key_pair" "ssh-key" {
#     key_name = "server-key"
#     public_key = file(var.public_key_location)
# }

resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.myapp-subnet-1.id

    # We can have a list of security groups here.
    vpc_security_group_ids = [aws_default_security_group.default-sg.id]
    availability_zone = var.avail_zone

    associate_public_ip_address = true

    # Better not to hardcode this
    key_name = "server-key-pair"

    # Use instead:
    # key_name = aws_key_pair.ssh-key.key_name

    # This script runs only in the start of EC2 creation and in the subsequent runs it is not executed (Unless the resource is destroyed and created again of course)
    user_data = file("entry-script.sh")

    # Specifies the connection of the provisioner to the server.
    connection {
        type = "ssh"
        host = self.public_ip
        user = "ec2-user"
        private_key = file(var.private_key_location)
    }

    # We use this to copy the file we need to the server.
    provisioner "file" {
        source = "entry-script.sh"
        destination = "/home/ec2-user/entry-script-on-ec2.sh"
    }

    # provisioner "file" {
    #     source = "entry-script.sh"
    #     destination = "/home/ec2-user/entry-script-on-ec2.sh"
    # 
    #     # we can use another connection block to use this provisioner on another server if we need to.
    #     connection {
    #         type = "ssh"
    #         host = some-other-server.public_ip
    #         user = "ec2-user"
    #         private_key = file(var.private_key_location)
    #     }
    # }

    # Allows us to connect to the server and execute commands on it.
    provisioner "remote-exec" {
        # inline = [
        #     "commands here"
        #     "commands here"
        #     .
        #     .
        #     .
        # ]

        # This script should already exist on the server before executing it.
        script = file("entry-script-on-ec2.sh")
    }

    # Executes commands on our local computer.
    provisioner "local-exec" {
        command = "echo ${self.public_ip} > output.txt"
    }

    tags = {
        Name = "${var.env_prefix}-server"
    }
}
