provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "demo-server" {
    ami = "ami-0c7217cdde317cfec"
    instance_type = "t2.micro"
    key_name = "ec2-instance"
    vpc_security_group_ids = [ aws_security_group.demo-sg.id ]
    subnet_id = aws_subnet.demo-subnet-01.id
for_each = toset( [ "jenkins-master", "jenkins-slave", "ansible" ] )
   tags = {
     Name = "${each.key}"
   }
}

resource "aws_security_group" "demo-sg" {
    name = "demo-ig"
    description = "SSH-access"
    vpc_id = aws_vpc.demo-vpc.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    tags = {
      name = "ssh-port"
    }
}

resource "aws_vpc" "demo-vpc" {
    cidr_block = "10.1.0.0/16"
    tags       = {
        name = "demo-vpc"
    }
}

resource "aws_subnet" "demo-subnet-01" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
  tags = {
    name = "subnet-1"
  }
}

resource "aws_subnet" "demo-subnet-02" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1b"
  tags = {
    name = "subnet-2"
  }
}

resource "aws_internet_gateway" "demo-igw" {
    vpc_id = aws_vpc.demo-vpc.id
    tags = {
        name = "internet-gateway"
    }
}

resource "aws_route_table" "demo-route" {
    vpc_id = aws_vpc.demo-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.demo-igw.id
    }
}

resource "aws_route_table_association" "demo-association-01" {
    subnet_id = aws_subnet.demo-subnet-01.id
    route_table_id = aws_route_table.demo-route.id    
}

resource "aws_route_table_association" "demo-association-02" {
    subnet_id = aws_subnet.demo-subnet-02.id
    route_table_id = aws_route_table.demo-route.id    
}