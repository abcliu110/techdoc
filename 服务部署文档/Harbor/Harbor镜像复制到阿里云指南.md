# Harbor 镜像复制到阿里云指南

## 一、前提条件

- Harbor 已部署并正常运行
- 已有阿里云容器镜像服务账号
- 已在阿里云创建个人版或企业版镜像仓库

---

## 二、获取阿里云镜像仓库信息

### 1. 登录阿里云容器镜像服务

访问：https://cr.console.aliyun.com/

### 2. 获取仓库地址

```
个人版实例：
https://crpi-<实例ID>.cn-hangzhou.personal.cr.aliyuncs.com

企业版实例：
https://<实例名称>-registry.cn-hangzhou.cr.aliyuncs.com
```

### 3. 获取访问凭证

```
系统管理 → 访问凭证
- 用户名：阿里云账号全名（如：example@aliyun.com）
- 密码：设置的固定密码（不是阿里云登录密码）
```

---

## 三、在 Harbor 中配置阿里云镜像仓库

### 1. 添加镜像仓库端点

1. 登录 Harbor Web UI
2. 进入 `Administration` → `Registries`
3. 点击 `NEW ENDPOINT`
4. 填写配置：

| 配置项 | 值 | 说明 |
|--------|-----|------|
| Provider | `Alibaba Cloud CR` | 选择阿里云容器镜像服务 |
| Name | `aliyun-acr` | 自定义名称 |
| Endpoint URL | `https://crpi-xxx.cn-hangzhou.personal.cr.aliyuncs.com` | 阿里云仓库地址 |
| Access ID | `your-username@aliyun.com` | 阿里云用户名 |
| Access Secret | `your-password` | 阿里云固定密码 |
| Verify Remote Cert | 勾选 | 验证 SSL 证书 |

5. 点击 `TEST CONNECTION` 测试连接
6. 测试成功后点击 `OK` 保存

---

## 四、创建镜像复制规则

### 1. 进入复制管理

```
Administration → Replications → NEW REPLICATION RULE
```

### 2. 配置复制规则

| 配置项 | 值 | 说明 |
|--------|-----|------|
| Name | `sync-to-aliyun` | 规则名称 |
| Description | `同步镜像到阿里云` | 规则描述（可选） |
| Replication mode | `Push-based` | 推送模式 |
| Source registry | `-` | 本地 Harbor |
| Source resource filter | 见下方 | 过滤规则 |
| Destination registry | `aliyun-acr` | 选择刚创建的端点 |
| Destination namespace | `lgy-images` | 阿里云命名空间 |
| Trigger Mode | 见下方 | 触发方式 |

### 3. 配置源资源过滤器

**按项目名称过滤：**
```
Resource filter:
  Name: nms4cloud-*
  Tag: prod-*, v*
```

**按标签过滤：**
```
Resource filter:
  Name: **
  Tag: prod-*, release-*
  Label: production
```

### 4. 配置触发模式

| 模式 | 说明 | 适用场景 |
|------|------|---------|
| Manual | 手动触发 | 测试或按需同步 |
| Scheduled | 定时触发 | 每天凌晨 2:00 自动同步 |
| Event Based | 事件触发 | 镜像推送到 Harbor 时自动同步 |

**推荐配置：**
```
Trigger Mode: Event Based
  - 勾选 "Delete remote resources when locally deleted"（可选）
```

### 5. 保存规则

点击 `SAVE` 保存复制规则。

---

## 五、手动触发镜像同步

### 1. 触发同步

```
Administration → Replications → 选择规则 → REPLICATE
```

### 2. 查看同步进度

```
Replications → Executions → 查看任务状态
```

状态说明：
- `Succeed`：同步成功
- `In Progress`：同步中
- `Failed`：同步失败（点击查看详细日志）

---

## 六、验证镜像同步

### 1. 在阿里云查看镜像

```
阿里云容器镜像服务 → 镜像仓库 → lgy-images 命名空间
```

### 2. 拉取测试

```bash
# 登录阿里云镜像仓库
docker login crpi-xxx.cn-hangzhou.personal.cr.aliyuncs.com \
  -u your-username@aliyun.com \
  -p your-password

# 拉取镜像
docker pull crpi-xxx.cn-hangzhou.personal.cr.aliyuncs.com/lgy-images/nms4cloud-gateway:prod-v1.0.0
```

---

## 七、常见问题

### 问题1：测试连接失败

**错误信息：**
```
Failed to ping endpoint: unauthorized
```

**原因：**
- Access ID 或 Access Secret 错误
- 阿里云固定密码未设置

**解决：**
```
阿里云容器镜像服务 → 访问凭证 → 设置固定密码
```

---

### 问题2：同步失败 - 命名空间不存在

**错误信息：**
```
namespace not found: lgy-images
```

**原因：**
阿里云中未创建对应的命名空间

**解决：**
```
阿里云容器镜像服务 → 命名空间 → 创建命名空间
名称：lgy-images
```

---

### 问题3：同步失败 - 镜像已存在

**错误信息：**
```
image already exists
```

**原因：**
阿里云中已有同名同 tag 的镜像

**解决：**
```
复制规则配置中勾选：
"Override" - 覆盖已存在的镜像
```

---

### 问题4：同步速度慢

**原因：**
- 网络带宽限制
- 镜像体积大

**优化：**
```
1. 使用定时同步，避开业务高峰期
2. 配置过滤规则，只同步必要的镜像
3. 使用阿里云同地域的 Harbor 部署
```

---

## 八、自动化同步最佳实践

### 1. 生产环境推荐配置

```
复制规则：
  Name: prod-to-aliyun
  Source filter:
    - Name: nms4cloud-*
    - Tag: prod-*, v[0-9]*
  Destination: aliyun-acr
  Namespace: production
  Trigger: Event Based
  Override: 启用
  Delete remote: 禁用（保留历史版本）
```

### 2. 测试环境推荐配置

```
复制规则：
  Name: test-to-aliyun
  Source filter:
    - Name: nms4cloud-*
    - Tag: test-*, dev-*
  Destination: aliyun-acr
  Namespace: testing
  Trigger: Manual
  Override: 启用
  Delete remote: 启用（自动清理）
```

---

## 九、监控和告警

### 1. 查看同步历史

```
Administration → Replications → Executions
```

可以看到：
- 同步时间
- 同步状态
- 同步的镜像数量
- 失败原因

### 2. 配置 Webhook 通知

```
Administration → Webhooks → NEW WEBHOOK
```

配置：
```
Name: replication-notify
Endpoint URL: https://your-webhook-url
Events:
  - Replication finished
  - Replication failed
```

---

## 十、清理和维护

### 1. 删除复制规则

```
Administration → Replications → 选择规则 → DELETE
```

### 2. 删除镜像仓库端点

```
Administration → Registries → 选择端点 → DELETE
```

注意：删除端点前需要先删除关联的复制规则。

---

## 十一、命令行操作（可选）

### 使用 Harbor API 触发同步

```bash
# 获取复制规则 ID
curl -u admin:Harbor12345 \
  http://harbor-core.harbor/api/v2.0/replication/policies

# 手动触发同步
curl -X POST \
  -u admin:Harbor12345 \
  -H "Content-Type: application/json" \
  -d '{"policy_id": 1}' \
  http://harbor-core.harbor/api/v2.0/replication/executions
```

---

## 总结

通过 Harbor 的镜像复制功能，可以实现：

1. ✅ 自动同步镜像到阿里云
2. ✅ 灵活的过滤规则（按项目、标签、Tag）
3. ✅ 多种触发方式（手动、定时、事件）
4. ✅ 支持多个目标仓库
5. ✅ 完整的同步历史和日志

**推荐使用场景：**
- 生产环境镜像备份到云端
- 多地域镜像分发
- 混合云镜像同步
