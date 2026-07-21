resource "helm_release" "argo_cd" {
  name             = var.name
  namespace        = var.namespace
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  create_namespace = true

  values = [
    templatefile("${path.module}/values.yaml", {
      namespace                  = var.namespace
      applications_chart_version = var.applications_chart_version
      app_name                   = var.app_name
      app_namespace              = var.app_namespace
      argocd_project             = var.argocd_project
      gitops_repo_url            = var.gitops_repo_url
      gitops_repo_branch         = var.gitops_repo_branch
      gitops_chart_path          = var.gitops_chart_path
      repo_username              = var.repo_username
      repo_password              = var.repo_password
      postgres_host              = var.postgres_host
      postgres_port              = var.postgres_port
      postgres_user              = var.postgres_user
      postgres_db                = var.postgres_db
      postgres_password          = var.postgres_password
      django_debug               = var.django_debug
      allowed_hosts              = var.allowed_hosts
    })
  ]
}

resource "helm_release" "argo_apps" {
  name             = "${var.name}-apps"
  namespace        = var.namespace
  chart            = "${path.module}/charts"
  create_namespace = false

  values = [
    templatefile("${path.module}/values.yaml", {
      namespace                  = var.namespace
      applications_chart_version = var.applications_chart_version
      app_name                   = var.app_name
      app_namespace              = var.app_namespace
      argocd_project             = var.argocd_project
      gitops_repo_url            = var.gitops_repo_url
      gitops_repo_branch         = var.gitops_repo_branch
      gitops_chart_path          = var.gitops_chart_path
      repo_username              = var.repo_username
      repo_password              = var.repo_password
      postgres_host              = var.postgres_host
      postgres_port              = var.postgres_port
      postgres_user              = var.postgres_user
      postgres_db                = var.postgres_db
      postgres_password          = var.postgres_password
      django_debug               = var.django_debug
      allowed_hosts              = var.allowed_hosts
    })
  ]

  depends_on = [helm_release.argo_cd]
}
