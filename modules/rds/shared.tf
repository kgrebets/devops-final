# Спільні ресурси, які використовуються як звичайною RDS, так і Aurora-кластером

# DB Subnet Group: визначає, у яких сабнетах фізично будуть запущені інстанси БД.
# Сабнети перемикаються автоматично залежно від того, чи має бути БД доступна з інтернету.
resource "aws_db_subnet_group" "default" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.publicly_accessible ? var.subnet_public_ids : var.subnet_private_ids

  tags = merge(var.tags, {
    Name = "${var.name}-subnet-group"
  })
}

# Security Group: дозволяє вхідні підключення до БД на db_port (5432 для Postgres/Aurora
# Postgres, 3306 для MySQL/Aurora MySQL) та необмежений вихідний трафік.
resource "aws_security_group" "rds" {
  name        = "${var.name}-sg"
  description = "Security group for RDS/Aurora ${var.name}"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-sg"
  })
}
