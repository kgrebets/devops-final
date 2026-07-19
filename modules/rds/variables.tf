# Ідентифікація ресурсу
variable "name" {
  description = "Базове ім'я, яке використовується для RDS instance / Aurora cluster та повʼязаних ресурсів (subnet group, security group, parameter group)"
  type        = string
}

# Перемикач архітектури
variable "use_aurora" {
  description = "true - підіймається Aurora Cluster (writer + readers), false - створюється звичайний aws_db_instance"
  type        = bool
  default     = false
}

# --- Звичайна RDS ---
variable "engine" {
  description = "Тип рушія БД для звичайної RDS (postgres, mysql, mariadb тощо). Використовується лише коли use_aurora = false"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Версія рушія БД для звичайної RDS"
  type        = string
  default     = "17.2"
}

variable "parameter_group_family_rds" {
  description = "Family параметр-групи для звичайної RDS. Має відповідати engine/engine_version (наприклад postgres17, mysql8.0)"
  type        = string
  default     = "postgres17"
}

# --- Aurora ---
variable "engine_cluster" {
  description = "Тип рушія для Aurora кластера (aurora-postgresql, aurora-mysql). Використовується лише коли use_aurora = true"
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version_cluster" {
  description = "Версія рушія Aurora кластера"
  type        = string
  default     = "15.3"
}

variable "parameter_group_family_aurora" {
  description = "Family параметр-групи для Aurora. Має відповідати engine_cluster/engine_version_cluster (наприклад aurora-postgresql15)"
  type        = string
  default     = "aurora-postgresql15"
}

variable "aurora_replica_count" {
  description = "Кількість read-only реплік (reader instances) в Aurora кластері"
  type        = number
  default     = 1
}

# --- Спільні параметри БД ---
variable "instance_class" {
  description = "Клас інстансу БД (наприклад db.t3.micro, db.t3.medium, db.r6g.large). Використовується як для RDS instance, так і для Aurora instances"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Обсяг дискового простору у ГБ для звичайної RDS (не використовується для Aurora)"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Ім'я бази даних, яка буде створена за замовчуванням"
  type        = string
}

variable "username" {
  description = "Ім'я адміністративного користувача БД (master_username)"
  type        = string
}

variable "password" {
  description = "Пароль адміністративного користувача БД (master_password). Значення є чутливим і не повинно потрапляти у стан у відкритому вигляді"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Порт, який використовує БД та на якому Security Group дозволяє вхідні підключення (5432 для PostgreSQL/Aurora PostgreSQL, 3306 для MySQL/Aurora MySQL)"
  type        = number
  default     = 5432
}

# --- Мережа та безпека ---
variable "vpc_id" {
  description = "ID VPC, у якій буде створено Security Group та Subnet Group"
  type        = string
}

variable "subnet_private_ids" {
  description = "Список ID приватних сабнетів. Використовується у Subnet Group, коли publicly_accessible = false"
  type        = list(string)
}

variable "subnet_public_ids" {
  description = "Список ID публічних сабнетів. Використовується у Subnet Group, коли publicly_accessible = true"
  type        = list(string)
}

variable "publicly_accessible" {
  description = "true - БД буде доступна з інтернету через публічні сабнети, false - лише в межах VPC через приватні сабнети"
  type        = bool
  default     = false
}

variable "allowed_cidr_blocks" {
  description = "Список CIDR блоків, з яких дозволено вхідні підключення до БД на db_port. За замовчуванням доступ вимкнено, тож передайте лише потрібні внутрішні мережі або bastion CIDR."
  type        = list(string)
  default     = []
}

variable "multi_az" {
  description = "Увімкнути Multi-AZ деплоймент (standby-репліка в іншій AZ) для звичайної RDS. Не застосовується до Aurora, яка реплікує дані за замовчуванням"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Кількість днів зберігання автоматичних резервних копій (0 - вимкнено)"
  type        = number
  default     = 7
}

variable "skip_final_snapshot" {
  description = "true - видаляти БД без фінального снапшоту (зручно для dev/навчальних середовищ), false - обовʼязково створювати final snapshot перед видаленням (рекомендовано для production)"
  type        = bool
  default     = true
}

# --- Parameter Group ---
variable "parameters" {
  description = "Довільний набір параметрів БД (наприклад max_connections, log_statement, work_mem), які будуть застосовані через parameter group"
  type        = map(string)
  default = {
    max_connections = "200"
    log_statement   = "none"
    work_mem        = "4096"
  }
}

# --- Теги ---
variable "tags" {
  description = "Мапа тегів, які будуть застосовані до всіх ресурсів модуля"
  type        = map(string)
  default     = {}
}
