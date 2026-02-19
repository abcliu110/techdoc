# Jenkins Pipeline 中的 Agent 详解

## 一、Agent 是什么？

### 1.1 基本概念

**Agent（代理/执行器）** 是 Jenkins 中**实际执行构建任务的地方**。

**类比理解：**
```
Jenkins Master = 老板（分配任务，不干活）
Agent = 员工（实际干活的人）

老板说："去构建这个项目"
员工（Agent）执行：下载代码、编译、测试、打包...
```

### 1.2 为什么需要 Agent？

**Jenkins Master 的职责：**
- ✅ 管理任务调度
- ✅ 展示 UI 界面
- ✅ 存储构建历史
- ❌ **不应该**执行构建任务（性能和安全考虑）

**Agent 的职责：**
- ✅ 执行实际的构建任务
- ✅ 提供构建环境（JDK、Maven、Docker 等）
- ✅ 隔离不同的构建任务

---

## 二、Agent 的类型

### 2.1 类型对比

| Agent 类型 | 说明 | 使用场景 |
|-----------|------|---------|
| `any` | 任何可用的 Agent | 简单项目 |
| `none` | 不分配 Agent | 手动指定 |
| `label` | 指定标签的 Agent | 特定环境 |
| `node` | 指定节点的 Agent | 固定机器 |
| `docker` | Docker 容器 Agent | 需要特定镜像 |
| `kubernetes` | K8s Pod Agent | 云原生环境 |

### 2.2 详细说明

#### 类型 1：agent any

```groovy
pipeline {
    agent any  // 使用任何可用的 Agent

    stages {
        stage('构建') {
            steps {
                sh 'mvn clean package'
            }
        }
    }
}
```

**含义：** Jenkins 会选择任何一个可用的 Agent 来执行任务。

---

#### 类型 2：agent none

```groovy
pipeline {
    agent none  // 不自动分配 Agent

    stages {
        stage('构建') {
            agent any  // 在 stage 级别指定 Agent
            steps {
                sh 'mvn clean package'
            }
        }
    }
}
```

**含义：** Pipeline 级别不分配 Agent，在每个 stage 中单独指定。

---

#### 类型 3：agent label

```groovy
pipeline {
    agent {
        label 'linux'  // 使用标签为 linux 的 Agent
    }

    stages {
        stage('构建') {
            steps {
                sh 'mvn clean package'
            }
        }
    }
}
```

**含义：** 使用带有特定标签的 Agent（需要预先配置）。

---

#### 类型 4：agent docker

```groovy
pipeline {
    agent {
        docker {
            image 'maven:3.9.6-openjdk-21'  // 使用 Docker 容器作为 Agent
        }
    }

    stages {
        stage('构建') {
            steps {
                sh 'mvn clean package'
            }
        }
    }
}
```

**含义：** 在 Docker 容器中执行构建（需要 Agent 机器上有 Docker）。

---

#### 类型 5：agent kubernetes（重点）

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
    image: maven:3.9.6-openjdk-21
    command: ['cat']
    tty: true
"""
        }
    }

    stages {
        stage('构建') {
            steps {
                container('maven') {
                    sh 'mvn clean package'
                }
            }
        }
    }
}
```

**含义：** 动态创建一个 K8s Pod 作为 Agent，用完即销毁。

---

## 三、agent { kubernetes { ... } } 详解

### 3.1 完整语法

```groovy
pipeline {
    agent {
        kubernetes {
            // Pod 的 YAML 定义
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: agent
spec:
  containers:
  - name: maven
    image: maven:3.9.6-openjdk-21
    command: ['cat']
    tty: true
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command: ['/busybox/cat']
    tty: true
"""
        }
    }

    stages {
        stage('Maven 构建') {
            steps {
                container('maven') {  // 在 maven 容器中执行
                    sh 'mvn clean package'
                }
            }
        }

        stage('构建镜像') {
            steps {
                container('kaniko') {  // 在 kaniko 容器中执行
                    sh '/kaniko/executor --dockerfile=Dockerfile --destination=myapp:1.0'
                }
            }
        }
    }
}
```

### 3.2 工作原理

```
1. Jenkins 读取 agent { kubernetes { ... } }
   ↓
2. Jenkins 调用 Kubernetes API 创建 Pod
   Pod 包含：
   - maven 容器
   - kaniko 容器
   ↓
3. Pod 启动完成
   ↓
4. Jenkins 连接到 Pod
   ↓
5. 执行 stage('Maven 构建')
   → 在 maven 容器中执行 mvn clean package
   ↓
6. 执行 stage('构建镜像')
   → 在 kaniko 容器中执行 /kaniko/executor
   ↓
7. 所有 stage 完成
   ↓
8. Jenkins 删除 Pod
```

### 3.3 关键点解释

#### command: ['cat'] 和 tty: true 是什么意思？

```yaml
containers:
- name: maven
  image: maven:3.9.6-openjdk-21
  command: ['cat']  # 执行 cat 命令（会一直等待输入）
  tty: true         # 分配一个伪终端
```

**作用：**
- `command: ['cat']`：让容器保持运行状态（cat 会等待输入，不会退出）
- `tty: true`：分配终端，让 Jenkins 可以连接进来执行命令

**如果不加这两行：**
```
容器启动 → 没有任务 → 立即退出 → Pod 终止 → 构建失败
```

**加了这两行：**
```
容器启动 → 执行 cat 命令 → 等待输入 → 保持运行 → Jenkins 可以连接执行命令
```

#### container('maven') 是什么意思？

```groovy
steps {
    container('maven') {  // 指定在哪个容器中执行
        sh 'mvn clean package'
    }
}
```

**含义：** 在 Pod 的 `maven` 容器中执行命令。

**完整流程：**
```
Jenkins → 连接到 Pod → 进入 maven 容器 → 执行 mvn clean package
```

**等价于：**
```bash
kubectl exec -it <pod-name> -c maven -n jenkins -- mvn clean package
```

---

## 四、不同 Agent 的对比

### 4.1 传统 Agent vs Kubernetes Agent

**传统固定 Agent：**

```groovy
pipeline {
    agent {
        label 'build-server'  // 使用固定的构建服务器
    }

    stages {
        stage('构建') {
            steps {
                sh 'mvn clean package'
            }
        }
    }
}
```

**架构：**
```
Jenkins Master
    ↓
固定的 Agent 服务器（build-server）
    - 需要预先安装 JDK、Maven、Docker 等
    - 一直运行，占用资源
    - 环境可能被污染
```

**Kubernetes 动态 Agent：**

```groovy
pipeline {
    agent {
        kubernetes {
            yaml """
spec:
  containers:
  - name: maven
    image: maven:3.9.6-openjdk-21
    command: ['cat']
    tty: true
"""
        }
    }

    stages {
        stage('构建') {
            steps {
                container('maven') {
                    sh 'mvn clean package'
                }
            }
        }
    }
}
```

**架构：**
```
Jenkins Master
    ↓
动态创建 Pod（临时 Agent）
    - 自动拉取镜像（maven:3.9.6-openjdk-21）
    - 用完即销毁，不占用资源
    - 每次都是全新环境
```

### 4.2 优缺点对比

| 特性 | 传统 Agent | Kubernetes Agent |
|------|-----------|-----------------|
| 资源利用 | ❌ 一直占用 | ✅ 按需创建 |
| 环境一致性 | ❌ 可能被污染 | ✅ 每次全新 |
| 扩展性 | ❌ 需要手动添加 | ✅ 自动扩展 |
| 维护成本 | ❌ 需要维护服务器 | ✅ 无需维护 |
| 启动速度 | ✅ 快（已启动） | ❌ 慢（需要拉取镜像） |
| 适用场景 | 小团队、简单项目 | 大团队、云原生 |

---

## 五、实际例子

### 5.1 简单项目（单容器）

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
    image: maven:3.9.6-openjdk-21
    command: ['cat']
    tty: true
"""
        }
    }

    stages {
        stage('检出代码') {
            steps {
                git 'https://github.com/your/repo.git'
            }
        }

        stage('Maven 构建') {
            steps {
                container('maven') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }
    }
}
```

**说明：**
- Agent 是一个包含 Maven 的 Pod
- 所有命令在 maven 容器中执行

### 5.2 复杂项目（多容器）

```groovy
pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  # Maven 容器（用于构建）
  - name: maven
    image: maven:3.9.6-openjdk-21
    command: ['cat']
    tty: true
    volumeMounts:
    - name: maven-cache
      mountPath: /root/.m2

  # Kaniko 容器（用于构建镜像）
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command: ['/busybox/cat']
    tty: true
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker

  # kubectl 容器（用于部署）
  - name: kubectl
    image: bitnami/kubectl:latest
    command: ['cat']
    tty: true

  volumes:
  - name: maven-cache
    emptyDir: {}
  - name: docker-config
    secret:
      secretName: docker-registry-secret
"""
        }
    }

    stages {
        stage('检出代码') {
            steps {
                git 'https://github.com/your/repo.git'
            }
        }

        stage('Maven 构建') {
            steps {
                container('maven') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }

        stage('构建镜像') {
            steps {
                container('kaniko') {
                    sh '''
                        /kaniko/executor \
                          --context=${WORKSPACE} \
                          --dockerfile=${WORKSPACE}/Dockerfile \
                          --destination=ccr.ccs.tencentyun.com/nms4cloud/myapp:1.0
                    '''
                }
            }
        }

        stage('部署到 K8s') {
            steps {
                container('kubectl') {
                    sh 'kubectl set image deployment/myapp myapp=ccr.ccs.tencentyun.com/nms4cloud/myapp:1.0 -n production'
                }
            }
        }
    }
}
```

**说明：**
- Agent 是一个包含 3 个容器的 Pod
- 不同的 stage 在不同的容器中执行
- maven 容器：构建 jar
- kaniko 容器：构建镜像
- kubectl 容器：部署到 K8s

---

## 六、常见问题

### 6.1 为什么不直接在 Jenkins Master 中执行？

**问题：** 为什么需要 Agent，直接在 Jenkins Master 中执行不行吗？

**答案：** 不推荐，原因：

1. **性能问题**
   - Jenkins Master 负责管理任务，不应该执行构建
   - 构建任务会占用大量 CPU 和内存

2. **安全问题**
   - 构建任务可能执行不可信的代码
   - 可能影响 Jenkins Master 的稳定性

3. **扩展性问题**
   - Master 只有一个，无法并行构建多个项目
   - Agent 可以有多个，支持并行构建

### 6.2 agent { kubernetes { ... } } 需要什么前提条件？

**前提条件：**

1. ✅ Jenkins 安装了 Kubernetes 插件
2. ✅ Jenkins 配置了 Kubernetes Cloud
3. ✅ Jenkins 有权限调用 Kubernetes API（ServiceAccount）
4. ✅ K8s 集群可以拉取镜像

### 6.3 如何选择 Agent 类型？

**选择建议：**

| 场景 | 推荐 Agent |
|------|-----------|
| 小团队、简单项目 | `agent any` 或固定 Agent |
| 需要特定环境 | `agent docker` |
| 云原生、K8s 环境 | `agent kubernetes` |
| 大团队、高并发 | `agent kubernetes` |

---

## 七、总结

### 7.1 核心概念

```
Agent = 实际执行构建任务的地方

Jenkins Master（老板）
    ↓ 分配任务
Agent（员工）
    ↓ 执行任务
构建结果
```

### 7.2 agent { kubernetes { ... } } 的本质

```
agent {
    kubernetes {
        yaml """..."""  ← 定义一个 Pod 作为 Agent
    }
}

等价于：
1. 创建一个 K8s Pod
2. 在 Pod 中执行构建任务
3. 任务完成后删除 Pod
```

### 7.3 关键点

- ✅ Agent 是执行构建的地方，不是 Jenkins Master
- ✅ `agent { kubernetes { ... } }` 会动态创建 Pod
- ✅ Pod 包含多个容器，每个容器有不同的工具
- ✅ 使用 `container('name')` 指定在哪个容器中执行
- ✅ 构建完成后 Pod 自动销毁

希望这样解释清楚了！有任何疑问随时问我。
