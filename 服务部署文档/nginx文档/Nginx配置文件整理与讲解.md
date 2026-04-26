# Nginx 配置文件整理与逐行讲解

本文基于 `nginx -T` 输出整理。讲解直接写在配置代码块内，紧跟对应指令，便于对照真实配置理解。

## 一、nginx -T 命令含义

`nginx -T` 是 Nginx 的配置检查和完整配置打印命令。

它会做两件事：

```text
1. 检查 Nginx 配置语法是否正确
2. 把最终加载的完整配置打印出来，包括 include 进来的配置文件
```

当前执行结果中有：

```text
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

这表示配置语法正确，Nginx 可以成功加载这些配置。

`nginx -T` 和 `nginx -t` 的区别：

| 命令 | 作用 | 是否打印完整配置 |
| --- | --- | --- |
| `nginx -t` | 只检查配置语法 | 否 |
| `nginx -T` | 检查配置语法，并打印完整配置 | 是 |

为什么本文使用 `nginx -T`：

```text
Nginx 主配置 /etc/nginx/nginx.conf 里有 include /etc/nginx/conf.d/*.conf
只看 nginx.conf 看不到业务域名和转发规则
nginx -T 会把 include 后的 default.conf、gzjj_lmnsaas_com.conf、p_lmnsaas_com.conf 一起打印出来
所以 nginx -T 能看到 Nginx 实际运行时加载的配置全貌
```

执行 `nginx -T` 时出现过这个警告：

```text
could not build optimal proxy_headers_hash,
you should increase either proxy_headers_hash_max_size: 512
or proxy_headers_hash_bucket_size: 64
```

这个警告不是语法错误。只要后面出现：

```text
syntax is ok
test is successful
```

就说明配置可以正常加载。该警告只是提示代理请求头较多，Nginx 认为 hash 表大小不够理想。

在当前容器中执行：

```bash
nginx -T
```

在 Kubernetes 外部可以执行：

```powershell
kubectl -n default exec deploy/nginx -- nginx -T
```

## 二、配置加载边界

当前 Nginx 实际加载 5 个文件：

```text
/etc/nginx/nginx.conf                  镜像内置，当前不能通过 CFS 直接修改
/etc/nginx/mime.types                  镜像内置，当前不能通过 CFS 直接修改
/etc/nginx/conf.d/default.conf         CFS/NFS 挂载，可直接修改
/etc/nginx/conf.d/gzjj_lmnsaas_com.conf CFS/NFS 挂载，可直接修改
/etc/nginx/conf.d/p_lmnsaas_com.conf   CFS/NFS 挂载，可直接修改
```

Deployment 只挂载了：

```yaml
mountPath: /etc/nginx/conf.d/
```

所以业务域名、路径、转发规则主要通过 `/etc/nginx/conf.d/*.conf` 管理。

## 三、Nginx 虚拟主机原理

Nginx 的“虚拟主机”本质上是：同一个 Nginx 进程监听同一个端口，但根据请求里的 `Host` 域名，把请求分发到不同的 `server {}` 配置块。

例如多个域名都进入同一个入口：

```text
h5.gzjjzhy.com   -> 同一个 CLB -> 同一个 nginx:80
shop.gzjjzhy.com -> 同一个 CLB -> 同一个 nginx:80
api.gzjjzhy.com  -> 同一个 CLB -> 同一个 nginx:80
```

Nginx 区分它们的关键是 HTTP 请求头里的 `Host`。

用户访问：

```text
https://h5.gzjjzhy.com/api/user
```

浏览器会发送类似请求头：

```http
Host: h5.gzjjzhy.com
```

Nginx 收到请求后，会用这个 `Host` 去匹配配置里的 `server_name`。

典型配置：

```nginx
server {                              # 一个 server 块就是一个虚拟主机。
    listen 80;                        # 这个虚拟主机监听 80 端口。
    server_name h5.gzjjzhy.com;       # Host 为 h5.gzjjzhy.com 的请求会命中这里。

    location / {                      # 命中虚拟主机后，再按 URL 路径匹配 location。
        proxy_pass https://h5-cos.example.com; # 把请求转发到 h5 对应的静态站点。
    }
}

server {                              # 第二个虚拟主机。
    listen 80;                        # 同样监听 80 端口。
    server_name shop.gzjjzhy.com;     # Host 为 shop.gzjjzhy.com 的请求会命中这里。

    location / {                      # 匹配 shop 的路径。
        proxy_pass https://shop-cos.example.com; # 把请求转发到 shop 对应的静态站点。
    }
}
```

这两个 `server` 都监听 `80`，但因为 `server_name` 不同，Nginx 可以把不同域名分发到不同规则。

请求匹配顺序可以理解为：

```text
1. 先看请求进入哪个端口，例如 listen 80
2. 在 listen 80 的 server 中，用 Host 匹配 server_name
3. 找到 server 后，再用 URL 路径匹配 location
4. 最后执行 location 里的 proxy_pass、root、alias 等动作
```

当前真实配置里，多个域名写在同一个 `server_name` 中：

```nginx
server_name gzjj.lmnsaas.com shop.gzjjzhy.com wx.gzjjzhy.com h5.gzjjzhy.com api.gzjjzhy.com mp.gzjjzhy.com;
```

含义是这些域名共用同一个虚拟主机配置。也就是说：

```text
gzjj.lmnsaas.com
shop.gzjjzhy.com
wx.gzjjzhy.com
h5.gzjjzhy.com
api.gzjjzhy.com
mp.gzjjzhy.com
```

都会进入同一个 `server {}`，然后再按路径进入不同 `location`：

```text
/          -> proxy_pass 到 shop COS 静态网站
/api/      -> proxy_pass 到 gateway/api/
/spapi/    -> proxy_pass 到 gateway/api/
/mqtt      -> proxy_pass 到 emqx54:8083
/pictures/ -> proxy_pass 到 pictures COS 静态网站
```

因此，虚拟主机解决的问题是：多个域名可以共用同一个 Nginx 实例、同一个端口，但仍然能按域名和路径走不同规则。

## 四、Nginx 变量 $uri 说明

`$uri` 是 Nginx 内置变量，表示当前请求的 URI 路径部分。

它不包含：

```text
协议：https://
域名：h5.gzjjzhy.com
查询参数：?id=1
```

例如用户访问：

```text
https://h5.gzjjzhy.com/api/user/list?id=100
```

Nginx 中常见变量可以这样理解：

```text
$host        = h5.gzjjzhy.com
$request_uri = /api/user/list?id=100
$uri         = /api/user/list
```

区别是：

```text
$request_uri 保留原始请求路径和查询参数
$uri 通常是不带查询参数、经过 Nginx 规范化处理后的路径
```

### 1. $uri 在 try_files 中的作用

当前配置里有：

```nginx
try_files $uri /index.html;
```

意思是：

```text
1. 先尝试查找当前请求路径对应的文件
2. 如果找不到，就回退到 /index.html
```

举例：

```text
请求地址:
https://h5.gzjjzhy.com/js/app.js

$uri:
/js/app.js

try_files 第一优先级:
查找 /js/app.js 对应的本地文件
```

再举例：

```text
请求地址:
https://h5.gzjjzhy.com/order/detail

$uri:
/order/detail

try_files 第一优先级:
查找 /order/detail 对应的本地文件

如果本地没有这个文件:
回退到 /index.html
```

这种写法常用于 Vue、React、Taro H5 这类前端单页应用。因为前端路由路径，例如 `/order/detail`，在服务器上通常没有真实文件，需要回退到 `index.html`，再由浏览器里的前端路由接管。

### 2. $uri 不等于文件路径

`$uri` 只是 URL 路径，不是磁盘路径。

比如：

```text
$uri = /js/app.js
```

Nginx 还需要结合 `root` 或 `alias` 才能知道磁盘文件在哪里。

如果配置是：

```nginx
location / {
    root /usr/share/nginx/html;
}
```

那么：

```text
$uri = /js/app.js
实际文件 = /usr/share/nginx/html/js/app.js
```

如果配置是：

```nginx
location /logo.png {
    alias /etc/nginx/conf.d/logo.png;
}
```

那么：

```text
$uri = /logo.png
实际文件 = /etc/nginx/conf.d/logo.png
```

### 3. 当前配置中 $uri 的实际意义

在当前真实配置里，`gzjj_lmnsaas_com.conf` 和 `p_lmnsaas_com.conf` 都有：

```nginx
try_files $uri /index.html;
```

但同一个 `server` 里的 `location /` 又配置了：

```nginx
proxy_pass https://shop-lmnsaas-com-1251303505.cos-website.ap-guangzhou.myqcloud.com;
```

或：

```nginx
proxy_pass https://p-lmnsaas-com-1251303505.cos-website.ap-guangzhou.myqcloud.com;
```

所以当前主前端页面主要通过 `proxy_pass` 转发到 COS 静态网站。`try_files $uri /index.html` 更像是本地静态站点模式遗留或兜底配置，不能据此判断静态文件一定在容器本地。

判断是否真正读取本地文件，要看对应 `location` 里是否只有 `root/alias`，还是有 `proxy_pass`。

### 4. 常见相关变量

| 变量 | 示例 | 含义 |
| --- | --- | --- |
| `$host` | `h5.gzjjzhy.com` | 请求里的 Host 域名 |
| `$uri` | `/api/user/list` | 不带查询参数的规范化 URI 路径 |
| `$request_uri` | `/api/user/list?id=100` | 原始请求 URI，包含查询参数 |
| `$args` | `id=100` | 查询参数部分 |
| `$remote_addr` | `1.2.3.4` | 直接连接到 Nginx 的客户端 IP，经过 CLB 时可能是上一层代理 IP |
| `$http_host` | `h5.gzjjzhy.com` | 原始 Host 请求头 |
| `$proxy_add_x_forwarded_for` | `原有XFF, 当前remote_addr` | 用于追加代理链路 IP |

## 五、HTTP 代理请求头与 Forwarded 变量

当前 API 转发规则里有这些代理请求头配置：

```nginx
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header Host $http_host;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header Connection Close;
proxy_set_header X-Forwarded-For $remote_addr;
```

这些配置的作用是：Nginx 作为反向代理转发请求到后端 `gateway` 时，重新设置或追加 HTTP 请求头，让后端知道“原始访问域名、客户端 IP、代理链路”等信息。

### 1. 为什么代理请求头重要

用户不是直接访问后端 `gateway`，而是经过多层代理：

```text
用户浏览器
  -> 腾讯云 CLB
  -> Nginx
  -> gateway
  -> 业务服务
```

如果 Nginx 不传递这些请求头，后端 `gateway` 看到的客户端可能只是 Nginx Pod 的 IP，而不是真实用户 IP。

常见代理头：

```text
Host              原始访问域名
X-Real-IP         客户端 IP
X-Forwarded-For   代理链路 IP 列表
X-Forwarded-Proto 原始协议 http/https
```

当前配置没有设置 `X-Forwarded-Proto`。如果后端需要知道用户原始访问协议是 HTTPS，需要结合腾讯云 CLB 是否传递协议头，再考虑补充：

```nginx
proxy_set_header X-Forwarded-Proto $scheme;
```

### 2. `$remote_addr`

`$remote_addr` 是 Nginx 看到的“直接连接方 IP”。

没有代理时：

```text
用户浏览器 -> Nginx
$remote_addr = 用户公网 IP
```

当前架构中：

```text
用户浏览器 -> CLB -> Nginx
```

Nginx 的直接连接方可能是 CLB 或上一层代理，所以：

```text
$remote_addr = CLB/上一层代理 IP
```

这不一定是真实用户公网 IP。

当前配置：

```nginx
proxy_set_header X-Real-IP $remote_addr;
```

含义是把 Nginx 看到的直接连接方 IP 传给后端：

```http
X-Real-IP: $remote_addr
```

### 3. `$http_host`

`$http_host` 表示客户端请求头里的原始 `Host`。

用户访问：

```text
https://api.gzjjzhy.com/api/user/list
```

浏览器会带：

```http
Host: api.gzjjzhy.com
```

Nginx 中：

```text
$http_host = api.gzjjzhy.com
```

当前配置：

```nginx
proxy_set_header Host $http_host;
```

含义是把原始域名继续传给后端。后端可以据此知道用户访问的是 `api.gzjjzhy.com`、`h5.gzjjzhy.com` 还是其他域名。

### 4. `X-Forwarded-For`

`X-Forwarded-For` 是代理链路中最常见的客户端 IP 传递头。

格式通常是：

```text
X-Forwarded-For: 客户端IP, 代理1IP, 代理2IP
```

例如：

```text
用户 IP: 1.1.1.1
CLB IP: 2.2.2.2
Nginx IP: 3.3.3.3
```

理想情况下传到后端可能是：

```http
X-Forwarded-For: 1.1.1.1, 2.2.2.2, 3.3.3.3
```

这样后端可以通过第一个 IP 判断原始客户端。

### 5. `$proxy_add_x_forwarded_for`

`$proxy_add_x_forwarded_for` 是 Nginx 内置变量，用来追加代理链路 IP。

逻辑是：

```text
如果请求原本没有 X-Forwarded-For:
  $proxy_add_x_forwarded_for = $remote_addr

如果请求原本有 X-Forwarded-For:
  $proxy_add_x_forwarded_for = 原来的 X-Forwarded-For + ", " + $remote_addr
```

例如请求进入 Nginx 时已有：

```http
X-Forwarded-For: 1.1.1.1
```

Nginx 看到：

```text
$remote_addr = 2.2.2.2
```

则：

```text
$proxy_add_x_forwarded_for = 1.1.1.1, 2.2.2.2
```

当前配置里先写了：

```nginx
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

这是一种常见写法，用来保留并追加代理链路。

### 6. 当前配置里 X-Forwarded-For 被覆盖的问题

当前配置后面又写了一行：

```nginx
proxy_set_header X-Forwarded-For $remote_addr;
```

同一个 `location` 中重复设置同一个请求头时，后面的配置会覆盖前面的配置。

也就是说，这两行同时存在：

```nginx
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-For $remote_addr;
```

最终更可能生效的是：

```nginx
proxy_set_header X-Forwarded-For $remote_addr;
```

影响是：

```text
原有 X-Forwarded-For 链路可能丢失
后端只能看到 Nginx 的 remote_addr
如果 remote_addr 是 CLB IP，后端就拿不到真实用户 IP
审计日志、风控、限流、按 IP 判断位置等逻辑可能不准确
```

更常见的写法是只保留：

```nginx
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

如果后端只认 `X-Real-IP`，也可以保留：

```nginx
proxy_set_header X-Real-IP $remote_addr;
```

但不要在同一个 `location` 中重复设置 `X-Forwarded-For`。

### 7. `Connection Close`

当前配置：

```nginx
proxy_set_header Connection Close;
```

含义是告诉后端：

```text
这个请求处理完后关闭连接
```

影响是：

```text
减少后端连接复用
可能增加连接建立开销
对某些旧后端或特殊网关可能是兼容性配置
```

注意 `/mqtt` 的 WebSocket 配置不同，它使用：

```nginx
proxy_set_header Connection "Upgrade";
```

这是为了支持 WebSocket 协议升级，不能改成 `Close`。

### 8. 推荐的 API 代理请求头写法

更常见的 API 代理写法是：

```nginx
location /api/ {
    proxy_pass http://gateway/api/;
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

如果前面有 CLB，并且 CLB 会传递真实协议和真实 IP，还需要根据腾讯云 CLB 的实际请求头做适配。

关键判断点：

```text
后端要真实用户 IP：优先保留完整 X-Forwarded-For 链路
后端要原始域名：保留 Host $http_host
后端要知道 HTTPS：补充或确认 X-Forwarded-Proto
WebSocket/MQTT：Connection 必须是 Upgrade，不是 Close
```

### 9. 这些请求头不设置会有什么后果

下面按请求头说明“不设置或设置错误”的实际影响。

| 请求头 | 正常作用 | 不设置或设置错误的后果 |
| --- | --- | --- |
| `Host` | 告诉后端用户访问的原始域名 | 后端可能只看到 `gateway`，导致多域名识别、租户识别、回调地址、跨域判断错误 |
| `X-Real-IP` | 告诉后端一个客户端 IP | 后端日志可能只记录 Nginx/CLB IP，无法定位真实用户 |
| `X-Forwarded-For` | 保留完整代理链路 IP | 后端丢失真实用户 IP，审计、限流、风控、登录安全策略可能失真 |
| `X-Forwarded-Proto` | 告诉后端原始协议是 HTTP 还是 HTTPS | 后端可能误以为请求是 HTTP，生成错误的 http 链接，影响回调、重定向、Cookie Secure 判断 |
| `Connection` | 控制代理到后端的连接行为 | API 场景可能影响连接复用；WebSocket 场景如果不是 `Upgrade` 会导致连接升级失败 |
| `Upgrade` | WebSocket 协议升级 | 不设置会导致 WebSocket/MQTT over WebSocket 无法建立 |
| `Sec-WebSocket-Protocol` | 指定 WebSocket 子协议 | MQTT over WebSocket 场景可能握手失败或协议不匹配 |

#### 不设置 `Host`

当前配置：

```nginx
proxy_set_header Host $http_host;
```

如果不设置，Nginx 转发到：

```nginx
proxy_pass http://gateway/api/;
```

后端看到的 Host 可能变成：

```text
gateway
```

而不是：

```text
api.gzjjzhy.com
h5.gzjjzhy.com
p.gzjjzhy.com
```

可能后果：

```text
后端按域名区分租户时识别错误
后端生成回调地址或跳转地址时域名错误
跨域 CORS 判断错误
日志里看不到用户实际访问的域名
多域名共用同一 gateway 时无法区分来源
```

#### 不设置 `X-Real-IP`

当前配置：

```nginx
proxy_set_header X-Real-IP $remote_addr;
```

如果不设置，后端通常只能从 TCP 连接里看到 Nginx Pod 的 IP。

可能后果：

```text
后端 access log 全是 Nginx Pod IP
无法定位用户真实来源
按 IP 限流会错误地把所有用户算成同一个代理 IP
登录安全、异常访问检测、地理位置判断不准确
```

注意：`$remote_addr` 在当前 CLB -> Nginx 架构里也不一定是真实用户 IP，它可能是 CLB IP。因此真实用户 IP 更应该结合 `X-Forwarded-For` 链路判断。

#### 不设置 `X-Forwarded-For`

当前配置里原本有正确写法：

```nginx
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

这会保留原始链路并追加当前代理 IP。

如果不设置，后端无法知道请求经过了哪些代理，也可能拿不到用户真实 IP。

可能后果：

```text
审计日志缺少真实客户端 IP
风控系统无法判断真实来源
黑白名单按 IP 判断失效
同一个 Nginx/CLB IP 下的所有用户被误认为同一来源
问题排查时无法还原访问链路
```

当前配置的问题是后面又写了：

```nginx
proxy_set_header X-Forwarded-For $remote_addr;
```

这会覆盖前面的链路追加结果。实际效果可能从：

```text
真实用户IP, CLB IP
```

变成：

```text
CLB IP 或 Nginx 看到的直接连接 IP
```

因此这行会削弱 `X-Forwarded-For` 的价值。

#### 不设置 `X-Forwarded-Proto`

当前配置没有显式设置：

```nginx
proxy_set_header X-Forwarded-Proto $scheme;
```

公网用户访问是：

```text
https://api.gzjjzhy.com
```

但 CLB 到 Nginx 通常是：

```text
http://nginx:80
```

如果后端只看自己收到的协议，可能以为用户访问的是 HTTP。

可能后果：

```text
后端生成 http:// 开头的回调地址，而不是 https://
登录后重定向到 HTTP，导致浏览器安全警告或混合内容问题
需要 Secure 的 Cookie 判断错误
OAuth、支付回调、第三方平台验签中的回调地址可能不一致
接口文档或返回链接协议错误
```

是否能直接用 `$scheme` 要看 Nginx 收到的协议。如果 Nginx 收到的是 CLB 转发后的 HTTP，则：

```text
$scheme = http
```

这时还需要看 CLB 是否传递了类似：

```text
X-Forwarded-Proto: https
```

如果 CLB 已经传了，Nginx 应该继续透传这个头，而不是简单覆盖。

#### API 场景不正确设置 `Connection`

当前 API 配置：

```nginx
proxy_set_header Connection Close;
```

这表示告诉后端处理完请求后关闭连接。

可能后果：

```text
后端连接复用减少
高并发时连接创建和关闭更多
吞吐和延迟可能变差
```

它不一定是错误，有些旧系统或网关为了避免连接复用问题会这样配置。但如果没有特殊原因，现代 HTTP 代理通常不需要强制 `Connection Close`。

#### WebSocket 场景不设置 `Upgrade` / `Connection "Upgrade"`

当前 MQTT 配置：

```nginx
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "Upgrade";
proxy_set_header Sec-WebSocket-Protocol mqtt;
```

如果这些头不设置，浏览器或客户端想建立 WebSocket 时，后端可能收不到协议升级请求。

可能后果：

```text
WebSocket 握手失败
MQTT over WebSocket 连接不上
连接很快断开
客户端报 400、426、502 或连接超时
```

所以 API 的 `Connection Close` 和 MQTT 的 `Connection "Upgrade"` 不是一类配置，不能混用。

## 六、/etc/nginx/nginx.conf

```nginx
user nginx;                         # worker 进程使用 nginx 用户运行。
worker_processes auto;              # worker 进程数自动按 CPU 资源决定。

error_log /var/log/nginx/error.log notice;  # 错误日志路径是 /var/log/nginx/error.log，日志级别是 notice。
pid /run/nginx.pid;                         # Nginx 主进程 PID 文件位置。

events {                            # events 块用于配置连接处理模型。
    worker_connections 1024;        # 每个 worker 最多同时处理 1024 个连接。
}

http {                              # http 块是 HTTP/Web 代理配置的主作用域。
    include /etc/nginx/mime.types;  # 加载 MIME 类型映射文件，例如 js/css/png/html 对应什么 Content-Type。
    default_type application/octet-stream; # 找不到 MIME 类型时，默认按二进制流返回。

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '  # 定义名为 main 的访问日志格式：客户端 IP、用户、时间、请求行。
                    '$status $body_bytes_sent "$http_referer" '              # 继续记录状态码、响应字节数、来源页面。
                    '"$http_user_agent" "$http_x_forwarded_for"';            # 继续记录浏览器 UA 和转发链路 IP。

    access_log /var/log/nginx/access.log main; # 访问日志写到 /var/log/nginx/access.log，并使用 main 格式。

    sendfile on;                    # 开启 sendfile，提高静态文件传输效率。
    keepalive_timeout 65;           # HTTP keepalive 空闲连接保留 65 秒。
    client_max_body_size 20m;       # 请求体最大 20MB，影响上传文件大小。

    include /etc/nginx/conf.d/*.conf; # 加载业务配置目录下所有 .conf 文件，这是业务域名规则入口。
}
```

## 七、/etc/nginx/mime.types

`mime.types` 是扩展名到响应类型的映射。它来自官方镜像，当前不通过 CFS 修改。

```nginx
types {                                                         # MIME 类型映射表开始。
    text/html                                        html htm shtml; # .html/.htm/.shtml 返回 text/html。
    text/css                                         css;            # .css 返回 text/css。
    text/xml                                         xml;            # .xml 返回 text/xml。
    image/gif                                        gif;            # .gif 返回 image/gif。
    image/jpeg                                       jpeg jpg;       # .jpeg/.jpg 返回 image/jpeg。
    application/javascript                           js;             # .js 返回 application/javascript。
    application/atom+xml                             atom;           # .atom 返回 application/atom+xml。
    application/rss+xml                              rss;            # .rss 返回 application/rss+xml。

    text/mathml                                      mml;            # .mml 返回 text/mathml。
    text/plain                                       txt;            # .txt 返回 text/plain。
    text/vnd.sun.j2me.app-descriptor                 jad;            # .jad 返回 J2ME 描述文件类型。
    text/vnd.wap.wml                                 wml;            # .wml 返回 WAP 页面类型。
    text/x-component                                 htc;            # .htc 返回 IE 组件类型。

    image/avif                                       avif;           # .avif 图片类型。
    image/png                                        png;            # .png 图片类型。
    image/svg+xml                                    svg svgz;       # .svg/.svgz 矢量图片类型。
    image/tiff                                       tif tiff;       # .tif/.tiff 图片类型。
    image/vnd.wap.wbmp                               wbmp;           # .wbmp 图片类型。
    image/webp                                       webp;           # .webp 图片类型。
    image/x-icon                                     ico;            # .ico 图标类型。
    image/x-jng                                      jng;            # .jng 图片类型。
    image/x-ms-bmp                                   bmp;            # .bmp 图片类型。

    font/woff                                        woff;           # .woff 字体类型。
    font/woff2                                       woff2;          # .woff2 字体类型。

    application/java-archive                         jar war ear;    # Java 包类型。
    application/json                                 json;           # JSON 响应类型。
    application/mac-binhex40                         hqx;            # hqx 文件类型。
    application/msword                               doc;            # Word 旧格式。
    application/pdf                                  pdf;            # PDF 文件类型。
    application/postscript                           ps eps ai;      # PostScript/AI 文件类型。
    application/rtf                                  rtf;            # RTF 文档类型。
    application/vnd.apple.mpegurl                    m3u8;           # HLS m3u8 类型。
    application/vnd.google-earth.kml+xml             kml;            # Google Earth KML 类型。
    application/vnd.google-earth.kmz                 kmz;            # Google Earth KMZ 类型。
    application/vnd.ms-excel                         xls;            # Excel 旧格式。
    application/vnd.ms-fontobject                    eot;            # EOT 字体类型。
    application/vnd.ms-powerpoint                    ppt;            # PowerPoint 旧格式。
    application/vnd.oasis.opendocument.graphics      odg;            # OpenDocument 图形。
    application/vnd.oasis.opendocument.presentation  odp;            # OpenDocument 演示。
    application/vnd.oasis.opendocument.spreadsheet   ods;            # OpenDocument 表格。
    application/vnd.oasis.opendocument.text          odt;            # OpenDocument 文档。
    application/vnd.openxmlformats-officedocument.presentationml.presentation pptx; # PowerPoint 新格式。
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet xlsx;         # Excel 新格式。
    application/vnd.openxmlformats-officedocument.wordprocessingml.document docx;   # Word 新格式。
    application/vnd.wap.wmlc                         wmlc;           # WML 编译格式。
    application/wasm                                 wasm;           # WebAssembly 类型。
    application/x-7z-compressed                      7z;             # 7z 压缩包。
    application/x-cocoa                              cco;            # Cocoa 文件类型。
    application/x-java-archive-diff                  jardiff;        # Java archive diff。
    application/x-java-jnlp-file                     jnlp;           # Java Web Start。
    application/x-makeself                           run;            # run 安装包。
    application/x-perl                               pl pm;          # Perl 脚本/模块。
    application/x-pilot                              prc pdb;        # Palm 文件。
    application/x-rar-compressed                     rar;            # RAR 压缩包。
    application/x-redhat-package-manager             rpm;            # RPM 包。
    application/x-sea                                sea;            # SEA 压缩类型。
    application/x-shockwave-flash                    swf;            # Flash 文件。
    application/x-stuffit                            sit;            # StuffIt 压缩包。
    application/x-tcl                                tcl tk;         # Tcl/Tk 脚本。
    application/x-x509-ca-cert                       der pem crt;    # 证书文件。
    application/x-xpinstall                          xpi;            # Firefox 插件包。
    application/xhtml+xml                            xhtml;          # XHTML 类型。
    application/xspf+xml                             xspf;           # XSPF 播放列表。
    application/zip                                  zip;            # ZIP 压缩包。

    application/octet-stream                         bin exe dll;    # 常见二进制文件。
    application/octet-stream                         deb;            # Debian 包。
    application/octet-stream                         dmg;            # macOS 镜像。
    application/octet-stream                         iso img;        # 光盘/镜像文件。
    application/octet-stream                         msi msp msm;    # Windows 安装包。

    audio/midi                                       mid midi kar;   # MIDI 音频。
    audio/mpeg                                       mp3;            # MP3 音频。
    audio/ogg                                        ogg;            # OGG 音频。
    audio/x-m4a                                      m4a;            # M4A 音频。
    audio/x-realaudio                                ra;             # RealAudio 音频。

    video/3gpp                                       3gpp 3gp;       # 3GP 视频。
    video/mp2t                                       ts;             # TS 视频流。
    video/mp4                                        mp4;            # MP4 视频。
    video/mpeg                                       mpeg mpg;       # MPEG 视频。
    video/quicktime                                  mov;            # MOV 视频。
    video/webm                                       webm;           # WebM 视频。
    video/x-flv                                      flv;            # FLV 视频。
    video/x-m4v                                      m4v;            # M4V 视频。
    video/x-mng                                      mng;            # MNG 视频/动画。
    video/x-ms-asf                                   asx asf;        # ASF 视频。
    video/x-ms-wmv                                   wmv;            # WMV 视频。
    video/x-msvideo                                  avi;            # AVI 视频。
}                                                                  # MIME 类型映射表结束。
```

## 八、/etc/nginx/conf.d/default.conf

```nginx
server {                                # 定义一个虚拟主机。
    listen 80;                          # 监听 IPv4 的 80 端口。
    listen [::]:80;                     # 监听 IPv6 的 80 端口。
    server_name localhost;              # 匹配 Host 为 localhost 的请求，也可能作为兜底 server。

    location / {                        # 匹配所有路径。
        root /usr/share/nginx/html;     # 静态文件根目录是官方镜像默认目录。
        index index.html index.htm;     # 访问目录时默认找 index.html 或 index.htm。
    }

    error_page 500 502 503 504 /50x.html; # 服务器错误时内部跳转到 /50x.html。

    location = /50x.html {              # 精确匹配 /50x.html。
        root /usr/share/nginx/html;     # 从官方镜像默认目录读取 50x.html。
    }
}                                       # 默认虚拟主机结束。
```

说明：这个文件在 `/etc/nginx/conf.d/` 下，当前来自 CFS/NFS，可以修改。但它主要是官方默认兜底配置，不是业务域名主入口。

## 九、/etc/nginx/conf.d/gzjj_lmnsaas_com.conf

```nginx
upstream api_bakend_wss {                          # 定义一个上游服务组，供 /mqtt 使用。
    ip_hash;                                       # 按客户端 IP 做粘性分配，同一个 IP 尽量转到同一后端。
    server emqx54:8083 max_fails=0 weight=1;       # 后端是 K8s 内部服务 emqx54 的 8083 端口，权重 1，不按失败次数摘除。
}                                                  # upstream 结束。注意 api_bakend_wss 名称里 bakend 拼写不影响运行。

server {                                           # 定义业务虚拟主机。
    listen 80;                                     # Nginx 容器内部监听 80，外部 HTTPS 已在 CLB 层终止。
    listen [::]:80;                                # 同时监听 IPv6 的 80。
    server_name gzjj.lmnsaas.com shop.gzjjzhy.com wx.gzjjzhy.com h5.gzjjzhy.com api.gzjjzhy.com mp.gzjjzhy.com; # 这些域名共用同一套规则。

    try_files $uri /index.html;                    # server 级兜底尝试；但 location / 里有 proxy_pass，普通页面主要走 COS。

    gzip on;                                       # 开启 gzip 压缩。
    gzip_min_length 1024;                          # 响应体超过 1024 字节才压缩。
    gzip_buffers 4 16k;                            # gzip 压缩缓冲区配置。
    gzip_types text/plain application/javascript application/x-javascript text/css application/xml text/javascript application/x-httpd-php image/jpeg image/gif image/png; # 指定哪些响应类型参与 gzip。

    location / {                                   # 匹配根路径和大部分普通前端请求。
        root /usr/share/nginx/html;                # 写了本地 root，但同一 location 有 proxy_pass，普通请求实际代理到 COS。
        proxy_pass https://shop-lmnsaas-com-1251303505.cos-website.ap-guangzhou.myqcloud.com; # 主前端页面来源：腾讯云 COS 静态网站。
    }

    location /logo.png {                           # 匹配 /logo.png。
        alias /etc/nginx/conf.d/logo.png;          # 实际读取 CFS/NFS 上的 logo.png。
        access_log off;                            # 关闭该资源访问日志。
        expires 1d;                                # 浏览器缓存 1 天。
    }

    location /logo.svg {                           # 匹配 /logo.svg。
        alias /etc/nginx/conf.d/logo.svg;          # 实际读取 CFS/NFS 上的 logo.svg。
        access_log off;                            # 关闭访问日志。
        expires 1d;                                # 浏览器缓存 1 天。
    }

    location /favicon.ico {                        # 匹配浏览器站点图标。
        alias /etc/nginx/conf.d/favicon.ico;       # 实际读取 CFS/NFS 上的 favicon.ico。
        access_log off;                            # 关闭访问日志。
        expires 1d;                                # 浏览器缓存 1 天。
    }

    location /logo/default/logo.png {              # 匹配 /logo/default/logo.png。
        alias /etc/nginx/conf.d/logo.png;          # 仍然复用同一个 logo.png。
        access_log off;                            # 关闭访问日志。
        expires 1d;                                # 浏览器缓存 1 天。
    }

    location /logo/default//logo.svg {             # 匹配带双斜杠的路径，可能是历史兼容或路径拼接遗留。
        alias /etc/nginx/conf.d/logo.svg;          # 仍然复用同一个 logo.svg。
        access_log off;                            # 关闭访问日志。
        expires 1d;                                # 浏览器缓存 1 天。
    }

    location /logo/default//favicon.ico {          # 匹配带双斜杠的 favicon 路径。
        alias /etc/nginx/conf.d/favicon.ico;       # 仍然复用同一个 favicon.ico。
        access_log off;                            # 关闭访问日志。
        expires 1d;                                # 浏览器缓存 1 天。
    }

    location /pictures/ {                          # 匹配 /pictures/ 下的图片资源。
        root /usr/share/nginx/html;                # 写了本地 root，但普通请求由 proxy_pass 代理。
        proxy_pass https://chain-pictures-01-1251303505.cos-website.ap-guangzhou.myqcloud.com/; # 图片资源代理到另一个 COS 静态网站。
    }

    location /mqtt {                               # 匹配 /mqtt，用于 MQTT over WebSocket。
        proxy_pass http://api_bakend_wss/mqtt;     # 转发到 upstream api_bakend_wss，也就是 emqx54:8083/mqtt。

        proxy_http_version 1.1;                    # WebSocket 升级需要 HTTP/1.1。
        proxy_set_header Upgrade $http_upgrade;    # 透传 Upgrade 请求头。
        proxy_set_header Connection "Upgrade";     # 告诉后端这是协议升级连接。
        proxy_set_header Sec-WebSocket-Protocol mqtt; # 指定 WebSocket 子协议 mqtt。
        proxy_connect_timeout 5s;                  # 连接后端超时时间 5 秒。
        proxy_read_timeout 60000s;                 # 读超时设置很长，适配长连接。
        proxy_send_timeout 60000s;                 # 写超时设置很长，适配长连接。
    }

    location /api/ {                               # 匹配 /api/ 开头的后端接口。
        proxy_pass http://gateway/api/;            # 转发到 K8s 内部 gateway 服务的 /api/。
        proxy_redirect default;                    # 使用默认重定向改写规则。
        proxy_set_header X-Real-IP $remote_addr;   # 把客户端 IP 传给后端。
        proxy_set_header Host $http_host;          # 把原始 Host 传给后端。
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 追加代理链路 IP。
        proxy_set_header Connection Close;         # 告诉后端关闭连接复用。
        proxy_set_header X-Forwarded-For $remote_addr; # 覆盖上一行 X-Forwarded-For，最终可能只保留 remote_addr。
        error_page 404 /404.html;                  # 404 错误页。
        error_page 500 502 503 504 /50x.html;      # 服务器错误页。
    }

    location /spapi/ {                             # 匹配 /spapi/ 开头的接口。
        proxy_pass http://gateway/api/;            # 外部 /spapi/ 会映射到内部 gateway 的 /api/。
        proxy_redirect default;                    # 使用默认重定向改写规则。
        proxy_set_header X-Real-IP $remote_addr;   # 传递客户端 IP。
        proxy_set_header Host $http_host;          # 传递原始 Host。
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 追加代理链路 IP。
        proxy_set_header Connection Close;         # 关闭后端连接复用。
        proxy_set_header X-Forwarded-For $remote_addr; # 覆盖上一行 X-Forwarded-For。
        error_page 404 /404.html;                  # 404 错误页。
        error_page 500 502 503 504 /50x.html;      # 服务器错误页。
    }

    error_page 500 502 503 504 /50x.html;          # server 级服务器错误页。

    location = /50x.html {                         # 精确匹配 /50x.html。
        root /usr/share/nginx/html;                # 从官方镜像默认目录读取 50x.html。
    }
}                                                  # gzjj_lmnsaas_com.conf 的 server 结束。
```

## 十、/etc/nginx/conf.d/p_lmnsaas_com.conf

```nginx
server {                                           # 定义支付相关虚拟主机。
    listen 80;                                     # Nginx 容器内部监听 80。
    listen [::]:80;                                # 同时监听 IPv6 80。
    server_name paygzjj.lmnsaas.com p.gzjjzhy.com; # 支付相关域名共用这一套规则。

    try_files $uri /index.html;                    # server 级兜底尝试；普通页面主要走下面的 COS proxy_pass。

    gzip on;                                       # 开启 gzip 压缩。
    gzip_min_length 1024;                          # 响应体超过 1024 字节才压缩。
    gzip_buffers 4 16k;                            # gzip 缓冲区。
    gzip_types text/plain application/javascript application/x-javascript text/css application/xml text/javascript application/x-httpd-php image/jpeg image/gif image/png; # 指定 gzip 类型。

    location / {                                   # 匹配支付前端首页和普通资源。
        root /usr/share/nginx/html;                # 写了本地 root，但同一 location 有 proxy_pass。
        proxy_pass https://p-lmnsaas-com-1251303505.cos-website.ap-guangzhou.myqcloud.com; # 支付前端页面来源：COS 静态网站。
    }

    location /api/ {                               # 匹配支付域名下的 /api/。
        proxy_pass http://gateway/api/;            # 转发到内部 gateway 的 /api/。
        proxy_redirect default;                    # 默认重定向改写。
        proxy_set_header X-Real-IP $remote_addr;   # 传递客户端 IP。
        proxy_set_header Host $http_host;          # 传递原始 Host。
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 追加代理链路 IP。
        proxy_set_header Connection Close;         # 关闭后端连接复用。
        proxy_set_header X-Forwarded-For $remote_addr; # 覆盖上一行 X-Forwarded-For。
        error_page 404 /404.html;                  # 404 错误页。
        error_page 500 502 503 504 /50x.html;      # 服务器错误页。
    }

    location /spapi/ {                             # 匹配支付域名下的 /spapi/。
        proxy_pass http://gateway/api/;            # 外部 /spapi/ 映射到内部 /api/。
        proxy_redirect default;                    # 默认重定向改写。
        proxy_set_header X-Real-IP $remote_addr;   # 传递客户端 IP。
        proxy_set_header Host $http_host;          # 传递原始 Host。
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # 追加代理链路 IP。
        proxy_set_header Connection Close;         # 关闭后端连接复用。
        proxy_set_header X-Forwarded-For $remote_addr; # 覆盖上一行 X-Forwarded-For。
        error_page 404 /404.html;                  # 404 错误页。
        error_page 500 502 503 504 /50x.html;      # 服务器错误页。
    }

    error_page 500 502 503 504 /50x.html;          # server 级服务器错误页。

    location = /50x.html {                         # 精确匹配 /50x.html。
        root /usr/share/nginx/html;                # 从官方镜像默认目录读取 50x.html。
    }
}                                                  # p_lmnsaas_com.conf 的 server 结束。
```

## 十一、请求匹配与路由总表

| 访问域名 | 命中的配置文件 | 首页/前端来源 | API 来源 | 特殊路径 |
| --- | --- | --- | --- | --- |
| `gzjj.lmnsaas.com` | `gzjj_lmnsaas_com.conf` | shop COS 静态网站 | `gateway/api/` | `/mqtt` -> `emqx54:8083` |
| `shop.gzjjzhy.com` | `gzjj_lmnsaas_com.conf` | shop COS 静态网站 | `gateway/api/` | `/pictures/` -> pictures COS |
| `wx.gzjjzhy.com` | `gzjj_lmnsaas_com.conf` | shop COS 静态网站 | `gateway/api/` | `/mqtt` -> `emqx54:8083` |
| `h5.gzjjzhy.com` | `gzjj_lmnsaas_com.conf` | shop COS 静态网站 | `gateway/api/` | `/logo.png` 等来自 CFS |
| `api.gzjjzhy.com` | `gzjj_lmnsaas_com.conf` | shop COS 静态网站 | `gateway/api/` | `/spapi/` -> `gateway/api/` |
| `mp.gzjjzhy.com` | `gzjj_lmnsaas_com.conf` | shop COS 静态网站 | `gateway/api/` | `/mqtt` -> `emqx54:8083` |
| `paygzjj.lmnsaas.com` | `p_lmnsaas_com.conf` | pay COS 静态网站 | `gateway/api/` | 无特殊 MQTT 配置 |
| `p.gzjjzhy.com` | `p_lmnsaas_com.conf` | pay COS 静态网站 | `gateway/api/` | 无特殊 MQTT 配置 |

## 十二、当前静态页面到底在哪里

当前主页面不在 `nginx:1.27.5` 镜像内，也不靠 `/usr/share/nginx/html` 提供，而是代理到腾讯云 COS 静态网站：

```text
shop-lmnsaas-com-1251303505.cos-website.ap-guangzhou.myqcloud.com
p-lmnsaas-com-1251303505.cos-website.ap-guangzhou.myqcloud.com
chain-pictures-01-1251303505.cos-website.ap-guangzhou.myqcloud.com
```

`/usr/share/nginx/html` 在当前业务配置里主要是：

```text
官方默认页面目录
50x 错误页目录
root 占位配置
```

不能只看到 `root /usr/share/nginx/html;` 就判断业务前端页面在镜像内，因为同一个 `location` 里配置了 `proxy_pass`。

## 十三、nginx -T 警告说明

执行 `nginx -T` 时出现：

```text
could not build optimal proxy_headers_hash,
you should increase either proxy_headers_hash_max_size: 512
or proxy_headers_hash_bucket_size: 64
```

这不是配置语法错误，因为后面已经显示：

```text
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

含义是：当前代理请求头配置较多，Nginx 认为默认 hash 表大小不够理想，但配置仍然可以加载。

如果要消除警告，可以在 `http {}` 中增加：

```nginx
proxy_headers_hash_max_size 1024;
proxy_headers_hash_bucket_size 128;
```

但当前 `http {}` 在镜像内置的 `/etc/nginx/nginx.conf` 中，业务只挂载了 `/etc/nginx/conf.d/`。是否修改要看是否允许自定义 Nginx 主配置或制作自定义镜像。

## 十四、需要注意的问题

| 问题 | 说明 | 建议 |
| --- | --- | --- |
| `root /usr/share/nginx/html` 与 `proxy_pass` 同时存在 | 容易误判静态页面在本地 | 以 `proxy_pass` 为准，当前主页面来自 COS |
| 多个域名共用一个 server | `h5`、`shop`、`api`、`mp`、`wx` 使用同一套规则 | 修改规则前要评估所有域名影响 |
| `X-Forwarded-For` 重复设置 | 后一行会覆盖前一行 | 谨慎调整，先确认后端取 IP 逻辑 |
| `logo/default//logo.svg` 有双斜杠 | 可能是历史拼接问题 | 不影响时可暂不动，后续统一整理 |
| `proxy_headers_hash` 警告 | 不是致命错误 | 可通过调整主配置消除 |
| 配置来自 CFS/NFS | 修改方便，但容易绕过版本管理 | 建议配置纳入 Git 或发布流程 |
