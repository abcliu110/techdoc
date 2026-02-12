<div id="chap-rancher"></div>

[⬆️ 返回目录](#catalog)


## rancher

Rancher Labs 公司将品牌命名为 Rancher，正是借用了「牧场」的隐喻 ——把 Kubernetes 集群比作 “牧场”，将各类容器、微服务比作 “牧场中的牲畜”，Rancher 平台则是 “牧场主”，负责统一管理、调度、维护整个 “牧场” 的资源，贴合其「容器集群管理平台」的产品定位，形象且易记。
三、补充：相关衍生词（帮你完整掌握词根体系）
ranch（n.）：牧场（尤指北美畜牧大牧场）；（v.）经营牧场，在牧场工作
ranching（n.）：牧场经营业，畜牧业（美式）
ranch house（n.）：美式牧场风格住宅（单层、大空间，适配西部牧场生活）

获取 Rancher 的初始安装密码（通常称为 **Bootstrap Password**）取决于你是通过哪种方式安装的。

以下是两种最常见的安装场景及其获取密码的方法：

### 场景一：通过 Helm 在 Kubernetes (如 RKE2) 上安装
如果你是按照标准生产流程，先装了 RKE2 再通过 Helm 安装了 Rancher，密码存储在 Kubernetes 的 `secret` 中。

请在服务器上运行以下命令：
```bash
kubectl get secret --namespace cattle-system bootstrap-secret -o jsonpath="{.data.bootstrapPassword}" | base64 -d
```
*注：如果提示 `kubectl` 命令不存在，请确保你已经配置了环境变量 `export KUBECONFIG=/etc/rancher/rke2/rke2.yaml`。*

---

### 场景二：通过 Docker 容器单机安装
如果你是使用 `docker run ... rancher/rancher` 的方式启动的，密码记录在容器的日志中。

1.  **首先获取容器 ID：**
    ```bash
    docker ps
    ```
2.  **查看日志搜索关键词：**
    ```bash
    docker logs  <容器ID>  2>&1 | grep "Bootstrap Password"
    ```
    你会看到类似一行：`Bootstrap Password: xxxxxxxx`

---

### 常见问题说明：

1.  **如果找不到 `bootstrap-secret`：**
    *   说明你可能已经登录过并修改了密码，或者你使用的是旧版本的 Rancher（v2.6 之前）。
    *   在旧版本中，第一次登录时是让你手动设置密码，没有初始随机密码。
2.  **用户名是什么？**
    *   默认的初始管理员用户名始终是：**`admin`**。
3.  **如果忘记了修改后的密码：**
    如果你已经设置过密码但忘了，需要通过重置命令（假设是 Docker 安装）：
    ```bash
    docker exec -ti <容器ID> reset-password
    ```

**由于你之前在尝试安装 RKE2：**
如果你的 RKE2 还没安装成功（因为长城宽带的报错），那么 Rancher 还没启动，自然也就没有密码。你需要先解决上一条回复中的下载问题，完成 RKE2 和 Rancher 的部署后，才能执行上述命令获取密码。

<!-- 跳转链接 -->
[⬆️ 返回目录](#catalog)  |  [文章开头 ➡️](#chap-rancher)