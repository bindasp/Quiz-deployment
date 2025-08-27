data "aws_secretsmanager_random_password" "rds_password" {
  password_length    = 50
  exclude_characters = "/'\"@"
}

resource "aws_secretsmanager_secret" "rds_secret" {
  name                    = "quizapp-rds"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "rds_secret_value" {
  secret_id = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = data.aws_secretsmanager_random_password.rds_password.random_password
  })

}

