# T-304/T-305 导入导出包与 Connector 详细设计

> 版本：v0.1
> 里程碑：M3
> 适用任务：T-304、T-305
> 依据：`../03-需求/PRD-产品需求规格说明书.md` REQ-060~063、REQ-085、REQ-088；公共工程规范 17/21/22/28

---

## 1. 目标

实现应用元数据导出/导入和 Connector 出网安全治理。跨环境迁移只能走包，不允许手工 SQL 搬运动动态业务表结构。

## 2. 应用包结构

```text
app-package.zip
  manifest.json
  metadata/
    objects.json
    pages.json
    roles.json
    workflows.json
    plugins.json
  compatibility/
    platform.json
    field-types.json
    expression.json
    page-schema.json
  assets/
    i18n.json
  signatures/
    manifest.sig
```

默认不包含附件二进制、不包含业务数据、不包含密钥明文。

## 3. Manifest

```text
packageCode
packageVersion
sourceTenant
sourceApp
createdBy
createdAt
platformVersion
schemaVersions
requiredPlugins
requiredLicenses
checksum
signature
```

## 4. 导入流程

```text
upload
-> signature verify
-> virus/security scan
-> compatibility check
-> id/code mapping preview
-> impact report
-> dry-run validation
-> import commit
-> publish or save draft
```

导入 commit 必须幂等。

## 5. 恶意包防护

阻断：

```text
跨租户 id 引用
未知字段类型
未知插件
不支持 schemaVersion
密钥明文
路径穿越
超大包
重复 code 覆盖未确认
签名不合法
```

## 6. Connector 模型

```text
ConnectorType
DataSource
CredentialRef
ConnectorPolicy
ConnectorCallLog
```

Connector 调用必须经过：

```text
URL Guard
DNS Rebinding Guard
凭据解密
超时
限流
响应大小限制
脱敏日志
outbox/重试策略
```

## 7. SSRF 防护

禁止访问：

```text
localhost/127.0.0.0/8
内网网段
link-local
cloud metadata
未解析或多次解析漂移域名
非白名单协议
```

## 8. 验收

1. 导出包不含密钥、token、业务数据和附件二进制。
2. 旧包导入给出兼容报告。
3. 恶意包被阻断并给出原因。
4. Connector 访问 localhost、私网、cloud metadata 被阻断。
5. Connector 调用日志脱敏且可按 traceId 排查。
