# Final DevOps Project (Terraform + AWS + EKS + CI/CD + GitOps)

This repository is focused on infrastructure and platform automation. The demo Django application source code is stored in a separate repository.

## Requirement Coverage

- Infrastructure in AWS via Terraform: `VPC`, `EKS`, `RDS`, `ECR`, `Jenkins`, `Argo CD`.
- Monitoring stack: `Prometheus` + `Grafana` deployed by Argo CD to namespace `monitoring`.
- Autoscaling: Django Helm chart includes `HorizontalPodAutoscaler` (`autoscaling/v2`).
- Security baseline: VPC isolation, IAM roles (EKS, IRSA for Jenkins), Security Groups (RDS).
- Documentation and operation commands: included below.
- Application source repository is external and consumed by Jenkins/Argo CD configuration.

## Project Structure

```text
.
├── main.tf
├── backend.tf
├── outputs.tf
├── Jenkinsfile
├── modules/
│   ├── s3-backend/
│   ├── vpc/
│   ├── ecr/
│   ├── eks/
│   ├── rds/
│   ├── jenkins/
│   ├── argo_cd/
│   │   └── charts/
│   └── charts/
│       └── django-app/
```

## What Is Deployed

1. Terraform backend resources via `modules/s3-backend` (S3 + DynamoDB).
2. Networking via `modules/vpc`.
3. Container registry via `modules/ecr`.
4. Kubernetes platform via `modules/eks` (+ EBS CSI add-on).
5. Database via `modules/rds` (standard RDS or Aurora mode).
6. Jenkins via `modules/jenkins` (Helm, persistent storage, IRSA for ECR push).
7. Argo CD via `modules/argo_cd` (Helm + app-of-apps chart).
8. Monitoring via Argo CD app:
   - Chart: `kube-prometheus-stack`
   - Namespace: `monitoring`
   - Includes Prometheus + Grafana
   - Grafana service override: `grafana` (for required port-forward command)

## Deploy

```bash
terraform init
terraform plan
terraform apply
```

## Required Validation Commands

After infrastructure is up:

```bash
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring
```

## Access Checks

```bash
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
kubectl port-forward svc/argocd-server 8081:443 -n argocd
kubectl port-forward svc/grafana 3000:80 -n monitoring
```

Then open:

- Jenkins: `http://localhost:8080`
- Argo CD: `https://localhost:8081`
- Grafana: `http://localhost:3000`

## Useful Commands

Update kubeconfig:

```bash
aws eks update-kubeconfig --region eu-north-1 --name lesson-7-eks
kubectl get nodes
```

Get Jenkins admin password:

```bash
kubectl exec -n jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password
```

Get Argo CD initial admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d
```

Validate Argo CD module changes (`application.yaml` and `values.yaml`):

```bash
# 1) Validate Terraform and templatefile rendering path for module.argo_cd
terraform init -backend=false
terraform validate
terraform plan -target=module.argo_cd

# 2) Validate local Argo applications chart template syntax
helm lint modules/argo_cd/charts
helm template argo-apps modules/argo_cd/charts -f modules/argo_cd/charts/values.yaml > NUL
```

## Important Notes

- Set real credentials/secrets before production use:
  - `module.jenkins.github_token`
  - `module.argo_cd.repo_password`
  - `module.rds.password`
- Demo app source is expected in a separate Git repository referenced by Jenkins and Argo CD variables.

## Cleanup

Always remove cloud resources after validation:

```bash
terraform destroy
```

Warning about backend resources: destroying full infrastructure can remove the S3 bucket and DynamoDB table used for Terraform state/locking. If that happens, recreate/import backend resources before next `terraform init` with remote backend.
