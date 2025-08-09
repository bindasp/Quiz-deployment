resource "aws_db_subnet_group" "this" {
  name       = "${var.cluster_name}-db-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "rds" {
  name        = "${var.cluster_name}-rds-sg"
  description = "Allow access to RDS from EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    description     = "Allow Postgres from EKS nodes"
    security_groups = [var.eks_node_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "postgres" {
  identifier                 = "${var.cluster_name}-postgres"
  allocated_storage          = 20
  storage_type               = "gp2"
  engine                     = "postgres"
  engine_version             = "17.4"
  instance_class             = "db.t4g.micro"
  db_name                    = "quizdb"
  username                   = var.db_username
  password                   = var.db_password
  db_subnet_group_name       = aws_db_subnet_group.this.name
  vpc_security_group_ids     = [aws_security_group.rds.id]
  skip_final_snapshot        = true
  publicly_accessible        = true
  multi_az                   = false
  auto_minor_version_upgrade = true
}
