# kubectl 命令详解

## 基本语法

```bash
kubectl [command] [TYPE] [NAME] [flags]
```

- `command`：操作类型（get、apply、delete 等）
- `TYPE`：资源类型（pod、deployment、service 等）
- `NAME`：资源名称（省略则列出所有）
- `flags`：可选参数（-n 指定命名空间等）

---

## 一、查看资源

```bash
# 查看资源列表
kubectl get pods                          # 查看当前命名空间的 pod
kubectl get pods -n kube-system           # 查看指定命名空间
kubectl get pods -A                       # 查看所有命名空间
kubectl get pods -o wide                  # 显示更多信息（IP、节点）
kubectl get pods -o yaml                  # 以 yaml 格式输出
kubectl get pods --watch                  # 实时监听变化

# 常用资源类型
kubectl get nodes                         # 查看节点
kubectl get namespaces                    # 查看命名空间
kubectl get deployments                   # 查看部署
kubectl get svc                           # 查看服务（services 缩写）
kubectl get ingress                       # 查看 ingress
kubectl get cm                            # 查看配置（configmap 缩写）
kubectl get secret                        # 查看密钥
kubectl get pvc                           # 查看持久卷声明
kubectl get pv                            # 查看持久卷
kubectl get events                        # 查看事件（排查问题常用）

# 查看详情
kubectl describe pod <pod-name>           # 详细信息（含事件）
kubectl describe node <node-name>
kubectl describe deployment <name>
```

---

## 二、创建 / 更新资源

```bash
# 通过 yaml 文件
kubectl apply -f deployment.yaml          # 创建或更新（推荐）
kubectl apply -f ./k8s/                   # 应用目录下所有 yaml
kubectl apply -f https://xxx/file.yaml    # 从 URL 应用

# 创建（不存在才创建，已存在报错）
kubectl create -f deployment.yaml

# 快速创建
kubectl create deployment nginx --image=nginx:latest
kubectl create namespace my-ns
kubectl create configmap my-config --from-file=config.properties
kubectl create secret generic my-secret --from-literal=password=123456
```

---

## 三、删除资源

```bash
kubectl delete pod <pod-name>
kubectl delete pod <pod-name> -n <namespace>
kubectl delete -f deployment.yaml         # 删除 yaml 定义的资源
kubectl delete deployment <name>
kubectl delete all --all -n <namespace>   # 删除命名空间下所有资源

# 强制删除（卡住的 pod）
kubectl delete pod <pod-name> --force --grace-period=0
```

---

## 四、调试排查

```bash
# 查看日志
kubectl logs <pod-name>                   # 查看日志
kubectl logs <pod-name> -f                # 实时跟踪日志
kubectl logs <pod-name> --tail=100        # 最后 100 行
kubectl logs <pod-name> -c <container>    # 多容器时指定容器
kubectl logs <pod-name> --previous        # 查看上一次崩溃的日志

# 进入容器（必须加 -n 指定命名空间，否则在默认命名空间找不到 pod）
kubectl exec -it <pod-name> -n <namespace> -- /bin/bash
kubectl exec -it <pod-name> -n <namespace> -c <container> -- /bin/sh

# 端口转发（本地调试）
kubectl port-forward pod/<pod-name> 8080:80
kubectl port-forward svc/<svc-name> 8080:80
kubectl port-forward deployment/<name> 8080:80

# 复制文件
kubectl cp <pod-name>:/path/to/file ./local-file   # 从容器复制出来
kubectl cp ./local-file <pod-name>:/path/to/file   # 复制进容器
```

---

## 五、更新 / 扩缩容

```bash
# 扩缩容
kubectl scale deployment <name> --replicas=3

# 更新镜像（滚动更新）
kubectl set image deployment/<name> <container>=<image>:<tag>

# 查看滚动更新状态
kubectl rollout status deployment/<name>

# 回滚
kubectl rollout undo deployment/<name>                    # 回滚到上一版本
kubectl rollout undo deployment/<name> --to-revision=2    # 回滚到指定版本
kubectl rollout history deployment/<name>                 # 查看历史版本

# 暂停 / 恢复滚动更新
kubectl rollout pause deployment/<name>
kubectl rollout resume deployment/<name>

# 重启 pod（不改配置的情况下触发重建）
kubectl rollout restart deployment/<name>
```

---

## 六、节点管理

```bash
# 标记节点不可调度（维护前）
kubectl cordon <node-name>

# 驱逐节点上的 pod（维护）
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# 恢复节点可调度
kubectl uncordon <node-name>

# 给节点打标签
kubectl label node <node-name> disktype=ssd

# 给节点打污点
kubectl taint node <node-name> key=value:NoSchedule
```

---

## 七、常用组合命令

```bash
# 查看所有命名空间下异常的 pod
kubectl get pods -A | grep -v Running | grep -v Completed

# 快速进入某个 pod（需指定命名空间）
kubectl exec -it $(kubectl get pod -l app=nginx -n <namespace> -o jsonpath='{.items[0].metadata.name}') -n <namespace> -- /bin/bash

# 查看 pod 的环境变量
kubectl exec <pod-name> -n <namespace> -- env

# 强制重建某个 deployment 的所有 pod
kubectl rollout restart deployment/<name> -n <namespace>

# 查看资源使用情况（需要 metrics-server）
kubectl top nodes
kubectl top pods -A
```

---

## 八、常用资源类型缩写

| 全称 | 缩写 |
|------|------|
| `pods` | `po` |
| `services` | `svc` |
| `deployments` | `deploy` |
| `replicasets` | `rs` |
| `namespaces` | `ns` |
| `nodes` | `no` |
| `configmaps` | `cm` |
| `persistentvolumeclaims` | `pvc` |
| `persistentvolumes` | `pv` |
| `serviceaccounts` | `sa` |
