# Creating VPC
resource "aws_vpc" "dev" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc-1"
  }
}

# Creating Internet Gateway and Attaching to VPC
resource "aws_internet_gateway" "dev" {
  vpc_id = aws_vpc.dev.id  # Corrected
  tags = {
    Name = "igw-1"
  }
}

# Creating Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.dev.id  # Corrected
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "public-subnet-1"
  }
}

# Creating Private Subnet
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.dev.id  # Corrected
  cidr_block              = "10.0.8.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1b"
  tags = {
    Name = "private-subnet-1"
  }
}

# Creating Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.dev.id  # Corrected
  tags = {
    Name = "public-route-table"
  }

  route {
    gateway_id = aws_internet_gateway.dev.id  # Corrected
    cidr_block = "0.0.0.0/0"
  }
}

# Associating Public Subnet with Public Route Table
resource "aws_route_table_association" "public_association" {
  route_table_id = aws_route_table.public.id  # Corrected
  subnet_id      = aws_subnet.public.id  # Corrected
}

# Create Security Group
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow HTTP and SSH access"
  vpc_id      = aws_vpc.dev.id  # Corrected

  # Inbound Rules
  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Rules
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev_sg"
  }
}


#creating ec2 instance in the public subnet
resource "aws_instance" "dev" {
    ami = var.ami
    key_name = var.key_name
    instance_type = var.instance_type
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.allow_tls.id]
    tags = {
      Name = "new-instance"
    }
  

}