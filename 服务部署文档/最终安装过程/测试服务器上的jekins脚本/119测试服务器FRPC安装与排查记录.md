# 119测试服务器 FRPC 安装与排查记录

## 1. 背景

- 测试服务器：`192.168.1.119`
- 登录用户：`jj`
- FRP 服务端地址：`43.135.175.71`
- FRP 服务端端口：`7000`
- Token：`123456`
- 客户端程序路径：`/opt/frp/frpc`
- 客户端配置路径：`/etc/frp/frpc.toml`

本次目标是在 Ubuntu 测试服务器 `192.168.1.119` 上安装并启动 `frpc`，并将 `80`、`9898`、`9999`、`30080` 四个端口按需映射到 FRP 服务端。

## 2. 安装过程

### 2.1 安装 `frpc`

执行命令：

```bash
sudo apt update
sudo apt install -y wget tar

cd /tmp
ARCH=$(dpkg --print-architecture)
case "$ARCH" in
  amd64) FRP_ARCH=amd64 ;;
  arm64) FRP_ARCH=arm64 ;;
  *) echo "不支持的架构: $ARCH"; exit 1 ;;
esac

wget https://github.com/fatedier/frp/releases/download/v0.68.1/frp_0.68.1_linux_${FRP_ARCH}.tar.gz
tar -xzf frp_0.68.1_linux_${FRP_ARCH}.tar.gz

sudo mkdir -p /opt/frp /etc/frp
sudo install -m 755 frp_0.68.1_linux_${FRP_ARCH}/frpc /opt/frp/frpc
```

版本验证：

```bash
/opt/frp/frpc --version
```

实际结果：

```text
0.68.1
```

## 3. 最终客户端配置

`/etc/frp/frpc.toml` 最终使用如下内容：

```toml
serverAddr = "43.135.175.71"
serverPort = 7000
auth.token = "123456"

[[proxies]]
name = "web-80"
type = "tcp"
localIP = "127.0.0.1"
localPort = 80
remotePort = 80

[[proxies]]
name = "api-9898"
type = "tcp"
localIP = "127.0.0.1"
localPort = 9898
remotePort = 9898

[[proxies]]
name = "netty-9999"
type = "tcp"
localIP = "127.0.0.1"
localPort = 9999
remotePort = 9999

[[proxies]]
name = "port-30080"
type = "tcp"
localIP = "127.0.0.1"
localPort = 30080
remotePort = 30080
```

配置校验命令：

```bash
/opt/frp/frpc verify -c /etc/frp/frpc.toml
```

校验结果：

```text
frpc: the configuration file /etc/frp/frpc.toml syntax is ok
```

## 4. `systemd` 服务创建与启动

### 4.1 服务文件

创建文件：`/etc/systemd/system/frpc.service`

内容如下：

```ini
[Unit]
Description=FRP Client
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/opt/frp/frpc -c /etc/frp/frpc.toml
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### 4.2 启动命令

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now frpc
sudo systemctl status frpc --no-pager -l
```

### 4.3 当前状态

实际验证结果：

- `frpc.service` 已创建
- `frpc.service` 已启用开机自启
- 当前状态为 `active (running)`

可用查看命令：

```bash
sudo systemctl status frpc --no-pager -l
sudo journalctl -u frpc -f
```

## 5. 本次排查过程总结

### 5.1 前期遇到的问题

前期多次报错，主要原因如下：

1. `frpc.toml` 复制粘贴过程中出现块结构丢失
   - 比如缺少 `[[proxies]]`
   - 导致 `localIP`、`localPort` 被当成顶层字段解析
   - 报错表现为 `json: unknown field "localIP"` 或 `json: unknown field "localPort"`

2. 部分代理块字段缺失
   - 比如某个 `[[proxies]]` 下缺少 `name` 或 `type`
   - 报错表现为 `unknown proxy type`

3. 一度怀疑 `token` 不一致
   - 但在最终配置正确后，客户端已经成功登录服务端
   - 因此最终确认 `token` 是正确的

### 5.2 关键验证结论

在 `192.168.1.119` 上验证到：

- `frpc` 版本正确：`0.68.1`
- 配置语法正确
- `frpc` 服务端登录成功
- `frpc` 已通过 `systemd` 启动成功

## 6. 端口可用性检查结果

对 `192.168.1.119` 本机端口的直接验证结果如下。

### 6.1 可访问端口

- `127.0.0.1:80` 可访问
  - `curl -I http://127.0.0.1:80`
  - 返回 `HTTP/1.1 404 Not Found`

- `127.0.0.1:30080` 可访问
  - `curl -I http://127.0.0.1:30080`
  - 返回 `HTTP/1.1 200 OK`
  - 响应头显示 `Server: nginx/1.25.3`

### 6.2 当前不可访问端口

- `127.0.0.1:9898` 不通
- `127.0.0.1:9999` 不通

对应服务日志中持续出现：

```text
[api-9898] connect to local service [127.0.0.1:9898] error: dial tcp 127.0.0.1:9898: connect: connection refused
[netty-9999] connect to local service [127.0.0.1:9999] error: dial tcp 127.0.0.1:9999: connect: connection refused
```

这说明：

- `frpc` 本身已经正常工作
- 问题不在 FRP 客户端和服务端连接
- 问题在于 `192.168.1.119` 本地没有程序监听 `9898` 和 `9999`

## 7. 当前最终结论

### 7.1 已完成事项

- 已在 `192.168.1.119` 安装 `frpc`
- 已完成 `/etc/frp/frpc.toml` 配置
- 已创建并启用 `frpc.service`
- 已确认 `frpc` 可成功连接 `43.135.175.71:7000`

### 7.2 当前可正常映射的端口

- `80`
- `30080`

### 7.3 当前会报错的端口

- `9898`
- `9999`

原因：本机对应端口没有监听服务。

## 8. 后续建议

### 方案一：保留当前完整配置

适用于后续还会补齐 `9898`、`9999` 本地服务的场景。
这种情况下 `frpc` 服务可以继续运行，但日志会持续打印这两个端口的拒绝连接错误。

### 方案二：临时只保留可用端口

如果当前只需要 `80` 和 `30080`，建议临时将 `frpc.toml` 改为仅保留以下两个代理：

```toml
[[proxies]]
name = "web-80"
type = "tcp"
localIP = "127.0.0.1"
localPort = 80
remotePort = 80

[[proxies]]
name = "port-30080"
type = "tcp"
localIP = "127.0.0.1"
localPort = 30080
remotePort = 30080
```

这样可以避免 `9898`、`9999` 持续报错。

## 9. 常用维护命令

查看服务状态：

```bash
sudo systemctl status frpc --no-pager -l
```

查看实时日志：

```bash
sudo journalctl -u frpc -f
```

重启服务：

```bash
sudo systemctl restart frpc
```

校验配置：

```bash
/opt/frp/frpc verify -c /etc/frp/frpc.toml
```