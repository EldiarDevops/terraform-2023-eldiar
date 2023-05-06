resource "aws_vpc" "vpceldiar" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpceldiar.id
  tags = {
    Name = var.igw_name
  }
}

resource "aws_subnet" "public_subnet_eldiar" {
  vpc_id     = aws_vpc.vpceldiar.id
  cidr_block = var.public_cidr_block
  availability_zone = var.az1
  map_public_ip_on_launch = true 

  tags = {
    Name = var.public_subnet_name
  }
}


resource "aws_subnet" "private_subnet_eldiar" {
  vpc_id     = aws_vpc.vpceldiar.id
  cidr_block = var.private_cidr_block
  availability_zone = var.az2
  map_public_ip_on_launch = false

  tags = {
    Name = var.private_subnet_name
  }
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpceldiar.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "eldiar-public-route-table"
  }
}


resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet_eldiar.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "nat_eip" {
  vpc = true

  tags = {
    Name = "my-nat-eip"
  }
}


resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_eldiar.id

  tags = {
    Name = "eldiar-nat-gateway"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpceldiar.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "eldiar-private-route-table"
  }
}


resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet_eldiar.id
  route_table_id = aws_route_table.private_route_table.id
}




resource "aws_security_group" "my_security_group" {
  name = "eldiar-security-group"
  vpc_id = aws_vpc.vpceldiar.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


ingress {
    description      = "TLS from VPC"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }



  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

    ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
  
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet_eldiar.id
  availability_zone = var.availability_zone_web
  key_name = aws_key_pair.deployer.key_name
  user_data = file("wordpress.sh")
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  
}


resource "aws_instance" "mysql" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_subnet_eldiar.id
  availability_zone = var.availability_zone_mysql
  key_name = aws_key_pair.deployer.key_name
  user_data = file("mysql.sh")
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  
}

