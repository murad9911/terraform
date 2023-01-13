provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "name" {
  ami = "ami-0b5eea76982371e91"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [ aws_security_group.http.id ]
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

     egress {
      description = "allow_internet"
      from_port = 0
      to_port = 0
      cidr_blocks = ["0.0.0.0/0"]
      protocol = "-1"      
      }
    }

  resource "aws_db_instance" "default" {
      allocated_storage    = 10
      db_name              = "mydb"
      engine               = "mysql"
      engine_version       = "5.7"
      instance_class       = "db.t3.micro"
      username             = "admin"
      password             = random_password.dbpass.result
      parameter_group_name = "default.mysql5.7"
      skip_final_snapshot  = true
      identifier = "test"
}

  resource "random_password" "dbpass" {
      length = 20
      special = false
  }

  resource "aws_secretsmanager_secret" "dbpass" {
      name = "dbpass"
  }   
  

  resource "aws_secretsmanager_secret_version" "dbpass" {
    secret_id = aws_secretsmanager_secret.dbpass.id
     secret_string = jsonencode(
    {
      username = "${var.dbuser}"
      password = aws_db_instance.default.password
      engine   = "mysql"
      host     = aws_db_instance.default.endpoint
    }
  )
  }

  variable "dbuser" {
      type =string
      default = "master"
  }
