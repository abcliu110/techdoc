# Jenkins 在 K8s 构建前端并由 Windows 从 Ubuntu 取包方案

## 1. 当前环境

- Ubuntu 物理机 IP：`192.168.1.119`
- Ubuntu 用户：`jj`
- Harbor 外部地址：`192.168.1.119:30020`
- Harbor 项目：`library`
- Jenkins 部署在 RKE2 Kubernetes 集群中
- 构建产物保存目录：`/data/frontend-build-output/01-nms4pos-ui`

当前只保留这一条最终方案：

1. 本地构建 Jenkins 构建环境镜像
2. 推送到 Harbor：`192.168.1.119:30020/library/node-pnpm-ssh:1.0`
3. RKE2 节点配置 HTTP Harbor 拉取规则
4. Jenkins 通过 K8s Pod 执行前端构建
5. Jenkins 通过 SSH 私钥将产物上传到 Ubuntu
6. Windows 按需从 Ubuntu 下载产物

## 2. 本地构建并推送镜像

### 2.1 Dockerfile

```dockerfile
FROM node:20-bullseye

RUN npm install -g pnpm \
    && apt-get update \
    && apt-get install -y git openssh-client rsync \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
```

### 2.2 构建镜像

```bash
docker build -t 192.168.1.119:30020/library/node-pnpm-ssh:1.0 .
```

### 2.3 登录 Harbor

```bash
docker login 192.168.1.119:30020
```

### 2.4 推送镜像

```bash
docker push 192.168.1.119:30020/library/node-pnpm-ssh:1.0
```

### 2.5 Docker Desktop 非安全仓库配置

如果本地 `docker push` 报 TLS 或 HTTPS 错误，在 Docker Desktop 中加入：

```json
{
  "insecure-registries": [
    "192.168.1.119:30020"
  ]
}
```

## 3. RKE2 节点配置 Harbor

Harbor 当前通过 HTTP 提供 registry 接口。  
RKE2 节点必须显式配置，否则 containerd 会默认按 HTTPS 拉取并报错：

```text
http: server gave HTTP response to HTTPS client
```

### 3.1 合并后的 `/etc/rancher/rke2/registries.yaml`

如果节点原来已经有 `10.43.92.252` 配置，按下面内容合并：

```yaml
mirrors:
  "10.43.92.252":
    endpoint:
      - "http://10.43.92.252"
  "192.168.1.119:30020":
    endpoint:
      - "http://192.168.1.119:30020"

configs:
  "10.43.92.252":
    tls:
      insecure_skip_verify: true
  "192.168.1.119:30020":
    auth:
      username: admin
      password: Harbor12345
    tls:
      insecure_skip_verify: true
```

### 3.2 完整执行命令

1. 备份原文件

```bash
cp /etc/rancher/rke2/registries.yaml /etc/rancher/rke2/registries.yaml.bak.$(date +%Y%m%d%H%M%S)
```

2. 写入配置

```bash
cat > /etc/rancher/rke2/registries.yaml <<'EOF'
mirrors:
  "10.43.92.252":
    endpoint:
      - "http://10.43.92.252"
  "192.168.1.119:30020":
    endpoint:
      - "http://192.168.1.119:30020"

configs:
  "10.43.92.252":
    tls:
      insecure_skip_verify: true
  "192.168.1.119:30020":
    auth:
      username: admin
      password: Harbor12345
    tls:
      insecure_skip_verify: true
EOF
```

3. 检查内容

```bash
cat /etc/rancher/rke2/registries.yaml
```

4. 重启 RKE2

Server 节点：

```bash
sudo systemctl restart rke2-server
```

Agent 节点：

```bash
sudo systemctl restart rke2-agent
```

自动判断版：

```bash
if systemctl list-unit-files | grep -q '^rke2-server'; then
  systemctl restart rke2-server
else
  systemctl restart rke2-agent
fi
```

5. 验证节点拉镜像

```bash
crictl pull 192.168.1.119:30020/library/node-pnpm-ssh:1.0
```

## 4. Ubuntu 物理机准备

### 4.1 创建产物目录

```bash
sudo mkdir -p /data/frontend-build-output/01-nms4pos-ui
sudo chown -R jj:jj /data/frontend-build-output
```

### 4.2 确认 SSH 服务开启

```bash
sudo systemctl status ssh
```

如果未安装：

```bash
sudo apt update
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

## 5. SSH 私钥配置

### 5.1 Windows 生成私钥

```powershell
ssh-keygen -t ed25519 -C "jj@192.168.1.119" -f $env:USERPROFILE\.ssh\jenkins_ubuntu_ed25519
```

生成后的文件：

- 私钥：`C:\Users\当前用户名\.ssh\jenkins_ubuntu_ed25519`
- 公钥：`C:\Users\当前用户名\.ssh\jenkins_ubuntu_ed25519.pub`

### 5.2 查看公钥

```powershell
type $env:USERPROFILE\.ssh\jenkins_ubuntu_ed25519.pub
```

### 5.3 Ubuntu 写入 `authorized_keys`

```bash
mkdir -p /home/jj/.ssh
chmod 700 /home/jj/.ssh
touch /home/jj/.ssh/authorized_keys
chmod 600 /home/jj/.ssh/authorized_keys
echo '这里替换成公钥整行内容' >> /home/jj/.ssh/authorized_keys
chown -R jj:jj /home/jj/.ssh
```

### 5.4 测试免密登录

```powershell
ssh -i $env:USERPROFILE\.ssh\jenkins_ubuntu_ed25519 jj@192.168.1.119
```

## 6. Jenkins 凭据配置

Jenkins 中至少配置两类凭据：

### 6.1 Git 凭据

- 类型：`Username with password`
- 用途：拉取前端仓库代码
- 凭据 ID：例如 `frontend-git-credentials`

### 6.2 Ubuntu SSH 私钥凭据

- 类型：`SSH Username with private key`
- 用户名：`jj`
- 凭据 ID：`ubuntu-output-ssh-key`
- 私钥内容：`jenkins_ubuntu_ed25519` 私钥文件内容

## 7. Jenkins Pipeline 最终版

这份脚本是当前唯一保留的正确版本，可直接粘贴到 Jenkins 的 `Pipeline script` 中。

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
      GIT_URL = 'https://codeup.aliyun.com/613895a803e1c17d57a7630f/web/nms4pos-ui.git'
      GIT_CREDENTIALS_ID = 'aliyun-codeup-token'

    UBUNTU_HOST = '192.168.1.119'
    UBUNTU_USER = 'jj'
    SSH_CREDENTIALS_ID = 'ubuntu-output-ssh-key'

    PROJECT_NAME = '01-nms4pos-ui'
    BUILD_OUTPUT_DIR = 'app/pos4desktop/www'
    REMOTE_BASE = '/data/frontend-build-output'
    REMOTE_OUTPUT_DIR = "${REMOTE_BASE}/${PROJECT_NAME}/app/pos4desktop/www"
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
            pnpm -v

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

    stage('Upload To Ubuntu') {
      steps {
        container('node') {
          withCredentials([sshUserPrivateKey(
            credentialsId: "${SSH_CREDENTIALS_ID}",
            keyFileVariable: 'SSH_KEY'
          )]) {
            sh '''
              set -e

              # 清空目标目录，再重建
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

  需要确认的变量只有：
  
  - `BUILD_OUTPUT_DIR`
  - `PROJECT_NAME`

  说明：

  - `GIT_BRANCH` 已参数化，构建时直接输入分支名
  - `BUILD_OUTPUT_DIR` 需要改成真实前端产物目录，例如 `dist` 或 `build`
  - `PROJECT_NAME` 需要改成你想在 Ubuntu 上保存的目录名

## 8. Windows 从 Ubuntu 下载产物

### 8.1 scp 下载

```powershell
scp -r jj@192.168.1.119:/data/frontend-build-output/01-nms4pos-ui/build-123/* D:\frontend-output\
```

### 8.2 sftp 下载

```powershell
sftp jj@192.168.1.119
```

进入后执行：

```text
lcd D:\frontend-output
cd /data/frontend-build-output/01-nms4pos-ui/build-123
get -r *
```

## 9. 关键检查项

- `curl -I http://192.168.1.119:30020/v2/` 返回 `401 Unauthorized` 或 `200`
- 本地 `docker push 192.168.1.119:30020/library/node-pnpm-ssh:1.0` 成功
- RKE2 节点已按上面的内容合并 `/etc/rancher/rke2/registries.yaml`
- `crictl pull 192.168.1.119:30020/library/node-pnpm-ssh:1.0` 成功
- Ubuntu 的 `jj` 用户已配置公钥登录
- Jenkins 中已配置 Git 凭据和 `ubuntu-output-ssh-key`
- 前端真实输出目录与 `BUILD_OUTPUT_DIR` 一致

## 10. 最终路径

`本地构建 Docker 镜像 -> 推送 Harbor 192.168.1.119:30020 -> RKE2 节点配置 HTTP Harbor -> Jenkins K8s Pod 构建前端 -> SSH 上传到 Ubuntu 192.168.1.119 -> Windows 按需下载`
