# nginx部署 目录说明

## 1. 目录用途

这个目录用于测试/安装环境部署 Nginx。

目录结构：

```text
nginx部署/
  conf.d/
    default.conf
    main.conf
    pay.conf
```

## 2. 文件作用

- `default.conf`
  - 默认虚拟主机
  - 支持内网通过 `节点IP:30080` 直接访问主业务
- `main.conf`
  - 主业务站点
  - 域名：`gzjj.lmnsaas.com`、`shop.gzjjzhy.com`、`wx.gzjjzhy.com`、`h5.gzjjzhy.com`、`api.gzjjzhy.com`、`mp.gzjjzhy.com`
- `pay.conf`
  - 支付站点
  - 域名：`paygzjj.lmnsaas.com`、`p.gzjjzhy.com`

## 3. Deployment 文件

部署文件：

```text
nginx-deployment-online-like.yaml
```

它会创建两个 PVC：

```text
nginx-conf-files   -> 挂载到 /etc/nginx/conf.d
nginx-html-files   -> 挂载到 /usr/share/nginx/html
```

## 4. 需要放进去的内容

### 配置目录 PVC

`nginx-conf-files` 中需要放：

```text
/etc/nginx/conf.d/default.conf
/etc/nginx/conf.d/main.conf
/etc/nginx/conf.d/pay.conf
```

### 静态网页 PVC

`nginx-html-files` 中建议放：

```text
/usr/share/nginx/html/main/
  index.html
  js/
  css/
  assets/

/usr/share/nginx/html/pay/
  index.html
  js/
  css/
  assets/

/usr/share/nginx/html/pictures/
  ...
```

对应关系：

```text
主业务首页     -> /usr/share/nginx/html/main
支付首页       -> /usr/share/nginx/html/pay
/pictures/     -> /usr/share/nginx/html/pictures
```

## 5. 部署顺序

1. 部署 `nginx-deployment-online-like.yaml`
2. 把 `conf.d` 下 3 个配置文件复制到 `nginx-conf-files` 对应挂载目录
3. 把主业务和支付前端静态文件复制到 `nginx-html-files` 对应挂载目录
4. 重启 Nginx Pod 或执行 reload

## 6. 访问方式

内网直接访问：

```text
http://节点IP:30080/
http://节点IP:30080/user/login
```

如果要测试指定虚拟主机：

```bash
curl -H "Host: p.gzjjzhy.com" http://节点IP:30080/
curl -H "Host: h5.gzjjzhy.com" http://节点IP:30080/
```

## 7. 注意事项

- 当前 PVC 使用 `local-path + ReadWriteOnce`
- 所以 `replicas` 暂时设为 `1`
- 如果后续改成共享存储，例如 CFS/NFS/RWX，再改成 `2` 副本更接近线上
- `conf.d` 只建议放 `.conf` 配置文件
- 静态网页建议放 `/usr/share/nginx/html`，不要和配置目录混放
