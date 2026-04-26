# Jenkins 在 K8s 构建 taro-pos 前端并由 Windows 从 Ubuntu 取包方案

## 1. 当前环境

- Ubuntu 物理机 IP：`192.168.1.119`
- Ubuntu 用户：`jj`
- Harbor 镜像：`192.168.1.119:30020/library/node-pnpm-ssh:1.0`
- Jenkins 部署在 RKE2 Kubernetes 集群中
- 构建产物保存目录：`/data/frontend-build-output/01-taro-pos`
- SSH 凭据复用：`ubuntu-output-ssh-key`

## 2. Ubuntu 物理机准备

```bash
sudo mkdir -p /data/frontend-build-output/01-taro-pos
sudo chown -R jj:jj /data/frontend-build-output
```

## 3. Jenkins Pipeline 最终版

```groovy
pipeline {
  agent {
    kubernetes {
      defaultContainer 'node'
      yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: node
    image: 192.168.1.119:30020/library/node-pnpm-ssh:1.0
    command:
    - cat
    tty: true
'''
    }
  }

  parameters {
    string(name: 'GIT_BRANCH', defaultValue: 'master', description: 'Git 分支名称')
  }

  options {
    skipDefaultCheckout(true)
    disableConcurrentBuilds()
    timeout(time: 30, unit: 'MINUTES')
    timestamps()
  }

  environment {
    GIT_URL            = 'https://codeup.aliyun.com/613895a803e1c17d57a7630f/web/taro-pos.git'
    GIT_CREDENTIALS_ID = 'aliyun-codeup-token'

    UBUNTU_HOST        = '192.168.1.119'
    UBUNTU_USER        = 'jj'
    SSH_CREDENTIALS_ID = 'ubuntu-output-ssh-key'

    BUILD_OUTPUT_DIR   = 'dist'
    REMOTE_OUTPUT_DIR  = '/data/frontend-build-output/01-taro-pos/dist'
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
            node -v
            npm -v

            npm install
            npm run build:h5

            test -d "${BUILD_OUTPUT_DIR}"
          '''
        }
      }
    }

    stage('Upload To Ubuntu') {
      steps {
        container('node') {
          withCredentials([sshUserPrivateKey(
            credentialsId: "${SSH_CREDENTIALS_ID}",
            keyFileVariable: 'SSH_KEY'
          )]) {
            sh '''
              set -e

              ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ${UBUNTU_USER}@${UBUNTU_HOST} \
                "rm -rf ${REMOTE_OUTPUT_DIR} && mkdir -p ${REMOTE_OUTPUT_DIR}"

              scp -i "$SSH_KEY" -o StrictHostKeyChecking=no -r ${BUILD_OUTPUT_DIR}/* \
                ${UBUNTU_USER}@${UBUNTU_HOST}:${REMOTE_OUTPUT_DIR}/
            '''
          }
        }
      }
    }
  }

  post {
    success {
      echo "构建成功，产物目录：${REMOTE_OUTPUT_DIR}"
    }
    failure {
      echo '构建失败，请检查 Git 拉取、前端构建命令、Harbor 镜像拉取或 SSH 上传步骤'
    }
  }
}
```

## 4. Windows 从 Ubuntu 取包

```powershell
scp -r jj@192.168.1.119:/data/frontend-build-output/01-taro-pos/dist/* D:\frontend-output\
```

## 5. 关键检查项

- Ubuntu 目录已创建且 `jj` 用户有写权限
- Jenkins 中已配置 `aliyun-codeup-token` 和 `ubuntu-output-ssh-key`
- `BUILD_OUTPUT_DIR` 与 Taro h5 实际输出目录一致（默认 `dist`，如不同请修改）
