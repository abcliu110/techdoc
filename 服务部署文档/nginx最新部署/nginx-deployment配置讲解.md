# nginx-deployment.yaml 中 Nginx 配置逐行讲解

本文基于 `D:\mywork\techdoc\服务部署文档\nginx-deployment.yaml` 整理，只解释该部署文件中 ConfigMap 生成的 Nginx 配置，并指出它与线上 Nginx 配置的差异。

## 一、部署文件中的配置来源

该部署文件通过 ConfigMap 提供 Nginx 业务配置：

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: nms4cloud
data:
  default.conf: |
    ...
```

Deployment 再把这个 ConfigMap 挂载到 Nginx 容器：

```yaml
volumeMounts:
  - name: nginx-config
    mountPath: /etc/nginx/conf.d
    readOnly: true
```

因此容器启动后，Nginx 会通过官方主配置中的：

```nginx
include /etc/nginx/conf.d/*.conf;
```

加载这个 ConfigMap 里的 `default.conf`。

注意：这个部署文件和线上不同。线上 `/etc/nginx/conf.d/` 来自 CFS/NFS；这里来自 ConfigMap。

## 二、default.conf 完整逐行讲解

```nginx
upstream api_bakend_wss {                                      # 定义一个上游后端组，供 /mqtt 反向代理使用。
    ip_hash;                                                   # 按客户端 IP 做粘性分配；同一客户端 IP 尽量落到同一后端。
    server emqx-54.nms4cloud.svc.cluster.local:8083 max_fails=0 weight=1; # 后端是 K8s Service emqx-54 的 8083 端口；max_fails=0 表示不按失败次数摘除；weight=1 表示权重为 1。
}                                                              # upstream 结束。

server {                                                       # 定义一个 Nginx 虚拟主机。
    listen 80;                                                 # 监听 IPv4 的 80 端口。CLB/NodePort 转进来后最终到容器 80。
    listen [::]:80;                                            # 监听 IPv6 的 80 端口。
    server_name api.lmnsaas.com;                               # 只匹配 Host 为 api.lmnsaas.com 的请求。

    #access_log /var/log/nginx/host.access.log main;           # 被注释掉了，不生效；如果启用，会为该虚拟主机单独写访问日志。
    try_files $uri /index.html;                                # server 级 try_files：尝试本地 URI 文件，找不到回退 /index.html；但 location / 中有 proxy_pass，所以首页主要走 COS。

    gzip on;                                                   # 开启 gzip 压缩。
    gzip_min_length 1024;                                      # 响应体大于 1024 字节才压缩。
    gzip_buffers 4 16k;                                        # gzip 压缩缓冲区：4 个 16k buffer。
    gzip_types text/plain application/javascript application/x-javascript text/css application/xml text/javascript application/x-httpd-php image/jpeg image/gif image/png; # 指定参与 gzip 的响应类型。

    location / {                                               # 匹配根路径和普通前端资源请求。
        root /usr/share/nginx/html;                            # 设置本地静态根目录；但同一 location 有 proxy_pass，普通请求实际代理到 COS。
        proxy_pass https://web-for-nginx-1251303505.cos-website.ap-guangzhou.myqcloud.com; # 把首页和普通前端资源转发到 COS 静态网站 web-for-nginx。
    }                                                          # 根路径 location 结束。

    location /pictures/ {                                      # 匹配 /pictures/ 图片资源路径。
        root /usr/share/nginx/html;                            # 设置本地静态根目录；但同一 location 有 proxy_pass，普通请求实际代理到 COS。
        # proxy_pass https://p-lmnsaas-com-1251303505.cos.ap-guangzhou.myqcloud.com; # 被注释掉了，不生效；这是旧的或备用 COS 地址。
        proxy_pass https://chain-pictures-01-1251303505.cos-website.ap-guangzhou.myqcloud.com/; # 把 /pictures/ 代理到图片 COS 静态网站。
    }                                                          # /pictures/ location 结束。

    location /mqtt {                                           # 匹配 /mqtt，用于 MQTT over WebSocket。
        proxy_pass http://api_bakend_wss/mqtt;                 # 转发到 upstream api_bakend_wss，也就是 emqx-54:8083/mqtt。

        # 代理到上面的地址去，格式：http://域名:端口号。       # 原配置注释，说明 proxy_pass 目标格式。
        proxy_http_version 1.1;                                # WebSocket 协议升级需要 HTTP/1.1。
        proxy_set_header Upgrade $http_upgrade;                # 透传客户端的 Upgrade 请求头。
        proxy_set_header Connection "Upgrade";                 # 告诉后端这是协议升级连接。
        proxy_set_header Sec-WebSocket-Protocol mqtt;          # 指定 WebSocket 子协议为 mqtt。
        proxy_connect_timeout 5s;                              # 连接后端超时时间 5 秒。
        proxy_read_timeout 60000s;                             # 读取后端响应超时时间很长，用于长连接。
        proxy_send_timeout 60000s;                             # 向后端发送数据超时时间很长，用于长连接。
    }                                                          # /mqtt location 结束。

    location /api/ {                                           # 匹配 /api/ 开头的接口请求。
        proxy_pass http://gateway.nms4cloud.svc.cluster.local:8080/api/; # 转发到 nms4cloud 命名空间下 gateway Service 的 8080 端口，并映射到 /api/。
        proxy_redirect default;                                # 使用 Nginx 默认重定向改写规则。
        proxy_set_header X-Real-IP $remote_addr;               # 把 Nginx 看到的直接连接方 IP 传给后端；经过 CLB 时不一定是真实用户 IP。
        proxy_set_header Host $http_host;                      # 把客户端原始 Host 传给后端，例如 api.lmnsaas.com。
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 追加代理链路 IP，通常用于保留真实客户端 IP 链路。
        proxy_set_header Connection Close;                     # 告诉后端处理完请求后关闭连接，减少连接复用。
        proxy_set_header X-Forwarded-For $remote_addr;         # 这里会覆盖上一行 X-Forwarded-For，导致代理链路可能丢失，这是明显缺陷。
        error_page 404 /404.html;                              # 404 时内部跳转到 /404.html。
        error_page 500 502 503 504 /50x.html;                  # 服务器错误时内部跳转到 /50x.html。
    }                                                          # /api/ location 结束。

    location /spapi/ {                                         # 匹配 /spapi/ 开头的接口请求，常用于支付或特殊 API 前缀。
        proxy_pass http://gateway.nms4cloud.svc.cluster.local:8080/api/; # 外部 /spapi/ 会映射到内部 gateway 的 /api/。
        proxy_redirect default;                                # 使用 Nginx 默认重定向改写规则。
        proxy_set_header X-Real-IP $remote_addr;               # 把 Nginx 看到的直接连接方 IP 传给后端。
        proxy_set_header Host $http_host;                      # 把客户端原始 Host 传给后端。
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 追加代理链路 IP。
        proxy_set_header Connection Close;                     # 告诉后端关闭连接复用。
        proxy_set_header X-Forwarded-For $remote_addr;         # 覆盖上一行 X-Forwarded-For，导致代理链路可能丢失，这是明显缺陷。
        error_page 404 /404.html;                              # 404 时内部跳转到 /404.html。
        error_page 500 502 503 504 /50x.html;                  # 服务器错误时内部跳转到 /50x.html。
    }                                                          # /spapi/ location 结束。

    #error_page 404 /404.html;                                 # 被注释掉，不生效。

    # redirect server error pages to the static page /50x.html # 原配置注释：服务器错误重定向到静态错误页。
    error_page 500 502 503 504 /50x.html;                      # server 级错误页配置。

    location = /50x.html {                                     # 精确匹配 /50x.html。
        root /usr/share/nginx/html;                            # 从 /usr/share/nginx/html 读取 50x.html。
    }                                                          # /50x.html location 结束。
}                                                              # server 结束。
```

## 三、这个配置实际能处理什么

这个 ConfigMap 只定义了一个虚拟主机：

```text
api.lmnsaas.com
```

它能处理的路径：

| 路径 | 目标 |
| --- | --- |
| `/` | `https://web-for-nginx-1251303505.cos-website.ap-guangzhou.myqcloud.com` |
| `/pictures/` | `https://chain-pictures-01-1251303505.cos-website.ap-guangzhou.myqcloud.com/` |
| `/mqtt` | `emqx-54.nms4cloud.svc.cluster.local:8083/mqtt` |
| `/api/` | `gateway.nms4cloud.svc.cluster.local:8080/api/` |
| `/spapi/` | `gateway.nms4cloud.svc.cluster.local:8080/api/` |
| `/50x.html` | `/usr/share/nginx/html/50x.html` |

## 四、和线上 Nginx 的关键差异

线上配置至少有两个业务 server：

```text
gzjj_lmnsaas_com.conf
p_lmnsaas_com.conf
```

而这个部署文件只有一个 `default.conf`，且只有：

```text
server_name api.lmnsaas.com;
```

缺失的线上域名包括：

```text
gzjj.lmnsaas.com
shop.gzjjzhy.com
wx.gzjjzhy.com
h5.gzjjzhy.com
api.gzjjzhy.com
mp.gzjjzhy.com
paygzjj.lmnsaas.com
p.gzjjzhy.com
```

尤其是支付服务需要的：

```text
paygzjj.lmnsaas.com
p.gzjjzhy.com
```

当前部署文件没有对应的支付 server，因此不能实现线上支付前端入口。

## 五、支付服务缺失点

线上支付配置类似：

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name paygzjj.lmnsaas.com p.gzjjzhy.com;

    location / {
        proxy_pass https://p-lmnsaas-com-1251303505.cos-website.ap-guangzhou.myqcloud.com;
    }

    location /api/ {
        proxy_pass http://gateway/api/;
    }

    location /spapi/ {
        proxy_pass http://gateway/api/;
    }
}
```

当前部署文件缺少这整个 `server`，所以：

```text
p.gzjjzhy.com 无法匹配支付 server
paygzjj.lmnsaas.com 无法匹配支付 server
支付前端 COS p-lmnsaas-com-1251303505.cos-website.ap-guangzhou.myqcloud.com 没有被代理
支付相关 /api/ 和 /spapi/ 规则没有独立域名入口
```

## 六、其他部署层面的缺陷

| 位置 | 当前配置 | 问题 |
| --- | --- | --- |
| PVC | `storageClassName: local-path`、`ReadWriteOnce` | 本地盘不适合多副本和节点漂移 |
| Deployment | `replicas: 1` | 不是线上双副本高可用 |
| Container | `hostPort: 8081` | 线上通过 Service NodePort 暴露，不需要 hostPort |
| Service | `nodePort: 30080` | 线上 CLB 后端是 `30008`，端口不一致 |
| 镜像 | `nginx:1.25.3` | 线上是 `nginx:1.27.5` |
| ConfigMap | 只有一个 `default.conf` | 缺少线上多个 server 配置 |
| API 请求头 | 重复设置 `X-Forwarded-For` | 后一行覆盖前一行，真实代理链路可能丢失 |

## 七、结论

这个部署文件只能实现一个简化版 Nginx：

```text
api.lmnsaas.com
  -> web-for-nginx COS
  -> gateway API
  -> emqx-54 MQTT
```

它不能完整实现线上 Nginx，尤其不能满足支付服务，因为缺少：

```text
p.gzjjzhy.com / paygzjj.lmnsaas.com 虚拟主机
p-lmnsaas-com COS 静态网站代理
与线上一致的 NodePort 30008
与线上一致的多域名 server_name
与线上一致的高可用部署方式
```

## 八、NodePort 通过 IP 访问与 default_server

当前 Service 使用的是 NodePort：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  namespace: nms4cloud
spec:
  type: NodePort
  ports:
    - name: http
      port: 80
      targetPort: 80
      nodePort: 30080
```

所以可以通过任意可达的 K8s 节点 IP 加 NodePort 访问 Nginx：

```text
http://192.168.1.119:30080/user/login
```

访问链路是：

```text
浏览器
  -> 192.168.1.119:30080
  -> K8s Service nginx NodePort
  -> nginx Pod:80
  -> Nginx server/location 配置
```

这里要区分两个概念：

```text
NodePort 负责把流量送到 Nginx Pod
server_name 负责让 Nginx 按 Host 域名匹配虚拟主机
```

当你访问：

```text
http://192.168.1.119:30080/user/login
```

浏览器发送的 Host 是：

```http
Host: 192.168.1.119:30080
```

它并不等于当前配置里的：

```nginx
server_name api.lmnsaas.com;
```

但 Nginx 不会因为 `server_name` 不匹配就直接拒绝请求。对于同一个 `listen 80`，如果没有任何 `server_name` 匹配，Nginx 会选择一个默认 server 来处理请求。

默认 server 的选择规则可以简单理解为：

```text
1. 如果某个 server 的 listen 写了 default_server，就用它
2. 如果没有显式 default_server，就用同一 listen 地址和端口下最先加载的 server
```

### 1. 显式 default_server 写法

可以这样写：

```nginx
server {
    listen 80 default_server;          # IPv4 默认虚拟主机。
    listen [::]:80 default_server;     # IPv6 默认虚拟主机。
    server_name _;                     # 习惯写法，表示兜底名称，不是特殊语法。

    return 444;                        # 直接关闭连接，不返回响应。也可以改成 404。
}
```

含义：

```text
所有没有匹配到明确 server_name 的请求
  -> 进入这个 default_server
  -> 直接关闭或返回错误
```

如果不想关闭连接，也可以返回 404：

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    return 404;
}
```

这样直接用 IP 访问：

```text
http://192.168.1.119:30080/
```

就不会误进入业务站点，而是返回 404。

### 2. 多域名业务 server 写法

业务域名继续单独写：

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name api.lmnsaas.com;

    location / {
        proxy_pass https://web-for-nginx-1251303505.cos-website.ap-guangzhou.myqcloud.com;
    }

    location /api/ {
        proxy_pass http://gateway.nms4cloud.svc.cluster.local:8080/api/;
    }
}

server {
    listen 80;
    listen [::]:80;
    server_name p.gzjjzhy.com paygzjj.lmnsaas.com;

    location / {
        proxy_pass https://p-lmnsaas-com-1251303505.cos-website.ap-guangzhou.myqcloud.com;
    }

    location /api/ {
        proxy_pass http://gateway.nms4cloud.svc.cluster.local:8080/api/;
    }
}
```

这样请求匹配结果是：

```text
Host: api.lmnsaas.com
  -> 命中 api.lmnsaas.com 的 server

Host: p.gzjjzhy.com
  -> 命中支付 server

Host: 192.168.1.119:30080
  -> 不匹配任何业务 server
  -> 命中 default_server
```

### 3. 用 NodePort 测试指定域名

即使没有 DNS，也可以通过 `Host` 请求头测试指定虚拟主机：

```bash
curl -H "Host: api.lmnsaas.com" http://192.168.1.119:30080/user/login
```

测试支付域名：

```bash
curl -H "Host: p.gzjjzhy.com" http://192.168.1.119:30080/
```

这时虽然访问的是 IP 和 NodePort，但 Nginx 看到的 Host 是你手动指定的域名，所以会按对应 `server_name` 匹配。

### 4. 为什么建议加 default_server

如果没有 default_server，直接用 IP 访问可能误命中第一个业务 server。

风险包括：

```text
IP 访问暴露业务站点
错误 Host 也能访问到前端页面
多个 server 后，请求可能落到非预期站点
排查时误以为 server_name 生效了，实际只是命中了默认 server
```

建议生产配置至少有一个兜底 server：

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    return 404;
}
```

然后所有业务域名单独写明确的 `server_name`。
