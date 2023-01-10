provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "name" {
  ami = "ami-0b5eea76982371e91"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public.id
  depends_on = [ aws_vpc.test ]

  tags = {
    "Name" = "test machine"
  }
}

resource "aws_vpc" "test" {
  cidr_block = "172.16.0.0/16"

  tags = {
    "Name" = "test"
  }
}



resource "aws_subnet" "public" {
  vpc_id = aws_vpc.test.id
  cidr_block = "172.16.10.0/24"


  tags = {
    "Name" = "public"
  }
}

resource "aws_security_group" "http" {
    name = "allow_http"
    description = "for test"
    vpc_id = aws_vpc.test.id
    
    dynamic "ingress" {
      for_each = [ "80", "443" ]
      content {
        description = "http_allow"
        from_port = ingress.value
        to_port = ingress.value
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"        
      }
    }
    dynamic "egress" {
      for_each = [ "80", "443" ]
      content {
        description = "allow_internet"
        from_port = egress.value
        to_port = egress.value
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"      
        }
      }
    }

