# Jenkins 在 K8s 通过 SSH 清理 Ubuntu 构建产物目录方案

## 1. 适用场景

- Jenkins 运行在 K8s 集群中
- 需要清理的是 Ubuntu 物理机 `192.168.1.119` 上的目录
- 目标目录不是挂载到 Jenkins Pod 的本地卷
- 需要复用现有 SSH 私钥凭据 `ubuntu-output-ssh-key`

## 2. 结论

这类清理任务不能直接在 Jenkins Freestyle 的 Shell 中对 `/data/...` 执行 `rm -rf`，因为那样删除的是 Jenkins Pod 容器内的路径，不是 Ubuntu 物理机上的真实目录。

正确做法是：

1. Jenkins 在 K8s 中启动一个临时 Pod
2. 通过 Jenkins 凭据注入 SSH 私钥
3. Pod 内执行 `ssh` 登录 `192.168.1.119`
4. 在远端物理机上创建、清理并重建目标目录

## 3. 需要清理的目录

当前确认需要清理并重建的目录如下：

- 前端输出目录：`/data/frontend-build-output/01-nms4pos-ui`
- 后端输出目录：`/data/backend-build-output/01-nms4pos-java`

根目录如果不存在则创建：

- `/data/frontend-build-output`
- `/data/backend-build-output`

目录权限统一设置为：

- 用户：`jj`
- 用户组：`jj`

## 4. Jenkins 凭据要求

Jenkins 中需要存在以下凭据：

- 凭据 ID：`ubuntu-output-ssh-key`
- 类型：`SSH Username with private key`
- 用户名：`jj`

该私钥必须能够直接登录：

```bash
ssh jj@192.168.1.119
```

此外，`jj` 用户需要能够在 `192.168.1.119` 上执行本文中的 `sudo` 命令。

## 5. 推荐方案：使用 K8s Pipeline Job

推荐新建一个专门的 Jenkins Pipeline Job，例如：`00-clean`。

完整脚本如下：

```groovy
pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: shell
    image: maven:3.9-eclipse-temurin-21
    command:
    - cat
    tty: true
"""
    }
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
    disableConcurrentBuilds()
    timeout(time: 10, unit: 'MINUTES')
    timestamps()
  }

  environment {
    UBUNTU_HOST        = '192.168.1.119'
    UBUNTU_USER        = 'jj'
    SSH_CREDENTIALS_ID = 'ubuntu-output-ssh-key'
  }

  stages {
    stage('安装 SSH 客户端') {
      steps {
        container('shell') {
          sh '''
            set -e
            apt-get update
            apt-get install -y openssh-client
          '''
        }
      }
    }

    stage('清理物理机目录') {
      steps {
        container('shell') {
          withCredentials([sshUserPrivateKey(
            credentialsId: "${SSH_CREDENTIALS_ID}",
            keyFileVariable: 'SSH_KEY'
          )]) {
            sh '''
              set -e
              chmod 600 "$SSH_KEY"

              ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ${UBUNTU_USER}@${UBUNTU_HOST} "
                set -e

                sudo mkdir -p /data/frontend-build-output
                sudo mkdir -p /data/backend-build-output

                sudo chown -R jj:jj /data/frontend-build-output
                sudo chown -R jj:jj /data/backend-build-output

                sudo rm -rf /data/frontend-build-output/01-nms4pos-ui
                sudo mkdir -p /data/frontend-build-output/01-nms4pos-ui

                sudo rm -rf /data/backend-build-output/01-nms4pos-java
                sudo mkdir -p /data/backend-build-output/01-nms4pos-java

                sudo chown -R jj:jj /data/frontend-build-output/01-nms4pos-ui
                sudo chown -R jj:jj /data/backend-build-output/01-nms4pos-java
              "
            '''
          }
        }
      }
    }
  }

  post {
    success {
      echo '清理完成'
    }
    failure {
      echo '清理失败，请检查 SSH 凭据、jj 用户权限或 sudo 配置'
    }
  }
}
```

## 6. 为什么不推荐 Freestyle

Freestyle 任务本身不是不能做，而是问题较多：

- 需要额外确认是否安装 `SSH Agent Plugin`
- 需要额外确认是否支持绑定 `SSH Username with private key`
- Shell 中直接写 `/data/...` 时，容易误删 Jenkins Pod 内路径
- 当前已有前后端 K8s 流水线均采用 `withCredentials + ssh/scp` 模式，Pipeline 与现有体系保持一致

因此这里推荐统一使用 Pipeline，而不是继续使用 Freestyle。

## 7. 常见报错与处理

### 7.1 `Permission denied (publickey,password)`

原因：

- Jenkins 没有成功注入私钥
- 私钥不是 `ubuntu-output-ssh-key`
- `jj` 用户未配置公钥登录

处理：

- 检查 Jenkins 凭据配置
- 检查 `authorized_keys`
- 在物理机上验证该私钥能否登录

### 7.2 `sudo: a password is required`

原因：

- `jj` 用户没有免密 sudo

处理：

- 为 `jj` 配置允许执行本文中目录命令的 sudo 权限

### 7.3 `ssh: not found`

原因：

- Pod 镜像中没有安装 OpenSSH 客户端

处理：

- 保留 `apt-get update && apt-get install -y openssh-client`

### 7.4 `ErrImagePull` / `ImagePullBackOff`

原因：

- K8s 节点无法拉取 `alpine` 等基础镜像
- 镜像加速域名失效

处理：

- 优先复用现有成功流水线已经在使用的镜像
- 本方案示例已改为：`maven:3.9-eclipse-temurin-21`
- 不再使用 `alpine:3.20`

## 8. 与现有文档的关系

本方案用于“构建前清理 Ubuntu 物理机产物目录”。

相关文档：

- `Jenkins在K8s构建前端并由Windows从Ubuntu取包方案.md`
- `Jenkins在K8s构建taro-pos前端并由Windows从Ubuntu取包方案.md`
- `Jenkins在K8s构建后端并由Windows从Ubuntu取包方案.md`

它们负责构建和上传产物；本文负责在构建链路前单独做目录清理。
