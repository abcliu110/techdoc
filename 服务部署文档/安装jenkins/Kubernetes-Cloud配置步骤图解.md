# Kubernetes Cloud 配置步骤（图解）

## 一、访问配置页面

### 步骤 1：登录 Jenkins

```
浏览器访问: http://<节点IP>:30080
输入用户名和密码
```

### 步骤 2：进入系统管理

```
首页 → 点击左侧菜单 "系统管理" (Manage Jenkins)
```

### 步骤 3：进入节点管理

```
系统管理页面 → 点击 "节点管理" (Manage Nodes and Clouds)
```

### 步骤 4：配置 Clouds

```
节点管理页面 → 点击左侧 "Configure Clouds"
```

## 二、添加 Kubernetes Cloud

### 步骤 5：添加新的 Cloud

```
Configure Clouds 页面 → 点击 "Add a new cloud" 下拉菜单 → 选择 "Kubernetes"
```

### 步骤 6：填写配置

#### 基本配置

```
┌─────────────────────────────────────────────────────────┐
│ Kubernetes Cloud 配置                                    │
├─────────────────────────────────────────────────────────┤
│                                                          │
│ 名称: kubernetes                                         │
│ [输入框: kubernetes]                                     │
│                                                          │
│ Kubernetes 地址:                                         │
│ [输入框: https://kubernetes.default.svc.cluster.local]  │
│                                                          │
│ Kubernetes 服务证书 key:                                 │
│ [输入框: 留空]                                           │
│                                                          │
│ ☐ 禁用 https 证书检查                                    │
│                                                          │
│ Kubernetes 命名空间:                                     │
│ [输入框: jenkins]                                        │
│                                                          │
│ 凭据:                                                    │
│ [下拉框: - none -]  (使用 ServiceAccount)               │
│                                                          │
│ ☑ WebSocket                                             │
│                                                          │
│ Jenkins 地址:                                            │
│ [输入框: http://jenkins.jenkins.svc.cluster.local:8080] │
│                                                          │
│ Jenkins 通道:                                            │
│ [输入框: jenkins.jenkins.svc.cluster.local:50000]       │
│                                                          │
│ [按钮: Test Connection]                                 │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### 步骤 7：测试连接

点击 "Test Connection" 按钮

**成功显示：**
```
✓ Connection test successful
  Kubernetes version: v1.28.x
```

**失败显示：**
```
✗ Connection test failed: ...
```

### 步骤 8：保存配置

```
页面底部 → 点击 "保存" (Save) 按钮
```

## 三、完整配置参数说明

### 必填参数

| 参数 | 值 | 说明 |
|------|-----|------|
| 名称 | kubernetes | Cloud 的名称，可以自定义 |
| Kubernetes 地址 | https://kubernetes.default.svc.cluster.local | K8s API Server 地址 |
| Kubernetes 命名空间 | jenkins | Pod 创建的命名空间 |
| Jenkins 地址 | http://jenkins.jenkins.svc.cluster.local:8080 | Jenkins Master 地址 |

### 可选参数

| 参数 | 值 | 说明 |
|------|-----|------|
| 凭据 | - none - | 使用 ServiceAccount 认证 |
| WebSocket | ☑ 勾选 | 使用 WebSocket 连接 |
| Jenkins 通道 | jenkins.jenkins.svc.cluster.local:50000 | Agent 连接端口 |

## 四、配置路径总结

```
完整路径:
Jenkins 首页
  → 系统管理 (Manage Jenkins)
    → 节点管理 (Manage Nodes and Clouds)
      → Configure Clouds
        → Add a new cloud
          → Kubernetes
            → 填写配置
              → Test Connection
                → Save
```

## 五、快速配置命令（文字版）

```
1. 访问 Jenkins: http://<节点IP>:30080
2. 点击: 系统管理
3. 点击: 节点管理
4. 点击: Configure Clouds
5. 点击: Add a new cloud → Kubernetes
6. 填写:
   - 名称: kubernetes
   - Kubernetes 地址: https://kubernetes.default.svc.cluster.local
   - 命名空间: jenkins
   - Jenkins 地址: http://jenkins.jenkins.svc.cluster.local:8080
7. 点击: Test Connection
8. 点击: Save
```

## 六、常见问题

### 问题 1：找不到 "Kubernetes" 选项

**原因：** 没有安装 Kubernetes Plugin

**解决：**
```
系统管理 → 插件管理 → 可选插件 → 搜索 "Kubernetes" → 安装
```

### 问题 2：Test Connection 失败

**原因：** ServiceAccount 权限不足

**解决：**
```bash
kubectl create clusterrolebinding jenkins \
  --clusterrole=cluster-admin \
  --serviceaccount=jenkins:jenkins
```

### 问题 3：Jenkins 地址填什么？

**如果 Jenkins 在 K8s 中：**
```
http://jenkins.jenkins.svc.cluster.local:8080
```

**如果 Jenkins 在 Docker 中：**
```
http://<宿主机IP>:8080
```

## 七、验证配置

### 方法 1：查看配置

```
系统管理 → 节点管理 → Configure Clouds
应该看到已配置的 "kubernetes" Cloud
```

### 方法 2：创建测试流水线

```groovy
pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ['cat']
    tty: true
"""
        }
    }
    stages {
        stage('Test') {
            steps {
                container('busybox') {
                    sh 'echo "Kubernetes Cloud works!"'
                }
            }
        }
    }
}
```

执行构建，如果成功说明配置正确。

## 八、配置截图说明

### 截图 1：系统管理入口
```
┌────────────────────────────────────┐
│ Jenkins                            │
├────────────────────────────────────┤
│ ☰ 菜单                             │
│   ├─ 新建任务                      │
│   ├─ 用户                          │
│   ├─ 构建历史                      │
│   └─ 系统管理  ← 点击这里          │
└────────────────────────────────────┘
```

### 截图 2：节点管理入口
```
┌────────────────────────────────────┐
│ 系统管理                           │
├────────────────────────────────────┤
│ ├─ 系统配置                        │
│ ├─ 全局工具配置                    │
│ ├─ 插件管理                        │
│ ├─ 节点管理  ← 点击这里            │
│ └─ ...                             │
└────────────────────────────────────┘
```

### 截图 3：Configure Clouds 入口
```
┌────────────────────────────────────┐
│ 节点管理                           │
├────────────────────────────────────┤
│ ☰ 左侧菜单                         │
│   ├─ 新建节点                      │
│   ├─ Configure Clouds  ← 点击这里  │
│   └─ 节点监控                      │
└────────────────────────────────────┘
```

### 截图 4：添加 Kubernetes Cloud
```
┌────────────────────────────────────┐
│ Configure Clouds                   │
├────────────────────────────────────┤
│ [按钮: Add a new cloud ▼]          │
│   ├─ Kubernetes  ← 选择这个        │
│   └─ ...                           │
└────────────────────────────────────┘
```

## 九、配置模板（复制粘贴）

```
名称: kubernetes

Kubernetes 地址: https://kubernetes.default.svc.cluster.local

Kubernetes 命名空间: jenkins

凭据: - none -

WebSocket: ☑

Jenkins 地址: http://jenkins.jenkins.svc.cluster.local:8080

Jenkins 通道: jenkins.jenkins.svc.cluster.local:50000
```

## 十、下一步

配置完成后：
1. 使用 Jenkinsfile-k8s 创建流水线
2. 执行构建
3. 查看 Pod 是否自动创建
4. 验证构建是否成功
