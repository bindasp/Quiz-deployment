data "aws_secretsmanager_random_password" "rds_password" {
  password_length    = 50
  exclude_characters = "/'\"@"
}

data "aws_secretsmanager_random_password" "jwt" {
  password_length    = 50
  exclude_characters = "/'\"@"
}


resource "aws_secretsmanager_secret" "rds_secret" {
  name                    = "quizapp-rds"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret" "jwt_secret" {
  name                    = "quizapp-jwt"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "rds_secret_value" {
  secret_id = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    DB_USER     = var.db_username
    DB_PASSWORD = data.aws_secretsmanager_random_password.rds_password.random_password
  })
}

resource "aws_secretsmanager_secret_version" "jwt_secret_value" {
  secret_id = aws_secretsmanager_secret.jwt_secret.id
  secret_string = jsonencode({
    JWT_SECRET_KEY = data.aws_secretsmanager_random_password.jwt.random_password
    SECRET_KEY     = data.aws_secretsmanager_random_password.jwt.random_password
  })
}
