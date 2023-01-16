provider "aws" {
  region = "us-east-1"
}

resource "random_password" "dbpassword" {
      length = 20
      special = true
      override_special = "@_"
  }

  resource "aws_secretsmanager_secret" "dbpassword" {
      name = "dbpassword"
      recovery_window_in_days = 0
  }   
  

  resource "aws_secretsmanager_secret_version" "dbpassword" {
    secret_id = aws_secretsmanager_secret.dbpassword.id
     secret_string = jsonencode(
    {
      username = "${var.dbuser}"
      password = random_password.dbpassword.result
      engine   = "mysql"
    }
  )
  }

  variable "dbuser" {
      type =string
      default = "master"
  }

data "aws_secretsmanager_secret_version" "dbpassword" {
  secret_id = aws_secretsmanager_secret.dbpassword.id
  depends_on = [aws_secretsmanager_secret_version.dbpassword]
}

  output "dball" {
    value = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.dbpassword.secret_string))
  }