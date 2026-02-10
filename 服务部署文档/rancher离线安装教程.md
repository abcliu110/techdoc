<div id="chap-rancherinstall"></div>

[⬆️ 返回目录](#catalog)


## rancher离线安装教程

---

### 第一阶段：物资准备（Windows 主机操作）

请在 Windows 上开启 VPN，下载以下 **v1.34.3+rke2r3** 版本的 4 个核心文件。请确保文件名完全一致：

1.  **二进制程序**: `rke2.linux-amd64.tar.gz`
2.  **核心镜像包**: `rke2-images.linux-amd64.tar.zst` (约 800MB)
3.  **校验文件**: `sha256sum-amd64.txt`
4.  **安装脚本**: [点击此处下载 install.sh](https://rancher-mirror.rancher.cn/rke2/install.sh)（国内镜像源版）

---

### 第二阶段：环境大扫除（Ubuntu 虚拟机操作）

在开始安装前，必须彻底清理旧环境并关闭干扰。

```bash
# 1. 停止旧服务
sudo systemctl stop rke2-server || true

# 2. 彻底禁用 Swap（etcd 启动成功的关键，不关必报错）
sudo swapoff -a
sudo sed -i '/swap/s/^/#/' /etc/fstab

# 3. 创建 RKE2 必须的目录结构
sudo mkdir -p /etc/rancher/rke2
sudo mkdir -p /var/lib/rancher/rke2/agent/images
sudo mkdir -p /root/rke2-artifacts
```

---

### 第三阶段：物资搬运（WinSCP + Linux 命令）

这一步是将文件从 Windows 真正送入 RKE2 运行位置的关键。

#### 1. WinSCP 上传
*   打开 WinSCP，连接你的虚拟机。
*   将 Windows 上的 4 个文件上传到虚拟机的 **/tmp** 目录。

#### 2. Linux 终端执行搬运（请直接复制以下命令）
我们要将文件从 `/tmp` 挪到专门的离线物资库和镜像库：

```bash
# 将安装包和脚本挪到离线物资库
sudo mv /tmp/rke2.linux-amd64.tar.gz /root/rke2-artifacts/
sudo mv /tmp/sha256sum-amd64.txt /root/rke2-artifacts/
sudo mv /tmp/install.sh /root/rke2-artifacts/
sudo chmod +x /root/rke2-artifacts/install.sh

# 将核心镜像包（粮食）挪到 RKE2 指定的自动加载目录
sudo mv /tmp/rke2-images.linux-amd64.tar.zst /var/lib/rancher/rke2/agent/images/

# 检查文件是否到位（确保列出的文件大小不为 0）
ls -lh /root/rke2-artifacts/
ls -lh /var/lib/rancher/rke2/agent/images/
```

---

### 第四阶段：触发离线安装

这一步利用 `install.sh` 注册系统服务，但通过变量强制它使用本地文件。

```bash
# 1. 设置环境变量，指向你的物资库
export INSTALL_RKE2_ARTIFACT_PATH=/root/rke2-artifacts

# 2. 执行安装脚本
sudo -E sh /root/rke2-artifacts/install.sh

# 3. 编写 RKE2 配置文件（防止启动后去外网拉取其他插件）
cat <<EOF | sudo tee /etc/rancher/rke2/config.yaml
write-kubeconfig-mode: "0644"
system-default-registry: "registry.cn-hangzhou.aliyuncs.com"
EOF
```

---

### 第五阶段：配置系统代理（可选）

虽然是离线安装，但如果后续 K8s 内部需要通过你的主机代理（7897 端口）访问外网，请执行：

```bash
sudo mkdir -p /etc/systemd/system/rke2-server.service.d/
cat <<EOF | sudo tee /etc/systemd/system/rke2-server.service.d/proxy.conf
[Service]
Environment="HTTP_PROXY=http://192.168.80.1:7897"
Environment="HTTPS_PROXY=http://192.168.80.1:7897"
Environment="NO_PROXY=localhost,127.0.0.1,10.42.0.0/16,10.43.0.0/16,192.168.0.0/16"
EOF
```

---

### 第六阶段：启动与生死时速

启动 RKE2 并观察日志。

```bash
# 1. 重载系统配置并启动
sudo systemctl daemon-reload
sudo systemctl enable rke2-server
sudo systemctl start rke2-server

# 2. 实时查看日志（按下 Ctrl+C 退出日志查看）
sudo journalctl -u rke2-server -f
```

**日志观察要点：**
*   你会看到类似 `Importing images from...` 的字样，这是在加载那个 800MB 的镜像包。
*   只要没有出现 `Connection Refused` 或 `EOF`，就耐心等 2 分钟。

---

### 第七阶段：配置 kubectl 环境

安装完成后，让系统识别 `kubectl` 命令。

```bash
# 1. 将 RKE2 二进制目录加入系统路径
echo 'export PATH=$PATH:/var/lib/rancher/rke2/bin' >> ~/.bashrc
source ~/.bashrc

# 2. 配置 Kubeconfig 访问权限
mkdir -p ~/.kube
sudo cp /etc/rancher/rke2/rke2.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config

# 3. 验收成果
kubectl get nodes
kubectl get pods -A
```

---

### 给网管的最后避坑总结：
1.  **install.sh 的作用**：它在这里充当了“安装器”，负责把二进制文件解压到 `/usr/local` 并且把 RKE2 注册成 Ubuntu 的 `systemd` 服务，省去了你手动写服务文件的麻烦。
2.  **不晃动的逻辑**：因为你有网但被拦截，所以我们的策略是：**用外网下载好的“干货”，在内网环境“假装离线”安装**。
3.  **内存提醒**：RKE2 v1.34 比较沉重，如果虚拟机内存低于 4G，`etcd` 极大概率启动失败。建议分配 8G。

<!-- 跳转链接 -->
[⬆️ 返回目录](#catalog)  |  [文章开头 ➡️](#chap-rancherinstall)