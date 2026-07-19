pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: jenkins-kaniko-git-agent
spec:
  serviceAccountName: jenkins-sa
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:v1.23.2-debug
      imagePullPolicy: Always
      command: ['sleep']
      args: ['99d']
    - name: git
      image: alpine/git:2.47.2
      imagePullPolicy: Always
      command: ['sleep']
      args: ['99d']
"""
    }
  }
  environment {
    APP_REPOSITORY       = "${params.APP_REPOSITORY ?: 'https://github.com/kgrebets/devops-django-test-app.git'}"
    GITOPS_REPOSITORY    = "${params.GITOPS_REPOSITORY ?: 'https://github.com/kgrebets/devops-lesson-9.git'}"
    GITOPS_VALUES_FILE   = "${params.GITOPS_VALUES_FILE ?: 'modules/charts/django-app/values.yaml'}"
    ECR_REPOSITORY       = "${params.ECR_REPOSITORY ?: '313588187261.dkr.ecr.eu-north-1.amazonaws.com/lesson-5-ecr'}"
    AWS_REGION           = "${params.AWS_REGION ?: 'eu-north-1'}"
    IMAGE_TAG            = "${env.BUILD_NUMBER}-${env.GIT_COMMIT?.take(7) ?: 'manual'}"
  }

  stages {
    stage('Checkout application source') {
      steps {
        container('git') {
          withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_TOKEN')]) {
            sh '''#!/bin/sh
              set -eu
              rm -rf "${WORKSPACE}/app-src"
              git clone "https://${GIT_USERNAME}:${GIT_TOKEN}@${APP_REPOSITORY#https://}" "${WORKSPACE}/app-src"
            '''
          }
        }
      }
    }

    stage('Build and push image to ECR') {
      steps {
        container('kaniko') {
          sh '''#!/busybox/sh
            set -eu
            /kaniko/executor \
              --context="${WORKSPACE}/app-src" \
              --dockerfile="${WORKSPACE}/app-src/Dockerfile" \
              --destination=${ECR_REPOSITORY}:${IMAGE_TAG} \
              --cache=true
          '''
        }
      }
    }

    stage('Update GitOps values and push main') {
      steps {
        container('git') {
          withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_TOKEN')]) {
            sh '''#!/bin/sh
              set -eu
              rm -rf "${WORKSPACE}/gitops"
              git clone "https://${GIT_USERNAME}:${GIT_TOKEN}@${GITOPS_REPOSITORY#https://}" "${WORKSPACE}/gitops"

              cd "${WORKSPACE}/gitops"
              if [ ! -f "${GITOPS_VALUES_FILE}" ]; then
                echo "values file not found: ${GITOPS_VALUES_FILE}" >&2
                exit 1
              fi

              sed -i -E "s|(^[[:space:]]*repository:[[:space:]]*).*$|\\1\\\"${ECR_REPOSITORY}\\\"|" "${GITOPS_VALUES_FILE}"
              sed -i -E "s|(^[[:space:]]*tag:[[:space:]]*).*$|\\1\\\"${IMAGE_TAG}\\\"|" "${GITOPS_VALUES_FILE}"

              git config user.name "jenkins-bot"
              git config user.email "jenkins-bot@local"

              if git diff --quiet; then
                echo "No changes in ${GITOPS_VALUES_FILE}; nothing to commit"
                exit 0
              fi

              git add "${GITOPS_VALUES_FILE}"
              git commit -m "chore(ci): update image tag to ${IMAGE_TAG}"
              git push "https://${GIT_USERNAME}:${GIT_TOKEN}@${GITOPS_REPOSITORY#https://}" HEAD:main
            '''
          }
        }
      }
    }
  }
}
