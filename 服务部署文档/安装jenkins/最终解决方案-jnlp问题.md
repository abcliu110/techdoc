# Jenkins Kubernetes jnlp 容器问题最终解决方案

## 问题现象

jnlp 容器启动后立即退出，显示帮助信息：
```
Container [jnlp] terminated [Completed]
```

日志显示的是 jnlp 的帮助文档，说明容器没有接收到正确的启动参数。

## 根本原因

Jenkins Kubernetes Plugin 在创建 Pod 时，需要自动注入 jnlp 容器的启动参数（secret、agent名称等）。

当我们在 Pod Template 中自定义 jnlp 容器配置时，会覆盖这些自动注入的参数，导致容器无法正常启动。

## 解决方案

### 方案 1：完全删除 Pod Template 配置（推荐）

**步骤：**

1. 进入 Jenkins 配置
   ```
   系统管理 → 节点管理 → Configure Clouds → Kubernetes
   ```

2. 找到 "Pod Templates" 部分

3. **删除所有自定义的 Pod Template**

4. 保存配置

5. 重新触发构建

**原理：**
- 没有自定义 Pod Template 时，Jenkins 使用默认配置
- 默认配置会正确注入 jnlp 容器的启动参数
- Jenkinsfile 中只定义业务容器（如 kaniko）

### 方案 2：配置 Kubernetes Cloud 的默认 jnlp 镜像

如果方案 1 不行，尝试在 Kubernetes Cloud 的全局配置中设置：

**步骤：**

1. 进入 Kubernetes Cloud 配置
   ```
   系统管理 → 节点管理 → Configure Clouds → Kubernetes → Configure
   ```

2. 找到 "Jenkins URL" 下方的配置

3. 查找类似 "Container Template" 或 "Images" 的全局配置

4. 设置默认的 jnlp 镜像（如果有这个选项）

### 方案 3：使用 RKE2 镜像加速（配合方案 1）

在 RKE2 节点上配置镜像加速，让默认的 jnlp 镜像能够正常拉取：

```bash
sudo tee /etc/rancher/rke2/registries.yaml <<'EOF'
mirrors:
  docker.io:
    endpoint:
      - "https://m.daocloud.io/docker.io"
      - "https://dockerproxy.com"
      - "https://docker.mirrors.ustc.edu.cn"
EOF

sudo systemctl restart rke2-server
```

## 当前配置状态

### Jenkinsfile-k8s
```yaml
containers:
- name: kaniko
  image: m.daocloud.io/gcr.io/kaniko-project/executor:debug
```

**说明：**
- 只定义 kaniko 容器
- jnlp 容器由 Jenkins 自动管理

### 需要的配置

1. ✅ Jenkinsfile 已正确配置
2. ❌ Jenkins Pod Template 需要删除
3. ✅ RKE2 镜像加速已配置

## 验证步骤

### 1. 检查 Pod Template 是否已删除

```
系统管理 → 节点管理 → Configure Clouds → Kubernetes → Pod Templates
```

应该看到：
- 没有任何自定义的 Pod Template
- 或者 Pod Template 列表为空

### 2. 触发构建

重新触发 Jenkins 构建

### 3. 查看 Pod 日志

```bash
# 查看 Pod 列表
kubectl get pods -n jenkins

# 查看 jnlp 容器日志
kubectl logs <pod-name> -n jenkins -c jnlp
```

**成功的日志应该包含：**
```
INFO: Connected
```

**而不是帮助信息**

### 4. 查看 Pod 详情

```bash
kubectl describe pod <pod-name> -n jenkins
```

查看 jnlp 容器的启动命令和参数是否正确注入。

## 常见问题

### Q: 删除 Pod Template 后仍然失败

A: 尝试以下步骤：
1. 重启 Jenkins：系统管理 → 重新加载配置
2. 或者重启 Jenkins Pod：`kubectl delete pod jenkins-xxx -n jenkins`
3. 清除浏览器缓存

### Q: 找不到 Pod Template 配置

A: 不同版本的 Kubernetes Plugin 界面可能不同，尝试：
1. 查找所有 "Advanced" 按钮并展开
2. 查找 "Pod Template" 或 "Container Template"
3. 查找 "Images" 配置

### Q: jnlp 镜像拉取失败

A: 配置 RKE2 镜像加速（见方案 3）

## 最终检查清单

```
☐ 1. 删除所有自定义 Pod Template
☐ 2. 保存 Jenkins 配置
☐ 3. 配置 RKE2 镜像加速
☐ 4. 重启 RKE2
☐ 5. 重新触发构建
☐ 6. 验证 jnlp 容器正常启动
```

## 如果还是不行

请提供以下信息：
1. Jenkins 版本
2. Kubernetes Plugin 版本
3. Pod 完整日志：`kubectl logs <pod-name> -n jenkins -c jnlp`
4. Pod 详情：`kubectl describe pod <pod-name> -n jenkins`
5. Kubernetes Cloud 配置截图

## 参考资料

- Jenkins Kubernetes Plugin 文档：https://plugins.jenkins.io/kubernetes/
- Kubernetes Pod Template 配置：https://github.com/jenkinsci/kubernetes-plugin
