# 快速配置 Kubernetes Cloud jnlp 镜像

## 问题

jnlp 容器使用默认的 Docker Hub 镜像，国内无法访问。

## 解决方案：在 Kubernetes Cloud 配置中修改

### 步骤 1：进入配置页面

```
Jenkins 首页
→ 系统管理 (Manage Jenkins)
→ 节点管理 (Manage Nodes and Clouds)  
→ Configure Clouds
→ 点击 "kubernetes" (你配置的 Cloud 名称)
```

### 步骤 2：找到 Pod Template 配置

向下滚动，找到以下任一选项：

**选项 A：Pod Template**
- 点击 "Pod Templates" 下的 "Add Pod Template"
- 或者展开已有的 Pod Template

**选项 B：Images**
- 找到 "Images" 或 "Container Template" 部分

**选项 C：Advanced**
- 点击 "Advanced" 按钮
- 找到 "Pod Template" 或 "Container Template"

### 步骤 3：配置 jnlp 容器镜像

找到 "Container Template" 或类似配置，添加或修改：

```
Name: jnlp
Docker image: swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/jenkins/inbound-agent:latest
```

**重要：** 
- Name 必须是 `jnlp`
- 不要设置 Command 或 Arguments（留空）

### 步骤 4：保存配置

点击页面底部的 "Save" 或 "保存" 按钮

## 配置截图位置参考

```
┌─────────────────────────────────────────────────────┐
│ Configure Clouds                                     │
├─────────────────────────────────────────────────────┤
│                                                      │
│ ☁ Kubernetes                                        │
│   ├─ Name: kubernetes                               │
│   ├─ Kubernetes URL: https://...                    │
│   ├─ Kubernetes Namespace: jenkins                  │
│   ├─ Jenkins URL: http://...                        │
│   │                                                  │
│   └─ [Advanced...] ← 点击这里                       │
│       │                                              │
│       ├─ Pod Templates                               │
│       │   └─ [Add Pod Template] ← 点击这里          │
│       │       │                                      │
│       │       ├─ Name: (可选)                       │
│       │       ├─ Labels: (可选)                     │
│       │       │                                      │
│       │       └─ Containers                          │
│       │           └─ [Add Container] ← 点击这里     │
│       │               │                              │
│       │               ├─ Name: jnlp ← 必须是 jnlp   │
│       │               ├─ Docker image: swr.cn-...   │
│       │               ├─ Command: (留空)            │
│       │               └─ Arguments: (留空)          │
│       │                                              │
│       └─ [Save] ← 最后点击保存                      │
│                                                      │
└─────────────────────────────────────────────────────┘
```

## 验证配置

### 方法 1：查看配置是否保存

重新进入 Configure Clouds，检查 jnlp 镜像配置是否存在

### 方法 2：触发构建测试

触发一次 Jenkins 构建，查看 Pod 创建情况：

```bash
kubectl get pods -n jenkins -w
```

查看 jnlp 容器日志：

```bash
kubectl logs <pod-name> -n jenkins -c jnlp
```

成功的日志应该包含：

```
INFO: Connected
```

## 如果找不到配置位置

### 备选方案：使用 Pod Template YAML

在 Kubernetes Cloud 配置中，找到 "Pod Template" 部分，可能有一个 "Raw YAML" 或 "YAML" 输入框：

```yaml
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: jnlp
    image: swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/jenkins/inbound-agent:latest
```

## 常见问题

### Q: 保存后配置丢失

A: 可能是权限问题，确保你有管理员权限

### Q: 找不到 Pod Template 配置

A: 不同版本的 Kubernetes Plugin 界面可能不同，尝试：
1. 点击所有 "Advanced" 按钮
2. 查找 "Images" 或 "Container Template"
3. 查找 "Pod Template" 或 "Pod Retention"

### Q: 配置后仍然使用旧镜像

A: 
1. 检查配置是否保存成功
2. 重启 Jenkins：系统管理 → 重新加载配置
3. 或者重启 Jenkins Pod

## 完成后

配置完成后，重新触发构建，jnlp 容器应该能正常启动并连接到 Jenkins Master。

## 如果还是不行

请提供以下信息：
1. Kubernetes Plugin 版本
2. Jenkins 版本
3. Pod 详细日志：`kubectl describe pod <pod-name> -n jenkins`
