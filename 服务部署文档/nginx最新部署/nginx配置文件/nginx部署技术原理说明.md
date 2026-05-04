# nginx 部署技术原理说明

本文说明 `nginx-deployment-online-like.yaml` 中这几个关键配置的技术原理：

```yaml
volumeMounts:
  - name: nginx-conf-files
    mountPath: /etc/nginx/conf.d
  - name: nginx-html-files
    mountPath: /usr/share/nginx/html

volumes:
  - name: nginx-conf-files
    persistentVolumeClaim:
      claimName: nginx-conf-files
  - name: nginx-html-files
    persistentVolumeClaim:
      claimName: nginx-html-files
```

以及它们为什么这样设计、Pod 启动后发生了什么、Nginx 为什么能直接读取配置和静态页面。

## 一、整体思路

这套部署把 Nginx 运行所需内容拆成两类：

```text
1. 配置文件
   -> 挂载到 /etc/nginx/conf.d

2. 静态网页文件
   -> 挂载到 /usr/share/nginx/html
```

这样做的目的不是把所有内容都打进镜像，而是把“程序”和“内容”分开：

```text
nginx:1.27.5 镜像
  = Nginx 程序本体

PVC 挂载目录
  = 站点配置、网页文件、图片文件
```

好处是：

```text
改配置不需要重新制作镜像
改静态网页不需要重新制作镜像
Pod 重启后配置和页面不会丢
配置目录和页面目录边界清晰
```

## 二、什么是 PVC

PVC 是 `PersistentVolumeClaim`，中文通常叫“持久卷声明”。

它的作用是：

```text
向 Kubernetes 申请一块持久化存储
然后把这块存储挂载到 Pod 内某个目录
```

在当前文件里有两个 PVC：

```yaml
kind: PersistentVolumeClaim
metadata:
  name: nginx-conf-files
```

和：

```yaml
kind: PersistentVolumeClaim
metadata:
  name: nginx-html-files
```

它们分别负责：

```text
nginx-conf-files  -> 配置文件存储
nginx-html-files  -> 静态网页存储
```

## 三、什么是 volumeMounts

`volumeMounts` 是容器级配置，表示“把某个卷挂到容器内哪个目录”。

当前配置：

```yaml
volumeMounts:
  - name: nginx-conf-files
    mountPath: /etc/nginx/conf.d
  - name: nginx-html-files
    mountPath: /usr/share/nginx/html
```

含义是：

```text
名为 nginx-conf-files 的卷
  -> 挂到容器内 /etc/nginx/conf.d

名为 nginx-html-files 的卷
  -> 挂到容器内 /usr/share/nginx/html
```

所以 Pod 启动后，Nginx 容器看到的：

```text
/etc/nginx/conf.d
/usr/share/nginx/html
```

都不是镜像里原始的目录内容，而是外部卷挂进来的内容。

## 四、什么是 volumes

`volumes` 是 Pod 级配置，表示“这个名字对应哪种卷来源”。

当前写法：

```yaml
volumes:
  - name: nginx-conf-files
    persistentVolumeClaim:
      claimName: nginx-conf-files
  - name: nginx-html-files
    persistentVolumeClaim:
      claimName: nginx-html-files
```

含义是：

```text
volumeMounts 里引用的 nginx-conf-files
  -> 实际来源是 PVC nginx-conf-files

volumeMounts 里引用的 nginx-html-files
  -> 实际来源是 PVC nginx-html-files
```

可以这样理解：

```text
volumes      负责定义“卷从哪里来”
volumeMounts 负责定义“卷挂到哪里去”
```

## 五、为什么要两个挂载目录

因为配置文件和静态网页不是一类东西。

### 1. `/etc/nginx/conf.d`

这是 Nginx 的业务配置目录。

Nginx 主配置里通常会有：

```nginx
include /etc/nginx/conf.d/*.conf;
```

所以这个目录里应该放：

```text
default.conf
main.conf
pay.conf
```

也就是：

```text
虚拟主机配置
location 路由配置
proxy_pass 配置
gzip 配置
错误页配置
```

它不适合放大量网页文件。

### 2. `/usr/share/nginx/html`

这是 Nginx 默认静态网页目录。

适合放：

```text
index.html
js/
css/
assets/
images/
pictures/
```

也就是：

```text
前端构建产物
静态页面
图片资源
错误页 html
```

你现在这套设计就是把：

```text
conf.d 只放配置
html 只放静态网页
```

这样边界最清楚。

## 六、Pod 启动时实际发生了什么

Kubernetes 启动这个 Pod 时，大致会做这些事：

```text
1. 创建或绑定 PVC
2. 把 PVC 对应的存储准备好
3. 启动 nginx 容器
4. 把 nginx-conf-files 挂载到 /etc/nginx/conf.d
5. 把 nginx-html-files 挂载到 /usr/share/nginx/html
6. 启动 nginx:1.27.5
7. Nginx 读取 /etc/nginx/nginx.conf
8. nginx.conf include /etc/nginx/conf.d/*.conf
9. 加载 default.conf、main.conf、pay.conf
10. 按这些配置提供网站和代理服务
```

也就是说：

```text
PVC 先挂载
Nginx 后启动
Nginx 启动时直接读取挂载后的目录内容
```

不是“先启动 Nginx，再动态拷文件进去”。

## 七、为什么 Nginx 会自动读取 conf.d 下的文件

不是 Kubernetes 自动解析这些 `.conf`，而是 Nginx 本身就有这个机制。

官方 Nginx 主配置一般会有：

```nginx
include /etc/nginx/conf.d/*.conf;
```

所以只要挂载目录里放的是：

```text
*.conf
```

Nginx 启动时就会自动加载。

例如：

```text
/etc/nginx/conf.d/default.conf
/etc/nginx/conf.d/main.conf
/etc/nginx/conf.d/pay.conf
```

这些会被自动加载。

但下面这些不会自动当作配置文件加载：

```text
logo.png
favicon.ico
README.md
notes.txt
```

它们只有在 `alias` 或 `root` 指向时，才会被当作静态文件访问。

## 八、为什么 `/usr/share/nginx/html` 要单独挂载

如果不单独挂载，Nginx 会使用镜像内自带的默认页面目录。

官方 `nginx:1.27.5` 镜像里通常只有默认欢迎页，不会有你的业务前端页面。

所以如果测试环境不能放 COS，又需要本地部署页面，就必须把静态文件挂到：

```text
/usr/share/nginx/html
```

这样主业务和支付前端可以放在：

```text
/usr/share/nginx/html/main
/usr/share/nginx/html/pay
/usr/share/nginx/html/pictures
```

再通过 `main.conf`、`pay.conf` 读取这些目录。

## 九、`local-path` 是什么

当前 PVC 写的是：

```yaml
storageClassName: local-path
```

`local-path` 的含义通常是：

```text
在 Kubernetes 节点本机磁盘上创建目录作为存储
不是云盘
不是共享文件系统
不是对象存储
```

它的特点：

```text
简单
适合测试环境
部署快
不适合多节点共享
```

也就是说，`local-path` 更像：

```text
把数据放在某一台 K8s 节点机器的本地磁盘上
```

不是像线上那样的：

```text
CFS/NFS 共享存储
```

## 十、`ReadWriteOnce` 是什么

当前 PVC 写的是：

```yaml
accessModes:
  - ReadWriteOnce
```

`ReadWriteOnce` 通常表示：

```text
同一时刻只能被一个节点以读写方式挂载
```

这会带来一个重要影响：

```text
适合单副本
不适合多节点多副本共享写入
```

所以你现在部署里 `replicas: 1` 是合理的。

如果改成 2 个副本，而两个 Pod 被调度到不同节点，`local-path + ReadWriteOnce` 很可能就不能正常共享这两个目录。

## 十一、为什么这个方案和线上不完全一样

线上你给出的结构更接近：

```text
/etc/nginx/conf.d  -> CFS/NFS
/usr/share/nginx/html 可能不是主页面来源，或走 COS
CLB -> NodePort -> nginx
多域名虚拟主机
```

当前测试方案改成：

```text
/etc/nginx/conf.d  -> local-path PVC
/usr/share/nginx/html -> local-path PVC
不用 COS
本地直接存放主业务和支付前端页面
```

所以它是：

```text
运行结构仿照线上
存储介质改成测试环境可用的本地 PVC
```

这是有意为之，不是偏差。

## 十二、你需要往这两个卷里放什么

### 1. 配置卷 `nginx-conf-files`

应该放：

```text
/etc/nginx/conf.d/default.conf
/etc/nginx/conf.d/main.conf
/etc/nginx/conf.d/pay.conf
```

### 2. 静态网页卷 `nginx-html-files`

应该放：

```text
/usr/share/nginx/html/main/index.html
/usr/share/nginx/html/main/js/...
/usr/share/nginx/html/main/css/...

/usr/share/nginx/html/pay/index.html
/usr/share/nginx/html/pay/js/...
/usr/share/nginx/html/pay/css/...

/usr/share/nginx/html/pictures/...
```

## 十三、当前方案的优点

```text
配置和静态页面分离
不依赖 ConfigMap
不依赖 COS
适合测试服务器离线或内网环境
Nginx 的行为和线上思路接近
```

## 十四、当前方案的限制

```text
local-path 不是共享存储
ReadWriteOnce 不适合多节点多副本
replicas 目前应保持 1
如果 Pod 漂移到其他节点，local-path 数据可能需要重新准备
不适合作为高可用生产方案
```

## 十五、后续如果要更接近线上

如果以后要更接近线上，可以逐步替换：

```text
local-path PVC
  -> CFS/NFS/RWX 共享存储

replicas: 1
  -> replicas: 2

本地静态网页
  -> COS 或共享存储
```

这样就会更接近真实线上架构。 
