# 多环境 CD 流程最佳实践

## 环境架构设计

```
代码仓库
   ↓
┌─────────────────────────────────────────────────┐
│                Jenkins CI/CD                     │
├─────────────────────────────────────────────────┤
│  develop 分支 → 自动部署 → DEV 环境              │
│  release 分支 → 自动部署 → TEST 环境             │
│  master 分支  → 人工审批 → PROD 环境             │
└─────────────────────────────────────────────────┘
         ↓              ↓              ↓
    ┌────────┐    ┌────────┐    ┌────────┐
    │  DEV   │    │  TEST  │    │  PROD  │
    │ 命名空间 │    │ 命名空间 │    │ 命名空间 │
    └────────┘    └────────┘    └────────┘
```

---

## 方案 1：多分支 + 自动环境映射（推荐）

### Jenkinsfile 配置

```groovy
pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: maven
    image: maven:3.9-eclipse-temurin-21
    command: ['cat']
    tty: true
  - name: kubectl
    image: bitnami/kubectl:latest
    command: ['cat']
    tty: true
"""
        }
    }

    environment {
        PROJECT_NAME = 'nms4cloud-pos-java'
        DOCKER_REGISTRY = 'crpi-xxx.cn-hangzhou.personal.cr.aliyuncs.com'
        DOCKER_NAMESPACE = 'lgy-images'
    }

    stages {
        stage('确定部署环境') {
            steps {
                script {
                    // 根据分支自动确定环境
                    def branch = env.GIT_BRANCH.replaceAll('origin/', '')

                    if (branch == 'master' || branch == 'main') {
                        env.DEPLOY_ENV = 'prod'
                        env.K8S_NAMESPACE = 'prod'
                        env.IMAGE_TAG = "${env.BUILD_NUMBER}"
                        env.REPLICAS = '3'
                        env.REQUIRE_APPROVAL = 'true'
                    } else if (branch == 'release' || branch.startsWith('release/')) {
                        env.DEPLOY_ENV = 'test'
                        env.K8S_NAMESPACE = 'test'
                        env.IMAGE_TAG = "${env.BUILD_NUMBER}-rc"
                        env.REPLICAS = '2'
                        env.REQUIRE_APPROVAL = 'false'
                    } else if (branch == 'develop' || branch.startsWith('feature/')) {
                        env.DEPLOY_ENV = 'dev'
                        env.K8S_NAMESPACE = 'dev'
                        env.IMAGE_TAG = "${env.BUILD_NUMBER}-dev"
                        env.REPLICAS = '1'
                        env.REQUIRE_APPROVAL = 'false'
                    } else {
                        error("不支持的分支: ${branch}")
                    }

                    echo """
                    ╔════════════════════════════════════════╗
                    ║         环境配置                        ║
                    ╚════════════════════════════════════════╝
                    分支: ${branch}
                    环境: ${env.DEPLOY_ENV}
                    命名空间: ${env.K8S_NAMESPACE}
                    镜像标签: ${env.IMAGE_TAG}
                    副本数: ${env.REPLICAS}
                    需要审批: ${env.REQUIRE_APPROVAL}
                    """
                }
            }
        }

        stage('构建镜像') {
            steps {
                script {
                    env.DOCKER_IMAGE = "${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${params.BUILD_MODULE}:${env.IMAGE_TAG}"
                    // ... 构建逻辑
                }
            }
        }

        stage('生产环境审批') {
            when {
                expression { env.REQUIRE_APPROVAL == 'true' }
            }
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    input message: """
                        确认部署到生产环境？

                        镜像: ${env.DOCKER_IMAGE}
                        命名空间: ${env.K8S_NAMESPACE}
                        副本数: ${env.REPLICAS}
                    """,
                    ok: '确认部署',
                    submitter: 'admin,ops-team'
                }
            }
        }

        stage('部署到 Kubernetes') {
            steps {
                container('kubectl') {
                    script {
                        deployToK8s(
                            namespace: env.K8S_NAMESPACE,
                            deployment: params.BUILD_MODULE,
                            image: env.DOCKER_IMAGE,
                            replicas: env.REPLICAS
                        )
                    }
                }
            }
        }

        stage('健康检查') {
            steps {
                container('kubectl') {
                    script {
                        healthCheck(
                            namespace: env.K8S_NAMESPACE,
                            deployment: params.BUILD_MODULE
                        )
                    }
                }
            }
        }

        stage('烟雾测试') {
            steps {
                container('kubectl') {
                    script {
                        smokeTest(
                            namespace: env.K8S_NAMESPACE,
                            service: params.BUILD_MODULE
                        )
                    }
                }
            }
        }
    }

    post {
        success {
            script {
                sendNotification(
                    status: 'SUCCESS',
                    env: env.DEPLOY_ENV,
                    image: env.DOCKER_IMAGE
                )
            }
        }
        failure {
            script {
                // 自动回滚
                if (env.K8S_NAMESPACE) {
                    container('kubectl') {
                        sh """
                            kubectl rollout undo deployment/${params.BUILD_MODULE} \
                                -n ${env.K8S_NAMESPACE}
                        """
                    }
                }

                sendNotification(
                    status: 'FAILURE',
                    env: env.DEPLOY_ENV
                )
            }
        }
    }
}

// ==================== 辅助函数 ====================

def deployToK8s(Map config) {
    echo ">>> 部署到 ${config.namespace} 环境..."

    sh """
        # 检查 Deployment 是否存在
        if kubectl get deployment ${config.deployment} -n ${config.namespace} &>/dev/null; then
            echo "✓ Deployment 已存在，执行滚动更新"

            # 更新镜像
            kubectl set image deployment/${config.deployment} \
                ${config.deployment}=${config.image} \
                -n ${config.namespace}

            # 更新副本数（如果需要）
            kubectl scale deployment/${config.deployment} \
                --replicas=${config.replicas} \
                -n ${config.namespace}
        else
            echo "⚠ Deployment 不存在，创建新的 Deployment"

            # 创建 Deployment
            kubectl create deployment ${config.deployment} \
                --image=${config.image} \
                --replicas=${config.replicas} \
                -n ${config.namespace}

            # 暴露服务
            kubectl expose deployment ${config.deployment} \
                --port=8080 \
                --target-port=8080 \
                -n ${config.namespace}
        fi

        echo "✓ 部署命令已执行"
    """
}

def healthCheck(Map config) {
    echo ">>> 健康检查: ${config.deployment} in ${config.namespace}"

    sh """
        # 等待 Deployment 就绪
        kubectl rollout status deployment/${config.deployment} \
            -n ${config.namespace} \
            --timeout=300s

        # 检查 Pod 状态
        kubectl get pods -n ${config.namespace} \
            -l app=${config.deployment} \
            -o wide

        # 检查 Pod 是否全部 Running
        READY_PODS=\$(kubectl get pods -n ${config.namespace} \
            -l app=${config.deployment} \
            -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}' | wc -w)

        TOTAL_PODS=\$(kubectl get pods -n ${config.namespace} \
            -l app=${config.deployment} \
            -o jsonpath='{.items[*].metadata.name}' | wc -w)

        echo "就绪 Pod 数: \$READY_PODS / \$TOTAL_PODS"

        if [ "\$READY_PODS" -eq "\$TOTAL_PODS" ] && [ "\$TOTAL_PODS" -gt 0 ]; then
            echo "✓ 所有 Pod 已就绪"
        else
            echo "✗ 部分 Pod 未就绪"
            exit 1
        fi
    """
}

def smokeTest(Map config) {
    echo ">>> 烟雾测试: ${config.service} in ${config.namespace}"

    sh """
        # 获取 Service ClusterIP
        SERVICE_IP=\$(kubectl get service ${config.service} -n ${config.namespace} \
            -o jsonpath='{.spec.clusterIP}')

        if [ -z "\$SERVICE_IP" ]; then
            echo "⚠ Service 不存在，跳过烟雾测试"
            exit 0
        fi

        echo "Service IP: \$SERVICE_IP"

        # 在集群内测试服务可访问性
        kubectl run smoke-test-${BUILD_NUMBER} \
            --rm -i --restart=Never \
            --image=curlimages/curl \
            -n ${config.namespace} \
            -- curl -f -s -o /dev/null -w "%{http_code}" \
            http://\$SERVICE_IP:8080/actuator/health

        echo "✓ 烟雾测试通过"
    """
}

def sendNotification(Map config) {
    // 这里可以集成钉钉、企业微信、Slack 等
    echo """
    ╔════════════════════════════════════════╗
    ║         部署通知                        ║
    ╚════════════════════════════════════════╝
    状态: ${config.status}
    环境: ${config.env}
    镜像: ${config.image ?: 'N/A'}
    时间: ${new Date()}
    """
}
```

---

## 方案 2：独立流水线（更安全）

### 创建三个独立的 Jenkins Job

#### 1. nms4cloud-pos-java-dev
```groovy
pipeline {
    agent { ... }

    environment {
        DEPLOY_ENV = 'dev'
        K8S_NAMESPACE = 'dev'
        AUTO_DEPLOY = 'true'
    }

    triggers {
        // 监听 develop 分支
        pollSCM('H/5 * * * *')
    }

    stages {
        stage('代码检出') {
            steps {
                git branch: 'develop',
                    url: 'https://...'
            }
        }
        // ... CI/CD 流程
    }
}
```

#### 2. nms4cloud-pos-java-test
```groovy
pipeline {
    agent { ... }

    environment {
        DEPLOY_ENV = 'test'
        K8S_NAMESPACE = 'test'
        AUTO_DEPLOY = 'true'
    }

    triggers {
        // 监听 release 分支
        pollSCM('H/5 * * * *')
    }

    stages {
        stage('代码检出') {
            steps {
                git branch: 'release',
                    url: 'https://...'
            }
        }
        // ... CI/CD 流程
    }
}
```

#### 3. nms4cloud-pos-java-prod
```groovy
pipeline {
    agent { ... }

    environment {
        DEPLOY_ENV = 'prod'
        K8S_NAMESPACE = 'prod'
        AUTO_DEPLOY = 'false'  // 需要手动触发
    }

    // 不使用自动触发，只能手动触发

    stages {
        stage('代码检出') {
            steps {
                git branch: 'master',
                    url: 'https://...'
            }
        }

        stage('生产环境审批') {
            steps {
                input message: '确认部署到生产环境？',
                      ok: '确认部署',
                      submitter: 'admin,ops-team'
            }
        }

        stage('金丝雀发布') {
            steps {
                // 金丝雀发布逻辑
            }
        }

        // ... 其他 CD 流程
    }
}
```

---

## 方案 3：GitOps（最先进）

使用 ArgoCD 或 FluxCD 实现声明式部署

### 目录结构
```
k8s/
├── base/                    # 基础配置
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
├── overlays/
│   ├── dev/                 # 开发环境
│   │   ├── kustomization.yaml
│   │   └── patch.yaml
│   ├── test/                # 测试环境
│   │   ├── kustomization.yaml
│   │   └── patch.yaml
│   └── prod/                # 生产环境
│       ├── kustomization.yaml
│       └── patch.yaml
```

### base/deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nms4cloud-pos3boot
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nms4cloud-pos3boot
  template:
    metadata:
      labels:
        app: nms4cloud-pos3boot
    spec:
      containers:
      - name: nms4cloud-pos3boot
        image: crpi-xxx/lgy-images/nms4cloud-pos3boot:latest
        ports:
        - containerPort: 8080
```

### overlays/prod/kustomization.yaml
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: prod

bases:
- ../../base

replicas:
- name: nms4cloud-pos3boot
  count: 3

images:
- name: crpi-xxx/lgy-images/nms4cloud-pos3boot
  newTag: prod-123

patches:
- path: patch.yaml
```

### Jenkins 只负责 CI + 更新镜像标签
```groovy
stage('更新 K8s 配置') {
    steps {
        script {
            // 更新 kustomization.yaml 中的镜像标签
            sh """
                cd k8s/overlays/${DEPLOY_ENV}
                kustomize edit set image \
                    crpi-xxx/lgy-images/nms4cloud-pos3boot:${IMAGE_TAG}

                git add .
                git commit -m "Update image to ${IMAGE_TAG}"
                git push
            """

            // ArgoCD 会自动检测变化并部署
        }
    }
}
```

---

## 环境配置对比

| 配置项 | DEV | TEST | PROD |
|--------|-----|------|------|
| 命名空间 | dev | test | prod |
| 副本数 | 1 | 2 | 3+ |
| 资源限制 | 低 | 中 | 高 |
| 自动部署 | ✓ | ✓ | ✗ (需审批) |
| 健康检查 | 基础 | 完整 | 完整 + 监控 |
| 回滚策略 | 手动 | 自动 | 自动 + 告警 |
| 日志保留 | 7天 | 30天 | 90天 |
| 备份策略 | 无 | 每日 | 实时 |

---

## 推荐方案总结

### 小团队（< 10人）
- **方案 1**：多分支 + 自动环境映射
- 简单易维护，一个 Jenkinsfile 搞定

### 中型团队（10-50人）
- **方案 2**：独立流水线
- 职责清晰，权限分离

### 大型团队（> 50人）
- **方案 3**：GitOps
- 声明式配置，审计完整，可追溯
