# Terraform-модуль `rds`

Універсальний модуль для розгортання бази даних AWS RDS, який підтримує два режими
роботи через єдиний прапор `use_aurora`:

- `use_aurora = false` -> звичайний `aws_db_instance` (PostgreSQL, MySQL тощо);
- `use_aurora = true` -> Amazon Aurora Cluster (writer + read-репліки).

В обох випадках модуль автоматично створює:

- `aws_db_subnet_group` - group сабнетів (публічні або приватні, залежно від
  `publicly_accessible`);
- `aws_security_group` - дозволяє вхідні підключення на `db_port`;
- Parameter Group (`aws_db_parameter_group` для RDS або
  `aws_rds_cluster_parameter_group` для Aurora) з базовими параметрами
  `max_connections`, `log_statement`, `work_mem` (та будь-якими іншими через `parameters`).

## Структура

```text
modules/rds/
├── rds.tf         # aws_db_instance + parameter group для звичайної RDS
├── aurora.tf       # aws_rds_cluster + writer/reader instances + parameter group для Aurora
├── shared.tf       # aws_db_subnet_group + aws_security_group (спільні для обох режимів)
├── variables.tf    # усі вхідні змінні модуля
└── outputs.tf      # виводи (endpoint, id, subnet group, security group тощо)
```

## Приклад використання

### Звичайна RDS (PostgreSQL)

```hcl
module "rds" {
  source = "./modules/rds"

  name       = "myapp-db"
  use_aurora = false

  # --- RDS-only ---
  engine                     = "postgres"
  engine_version             = "17.2"
  parameter_group_family_rds = "postgres17"

  # --- Common ---
  instance_class    = "db.t3.medium"
  allocated_storage = 20

  db_name  = "myapp"
  username = "postgres"
  password = var.db_password # передавайте через -var/TF_VAR_, не хардкодьте в коді

  vpc_id              = module.vpc.vpc_id
  subnet_private_ids  = module.vpc.private_subnet_ids
  subnet_public_ids   = module.vpc.public_subnet_ids
  publicly_accessible = false
  multi_az            = true

  backup_retention_period = 7

  parameters = {
    max_connections = "200"
    log_statement   = "none"
    work_mem        = "4096"
  }

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

### Aurora Cluster (PostgreSQL-сумісний)

Щоб перейти на Aurora, достатньо змінити `use_aurora` на `true` та заповнити
Aurora-специфічні змінні - решта параметрів (мережа, БД, теги) лишаються тими ж:

```hcl
module "rds" {
  source = "./modules/rds"

  name       = "myapp-db"
  use_aurora = true

  # --- Aurora-only ---
  engine_cluster                = "aurora-postgresql"
  engine_version_cluster        = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"
  aurora_replica_count          = 2

  # --- Common ---
  instance_class = "db.r6g.large"

  db_name  = "myapp"
  username = "postgres"
  password = var.db_password

  vpc_id              = module.vpc.vpc_id
  subnet_private_ids  = module.vpc.private_subnet_ids
  subnet_public_ids   = module.vpc.public_subnet_ids
  publicly_accessible = false

  backup_retention_period = 7

  tags = {
    Environment = "prod"
    Project     = "myapp"
  }
}
```

## Змінні

| Змінна                          | Тип            | Дефолт                                                              | Опис                                                                                       |
| -------------------------------- | -------------- | -------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| `name`                            | `string`       | -                                                                    | Базове ім'я для instance/cluster та повʼязаних ресурсів                                      |
| `use_aurora`                      | `bool`         | `false`                                                              | `true` - Aurora Cluster, `false` - звичайна RDS instance                                     |
| `engine`                          | `string`       | `"postgres"`                                                         | Рушій для звичайної RDS (`postgres`, `mysql`, ...)                                            |
| `engine_version`                  | `string`       | `"17.2"`                                                             | Версія рушія для звичайної RDS                                                                |
| `parameter_group_family_rds`      | `string`       | `"postgres17"`                                                       | Family parameter group для звичайної RDS                                                     |
| `engine_cluster`                  | `string`       | `"aurora-postgresql"`                                                | Рушій Aurora кластера (`aurora-postgresql`, `aurora-mysql`)                                   |
| `engine_version_cluster`          | `string`       | `"15.3"`                                                             | Версія рушія Aurora кластера                                                                  |
| `parameter_group_family_aurora`   | `string`       | `"aurora-postgresql15"`                                              | Family parameter group для Aurora                                                             |
| `aurora_replica_count`            | `number`       | `1`                                                                  | Кількість read-only реплік Aurora                                                             |
| `instance_class`                  | `string`       | `"db.t3.micro"`                                                      | Клас інстансу (для RDS instance та Aurora writer/readers)                                    |
| `allocated_storage`               | `number`       | `20`                                                                 | Обсяг диску у ГБ (лише для звичайної RDS)                                                    |
| `db_name`                         | `string`       | -                                                                    | Ім'я бази даних за замовчуванням                                                              |
| `username`                        | `string`       | -                                                                    | Ім'я адміністративного користувача                                                            |
| `password`                        | `string`       | -                                                                    | Пароль адміністративного користувача (`sensitive`)                                            |
| `db_port`                         | `number`       | `5432`                                                               | Порт БД / порт, що відкривається в Security Group                                            |
| `vpc_id`                          | `string`       | -                                                                    | ID VPC                                                                                        |
| `subnet_private_ids`              | `list(string)` | -                                                                    | Приватні сабнети (використовуються, якщо `publicly_accessible = false`)                       |
| `subnet_public_ids`               | `list(string)` | -                                                                    | Публічні сабнети (використовуються, якщо `publicly_accessible = true`)                        |
| `publicly_accessible`             | `bool`         | `false`                                                              | Доступність БД з інтернету                                                                    |
| `allowed_cidr_blocks`             | `list(string)` | `[]`                                                                  | CIDR-блоки, яким дозволено підключення до `db_port` (передавайте лише внутрішні або bastion CIDR) |
| `multi_az`                        | `bool`         | `false`                                                              | Multi-AZ для звичайної RDS                                                                    |
| `backup_retention_period`         | `number`       | `7`                                                                  | Днів зберігання автоматичних бекапів                                                          |
| `skip_final_snapshot`             | `bool`         | `true`                                                               | `false`, щоб створювати final snapshot перед видаленням (рекомендовано для production)         |
| `parameters`                      | `map(string)`  | `{max_connections="200", log_statement="none", work_mem="4096"}`     | Довільні параметри БД для parameter group                                                     |
| `tags`                            | `map(string)`  | `{}`                                                                 | Теги для всіх ресурсів модуля                                                                  |

## Як змінити тип БД / engine / клас інстансу

- **Тип БД (RDS <-> Aurora)**: змініть лише `use_aurora` (`true`/`false`). Усі інші
  спільні змінні (мережа, `db_name`, `username`, `password`, теги) лишаються без змін.
- **Engine**: для звичайної RDS - змінна `engine` (`postgres`, `mysql`, `mariadb`, ...);
  для Aurora - `engine_cluster` (`aurora-postgresql`, `aurora-mysql`). Не забудьте
  синхронно оновити `engine_version`/`engine_version_cluster` та відповідну
  `parameter_group_family_rds`/`parameter_group_family_aurora`, оскільки вона повинна
  точно відповідати обраній версії.
- **Клас інстансу**: змінна `instance_class` (наприклад `db.t3.micro` для dev,
  `db.r6g.large` для production Aurora).
- **MySQL замість PostgreSQL**: встановіть `engine = "mysql"` (або
  `engine_cluster = "aurora-mysql"`), відповідну версію, `parameter_group_family_*`
  (наприклад `mysql8.0`) та `db_port = 3306`.
- **Кількість Aurora-реплік**: змінна `aurora_replica_count`.
- **Публічний/приватний доступ**: змінна `publicly_accessible` автоматично перемикає
  Subnet Group між `subnet_public_ids` та `subnet_private_ids`.

## Виводи

| Вивід                            | Опис                                                                 |
| ---------------------------------- | ----------------------------------------------------------------------- |
| `endpoint`                         | Актуальний endpoint для підключення (Aurora writer або RDS endpoint)     |
| `db_subnet_group_name`             | Ім'я створеної DB Subnet Group                                          |
| `security_group_id`                | ID Security Group                                                       |
| `rds_instance_id` / `rds_instance_endpoint` / `rds_parameter_group_name` | Виводи звичайної RDS (`null`, якщо `use_aurora = true`)  |
| `aurora_cluster_id` / `aurora_cluster_endpoint` / `aurora_cluster_reader_endpoint` | Виводи Aurora кластера (`null`, якщо `use_aurora = false`) |
| `aurora_writer_instance_id` / `aurora_reader_instance_ids` / `aurora_parameter_group_name` | Виводи Aurora instances/parameter group |
