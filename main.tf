terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.51"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  # Fetch a fresh token per request instead of reusing the one resolved at plan
  # time (aws_eks_cluster_auth tokens expire after ~15 min, which otherwise
  # causes "context deadline exceeded" once cluster/node group/addon
  # provisioning eats into that window before Jenkins installs).
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", "eu-north-1"]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", "eu-north-1"]
    }
  }
}

#Підключаємо модуль S3 та DynamoDB
module "s3_backend" {
  source = "./modules/s3-backend"

  bucket_name = "terraform-state-devops-homework-5-1"
  table_name  = "terraform-locks"
}


# Підключаємо модуль VPC
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  vpc_name           = "lesson-5-vpc"
}

# Підключаємо модуль ECR
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-5-ecr"
  scan_on_push = true
}

# Підключаємо модуль EKS
module "eks" {
  source = "./modules/eks"

  cluster_name    = "lesson-7-eks"
  cluster_version = "1.36"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  node_group_name = "lesson-7-nodes"

  instance_types = ["t3.small"]

  desired_size = 2
  min_size     = 1
  max_size     = 6
}

# Підключаємо модуль RDS (звичайна RDS instance або Aurora Cluster, залежно від use_aurora)
module "rds" {
  source = "./modules/rds"

  name = "lesson-10-db"

  # Змініть на true, щоб замість звичайної RDS підняти Aurora Cluster (writer + readers)
  use_aurora = false

  # --- RDS-only (використовується, коли use_aurora = false) ---
  engine                     = "postgres"
  engine_version             = "17.10"
  parameter_group_family_rds = "postgres17"

  # --- Aurora-only (використовується, коли use_aurora = true) ---
  engine_cluster                = "aurora-postgresql"
  engine_version_cluster        = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"
  aurora_replica_count          = 1

  # --- Спільні параметри ---
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "mydb"
  username = "postgres"
  password = "ChangeMe123AWS!"

  vpc_id              = module.vpc.vpc_id
  subnet_private_ids  = module.vpc.private_subnet_ids
  subnet_public_ids   = module.vpc.public_subnet_ids
  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 7
  skip_final_snapshot     = true

  parameters = {
    max_connections = "200"
    log_statement   = "none"
    work_mem        = "4096"
  }

  tags = {
    Environment = "dev"
    Project     = "lesson-10"
  }
}

# # Підключаємо модуль Jenkins (розгортається через Helm на EKS)
module "jenkins" {
  source = "./modules/jenkins"

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url

  namespace          = "jenkins"
  release_name       = "jenkins"
  admin_user         = "admin"
  admin_password     = "admin123"
  ecr_repository_url = module.ecr.repository_url
  aws_region         = "eu-north-1"

  # Update these placeholders to your GitHub account/repositories.
  github_username       = "kgrebets"
  github_token          = ""
  infra_repository_url  = "https://github.com/kgrebets/devops-lesson-9.git"
  app_repository_url    = "https://github.com/kgrebets/devops-django-test-app.git"
  gitops_repository_url = "https://github.com/kgrebets/devops-lesson-9.git"
  gitops_values_file    = "modules/charts/django-app/values.yaml"

  depends_on = [module.eks]
}

# # Підключаємо модуль Argo CD (розгортається через Helm на EKS)
module "argo_cd" {
  source = "./modules/argo_cd"

  name      = "argo-cd"
  namespace = "argocd"

  # Tracks the same repo where Jenkins updates Helm values for GitOps sync.
  gitops_repo_url    = "https://github.com/kgrebets/devops-lesson-9.git"
  gitops_repo_branch = "main"
  gitops_chart_path  = "modules/charts/django-app"

  app_name      = "django-app"
  app_namespace = "default"

  # Repo credentials are required for private repositories.
  repo_username = "kgrebets"
  repo_password = ""

  depends_on = [module.eks]
}
