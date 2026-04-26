# bosswx.gzjjzhy.com HTTPS转发安装记录

## 1. 背景

目标是让子域名 `https://bosswx.gzjjzhy.com` 可以对外提供 HTTPS 访问，并在服务器内部转发到本机 HTTP 服务 `127.0.0.1:30080`。

最终目标链路：

```text
https://bosswx.gzjjzhy.com
  -> nginx:443
  -> http://127.0.0.1:30080
```

服务器信息：

- 公网 IP：`43.135.175.71`
- 系统：`Ubuntu`
- FRP 服务端：`frps`
- 域名：`gzjjzhy.com`
- 子域名：`bosswx.gzjjzhy.com`

## 2. 证书准备

本次使用的证书文件来自本地压缩包：

`C:\Users\16555\Documents\xwechat_files\wxid_e2im3dfkn4ee22_374c\msg\file\2026-04\gzjjzhy.com_nginx.zip`

压缩包内包含：

- `gzjjzhy.com_bundle.crt`
- `gzjjzhy.com_bundle.pem`
- `gzjjzhy.com.key`
- `gzjjzhy.com.csr`

证书主体验证结果：

- `CN=*.gzjjzhy.com`
- SAN 包含：
  - `*.gzjjzhy.com`
  - `gzjjzhy.com`

因此该证书可以覆盖：

- `bosswx.gzjjzhy.com`

本次实际部署到服务器的文件位置：

- `/etc/nginx/ssl/gzjjzhy.com_bundle.crt`
- `/etc/nginx/ssl/gzjjzhy.com.key`

## 3. 初始情况

开始时服务器上已经安装并运行了 `frps`，其配置文件位于：

`/root/frp/frps.toml`

初始配置只有：

```toml
bindPort = 7000
auth.token = "123456"
```

随后为了尝试让 `frps` 直接接 HTTPS，曾将其改为监听 `443`：

```toml
bindPort = 7000
vhostHTTPSPort = 443

auth.token = "123456"
```

验证结果：

- `frps` 可以监听 `443`
- 但从架构上更适合把 HTTPS 终止放到 `nginx`
- 最终方案调整为：`nginx` 终止 HTTPS，`frps` 保持普通代理能力

## 4. 最终采用方案

最终不再让 `frps` 直接处理 HTTPS，而是改成：

```text
公网 HTTPS
  -> nginx 处理证书和 TLS
  -> nginx 反向代理到 127.0.0.1:30080
  -> 后端服务继续走 HTTP
```

这样做的原因：

- 证书统一放在 `nginx`
- HTTPS 终止更符合常规运维方式
- 后端仍可保持 HTTP，不需要在 `frpc` 或业务服务内单独做 TLS
- 配置和排障都更直观

## 5. 实际安装与修改过程

### 5.1 上传证书

将本地腾讯云下载的证书上传到远端服务器，并存放到：

```text
/etc/nginx/ssl/gzjjzhy.com_bundle.crt
/etc/nginx/ssl/gzjjzhy.com.key
```

### 5.2 安装 Nginx

在服务器执行：

```bash
apt-get update
apt-get install -y nginx
```

### 5.3 调整 frps 配置

中间过程里曾临时把 `frps` 配成：

```toml
bindPort = 7000
vhostHTTPPort = 8080

auth.token = "123456"
```

然后让 `nginx` 先反代到 `127.0.0.1:8080`。

后续根据实际需要，又把 `nginx` 反代目标改成了：

```text
http://127.0.0.1:30080
```

因此最终不再需要 `vhostHTTPPort = 8080`，最后将其删除。

最终 `frps.toml` 内容为：

```toml
bindPort = 7000

auth.token = "123456"
```

最终 `frps` 配置文件路径：

`/root/frp/frps.toml`

### 5.4 配置 Nginx 站点

创建站点配置文件：

`/etc/nginx/sites-available/gzjjzhy.com.conf`

并链接到：

`/etc/nginx/sites-enabled/gzjjzhy.com.conf`

最终站点配置如下：

```nginx
server {
    listen 443 ssl http2;
    server_name gzjjzhy.com *.gzjjzhy.com;

    ssl_certificate /etc/nginx/ssl/gzjjzhy.com_bundle.crt;
    ssl_certificate_key /etc/nginx/ssl/gzjjzhy.com.key;

    ssl_session_timeout 10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://127.0.0.1:30080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header Connection "";
    }
}
```

### 5.5 处理端口冲突

安装 `nginx` 后第一次启动失败，原因是：

- `80` 端口已经被 `frps` 占用

错误现象：

```text
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
```

处理方式：

- 不让 `nginx` 监听 `80`
- 只让 `nginx` 监听 `443`

因此最终 `nginx` 只承担 HTTPS 入口，不负责 `80 -> 443` 跳转。

### 5.6 腾讯云防火墙放行 443

服务器内 `nginx` 已监听 `443`，但最初外部访问超时。

排查结果：

- DNS 已正确解析到 `43.135.175.71`
- 服务器内 `nginx` 已监听 `0.0.0.0:443`
- `ufw` 为 `inactive`
- `iptables` 默认 `ACCEPT`
- 外网 `443` 超时

最终发现问题在腾讯云防火墙未放行 `443`。

放行后，外网访问恢复正常。

## 6. 最终状态

### 6.1 frps 配置

```toml
bindPort = 7000

auth.token = "123456"
```

### 6.2 Nginx 监听状态

最终监听关系：

- `443` -> `nginx`
- `7000` -> `frps`
- `30080` -> `frps`
- `80` -> `frps`

说明：

- `30080` 由 `frps` 当前代理能力提供
- `nginx` 只负责 HTTPS 入口和证书

### 6.3 实际访问链路

```text
bosswx.gzjjzhy.com:443
  -> nginx
  -> proxy_pass http://127.0.0.1:30080
```

## 7. 验证结果

### 7.1 DNS 解析

已确认：

- `bosswx.gzjjzhy.com -> 43.135.175.71`

### 7.2 公网 443 连通性

外部测试结果：

- `bosswx.gzjjzhy.com:443` 可连通

### 7.3 HTTPS 访问结果

外部执行：

```bash
curl -k -I https://bosswx.gzjjzhy.com
```

返回：

```text
HTTP/1.1 200 OK
Server: nginx/1.24.0 (Ubuntu)
```

说明：

- 证书加载正常
- 公网 443 放通正常
- Nginx 反代链路正常

## 8. 关键文件路径

远端服务器关键文件如下：

- `frps` 程序：`/root/frp/frps`
- `frps` 配置：`/root/frp/frps.toml`
- `frps` systemd：`/etc/systemd/system/frps.service`
- `nginx` 证书目录：`/etc/nginx/ssl`
- `nginx` 站点配置：`/etc/nginx/sites-available/gzjjzhy.com.conf`
- `nginx` 启用链接：`/etc/nginx/sites-enabled/gzjjzhy.com.conf`

## 9. 常用检查命令

查看 `frps` 配置：

```bash
cat /root/frp/frps.toml
```

查看 `nginx` 站点配置：

```bash
cat /etc/nginx/sites-available/gzjjzhy.com.conf
```

查看监听端口：

```bash
ss -lntp | grep -E '(:443|:7000|:30080|:80)\b'
```

查看 `frps` 状态：

```bash
systemctl status frps
```

查看 `nginx` 状态：

```bash
systemctl status nginx
```

校验 `nginx` 配置：

```bash
nginx -t
```

重载 `nginx`：

```bash
systemctl reload nginx
```

重启 `frps`：

```bash
systemctl restart frps
```

公网验证：

```bash
curl -k -I https://bosswx.gzjjzhy.com
```

## 10. 后续接入说明

如果后续需要把 `bosswx.gzjjzhy.com` 真正接到某个业务服务，而不是当前的默认响应页，需要确认：

- `127.0.0.1:30080` 后面到底挂的是哪一个实际服务
- 该服务是否已经返回正确的业务接口或页面

如果后续继续用 `frp` 做转发，则只需要保证：

- `nginx` 保持 `443 -> 30080`
- `30080` 背后是正确的目标服务

## 11. 风险与建议

- 当前 `auth.token = "123456"` 较弱，建议尽快更换为高强度随机值
- 本次操作过程中曾暴露服务器 `root` 密码，建议尽快修改
- 当前 `80` 端口仍由 `frps` 占用，如果未来需要做 `http -> https` 跳转，需要先梳理 `80` 的现有用途
- 如果未来有更多子域名复用该证书，`*.gzjjzhy.com` 通配符可继续覆盖一级子域名

## 12. 结论

本次已完成：

- 腾讯云证书上传并部署到 `nginx`
- `bosswx.gzjjzhy.com` 的 HTTPS 入口开通
- `nginx` 反向代理到 `127.0.0.1:30080`
- 腾讯云防火墙 `443` 放行
- 公网访问验证成功

最终可用地址：

`https://bosswx.gzjjzhy.com`
