# Namespace dedicated to Jenkins
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace
  }
}

# StorageClass backed by the EBS CSI driver, used for the Jenkins home PVC
resource "kubernetes_storage_class" "ebs_sc" {
  metadata {
    name = "ebs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type = "gp3"
  }
}

# IAM role assumed by Jenkins Kubernetes agents (Kaniko/Git pods) via IRSA.
resource "aws_iam_role" "jenkins_kaniko_role" {
  name = "${var.cluster_name}-jenkins-kaniko-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = var.oidc_provider_arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:${var.namespace}:${var.agent_service_account_name}"
            "${replace(var.oidc_provider_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "jenkins_ecr_policy" {
  name = "${var.cluster_name}-jenkins-kaniko-ecr-policy"
  role = aws_iam_role.jenkins_kaniko_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "kubernetes_service_account" "jenkins_sa" {
  metadata {
    name      = var.agent_service_account_name
    namespace = kubernetes_namespace.jenkins.metadata[0].name

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.jenkins_kaniko_role.arn
    }
  }

  depends_on = [kubernetes_namespace.jenkins]
}

# Deploy Jenkins via the official Helm chart (charts.jenkins.io)
resource "helm_release" "jenkins" {
  name       = var.release_name
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = var.chart_version
  namespace  = kubernetes_namespace.jenkins.metadata[0].name

  # Basic login/password authentication (admin/admin123)
  set {
    name  = "controller.admin.username"
    value = var.admin_user
  }

  set_sensitive {
    name  = "controller.admin.password"
    value = var.admin_password
  }

  set {
    name  = "controller.serviceType"
    value = var.service_type
  }

  set {
    name  = "controller.servicePort"
    value = "80"
  }

  set {
    name  = "controller.image.tag"
    value = "2.504.1-jdk17"
  }

  set {
    name  = "controller.service.targetPort"
    value = "8080"
  }

  # Keep plugin set compatible with bundled Jenkins core.
  set {
    name  = "controller.installLatestPlugins"
    value = "false"
  }

  # Do not auto-upgrade dependencies of specified plugins.
  set {
    name  = "controller.installLatestSpecifiedPlugins"
    value = "true"
  }

  # Provision the Jenkins home volume via the EBS CSI driver
  set {
    name  = "persistence.storageClass"
    value = kubernetes_storage_class.ebs_sc.metadata[0].name
  }

  values = [
    templatefile("${path.module}/values.yaml", {
      service_account_name  = var.agent_service_account_name
      github_username       = var.github_username
      github_token          = var.github_token
      infra_repository_url  = var.infra_repository_url
      pipeline_job_name     = var.pipeline_job_name
      app_repository_url    = var.app_repository_url
      gitops_repository_url = var.gitops_repository_url
      gitops_values_file    = var.gitops_values_file
      ecr_repository_url    = var.ecr_repository_url
      aws_region            = var.aws_region
    })
  ]

  depends_on = [
    kubernetes_storage_class.ebs_sc,
    kubernetes_service_account.jenkins_sa,
    aws_iam_role_policy.jenkins_ecr_policy
  ]
}

# Read the Kubernetes Service created by the Helm release to expose the URL as output.
data "kubernetes_service" "jenkins" {
  metadata {
    name      = var.release_name
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }

  depends_on = [helm_release.jenkins]
}

