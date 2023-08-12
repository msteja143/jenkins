resource "aws_vpc" "teja" {
    cidr_block = var.vpc_cidr
    tags = {
      Name = var.vpc_tags
    }
}

resource "aws_subnet" "sub1" {
  count = length(var.subnet_cidr)
  cidr_block = cidrsubnet(var.vpc_cidr,8,count.index)
  availability_zone = var.availability_zone[count.index]
  vpc_id = aws_vpc.teja.id
  tags = {
       Name = var.subnet_tags[count.index]
        }
  
  }

resource "aws_internet_gateway" "card" {
  vpc_id = aws_vpc.teja.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.teja.id
  tags = {
    Name = "routes"
  }
}

resource "aws_route" "routee" {
  route_table_id = aws_route_table.example.id
   destination_cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.card.id

    } 

resource "aws_route_table_association" "assosate" {
  count = length(var.web_subnet_indexes)
  subnet_id = aws_subnet.sub1[0].id
  route_table_id = aws_route_table.example.id

}

resource "aws_security_group" "secra" {
   name = "openhttp" 
   description = "open http and ssh"
   vpc_id = aws_vpc.teja.id
}


resource "aws_security_group_rule" "rular" {
  type = "ingress"
  from_port = 80
  to_port   = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.secra.id
}

resource "aws_security_group_rule" "rular2" {
  
  type = "ingress"
  from_port = 22
  to_port =   22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.secra.id

}


resource "aws_security_group_rule" "allow_all" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.secra.id
}


resource "aws_instance" "ec1" {
    ami = "ami-0f8e81a3da6e2510a"
    instance_type = "t2.micro"
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.secra.id]
    subnet_id = aws_subnet.sub1[0].id
    key_name = "msindian"
    tags = {
      Name = "bhoola"
  }
}
 
