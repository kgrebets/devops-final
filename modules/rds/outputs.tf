# Спільні виводи
output "db_subnet_group_name" {
  description = "Ім'я створеної DB Subnet Group"
  value       = aws_db_subnet_group.default.name
}

output "security_group_id" {
  description = "ID Security Group, застосованої до RDS/Aurora"
  value       = aws_security_group.rds.id
}

# Виводи для звичайної RDS (порожні / null, якщо use_aurora = true)
output "rds_instance_id" {
  description = "ID звичайного RDS instance (null, якщо use_aurora = true)"
  value       = try(aws_db_instance.standard[0].id, null)
}

output "rds_instance_endpoint" {
  description = "Endpoint звичайного RDS instance (null, якщо use_aurora = true)"
  value       = try(aws_db_instance.standard[0].endpoint, null)
}

output "rds_parameter_group_name" {
  description = "Ім'я parameter group звичайної RDS (null, якщо use_aurora = true)"
  value       = try(aws_db_parameter_group.standard[0].name, null)
}

# Виводи для Aurora (порожні / null, якщо use_aurora = false)
output "aurora_cluster_id" {
  description = "ID Aurora кластера (null, якщо use_aurora = false)"
  value       = try(aws_rds_cluster.aurora[0].id, null)
}

output "aurora_cluster_endpoint" {
  description = "Writer endpoint Aurora кластера (null, якщо use_aurora = false)"
  value       = try(aws_rds_cluster.aurora[0].endpoint, null)
}

output "aurora_cluster_reader_endpoint" {
  description = "Reader endpoint Aurora кластера, балансує читання між репліками (null, якщо use_aurora = false)"
  value       = try(aws_rds_cluster.aurora[0].reader_endpoint, null)
}

output "aurora_writer_instance_id" {
  description = "ID writer-інстансу Aurora (null, якщо use_aurora = false)"
  value       = try(aws_rds_cluster_instance.aurora_writer[0].id, null)
}

output "aurora_reader_instance_ids" {
  description = "Список ID reader-інстансів Aurora (порожній список, якщо use_aurora = false)"
  value       = aws_rds_cluster_instance.aurora_readers[*].id
}

output "aurora_parameter_group_name" {
  description = "Ім'я parameter group Aurora кластера (null, якщо use_aurora = false)"
  value       = try(aws_rds_cluster_parameter_group.aurora[0].name, null)
}

# Універсальний вивід, що завжди повертає актуальний endpoint незалежно від типу БД
output "endpoint" {
  description = "Актуальний endpoint для підключення до БД (writer endpoint для Aurora, endpoint для звичайної RDS)"
  value       = var.use_aurora ? try(aws_rds_cluster.aurora[0].endpoint, null) : try(aws_db_instance.standard[0].endpoint, null)
}
