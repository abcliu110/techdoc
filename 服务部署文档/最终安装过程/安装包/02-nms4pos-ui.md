  pipeline {
    agent {
      kubernetes {
        defaultContainer 'node'
      yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: agent
    project: nms4pos-ui
spec:
  serviceAccountName: jenkins
  securityContext:
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000

  containers:
  - name: node
    image: maven:3.9.11-eclipse-temurin-21
    imagePullPolicy: IfNotPresent
    command:
    - cat
    tty: true
    securityContext:
      runAsUser: 0
    volumeMounts:
    - name: package-output
      mountPath: /package-output
  volumes:
  - name: package-output
    hostPath:
      path: /var/lib/jenkins-package-output
      type: DirectoryOrCreate
'''
      }
    }

    parameters {
      string(name: 'GIT_BRANCH', defaultValue: 'member-test', description: 'Git 分支名称')
    }
  
    options {
      skipDefaultCheckout(true)
      disableConcurrentBuilds()
    timeout(time: 30, unit: 'MINUTES')
  }

    environment {
      GIT_URL = 'https://codeup.aliyun.com/613895a803e1c17d57a7630f/web/nms4pos-ui.git'
      GIT_CREDENTIALS_ID = 'aliyun-codeup-token'

    PROJECT_NAME = '01-nms4pos-ui'
    BUILD_OUTPUT_DIR = 'app/pos4desktop/www'
    OUTPUT_DIR = "/package-output/frontend/${PROJECT_NAME}/app/pos4desktop/www"
  }

  stages {
    stage('Checkout') {
      steps {
        container('node') {
          deleteDir()
          withCredentials([usernamePassword(
            credentialsId: "${GIT_CREDENTIALS_ID}",
            usernameVariable: 'GIT_USERNAME',
            passwordVariable: 'GIT_PASSWORD'
          )]) {
            sh '''
              set -e

              cat > /tmp/git-askpass.sh <<'EOF'
#!/bin/sh
case "$1" in
  *Username*) printf '%s\n' "$GIT_USERNAME" ;;
  *Password*) printf '%s\n' "$GIT_PASSWORD" ;;
  *) printf '\n' ;;
esac
EOF
              chmod 700 /tmp/git-askpass.sh
              export GIT_ASKPASS=/tmp/git-askpass.sh
              export GIT_TERMINAL_PROMPT=0

              git clone --depth 1 --branch "${GIT_BRANCH}" "${GIT_URL}" .

              rm -f /tmp/git-askpass.sh
            '''
          }
        }
      }
    }

    stage('Build Frontend') {
      steps {
        container('node') {
          sh '''
            set -e
            apt-get update
            apt-get install -y --no-install-recommends nodejs npm git ca-certificates
            node -v
            npm -v
            npm install --global pnpm@9.15.9

            # 注入 pnpm.overrides 强制所有包使用 webpack@5.78.0
            # webpack 5.93+ 收紧 ProgressPlugin schema，Taro 3.6.x 不兼容
            node -e "const fs=require('fs');const p=JSON.parse(fs.readFileSync('package.json','utf8'));p.pnpm=p.pnpm||{};p.pnpm.overrides=p.pnpm.overrides||{};p.pnpm.overrides['webpack']='5.78.0';fs.writeFileSync('package.json',JSON.stringify(p,null,2));"
            pnpm install --no-frozen-lockfile
            pnpm run desktop:build
            pnpm run shell:build

            test -d "${BUILD_OUTPUT_DIR}"
          '''
        }
      }
    }

    stage('Publish package output') {
      steps {
        container('node') {
          sh '''
            set -eu
            rm -rf "${OUTPUT_DIR}"
            mkdir -p "${OUTPUT_DIR}"
            cp -R "${BUILD_OUTPUT_DIR}/." "${OUTPUT_DIR}/"
          '''
        }
      }
    }
  }

  post {
    success {
      echo "构建成功，产物目录：${OUTPUT_DIR}"
      build job: 'pos-install-package/03-nms4pos', wait: false
    }
    failure {
      echo '构建失败，请检查 Git 拉取、前端构建命令、Harbor 镜像拉取或 SSH 上传步骤'
    }
  }
}
