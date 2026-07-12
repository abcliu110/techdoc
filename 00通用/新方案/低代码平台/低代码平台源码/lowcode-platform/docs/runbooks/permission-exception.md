# 权限异常 Runbook

## 症状

- 接口返回无权限、不可访问或字段被裁剪。
- 同一用户在不同请求里权限不一致。
- 缺少 `X-Tenant-Id`、`X-Workspace-Id`、`X-User-Lid`、`X-Role-Codes`、`X-Trace-Id` 等上下文头。

## 影响

- 无租户上下文的请求应该 fail-fast；若误放行，会变成跨租户安全事故。
- 当前仓库未接入 Spring Security 和真实权限中心，默认能力仍以受控头部上下文和最小权限解释为主。

## 确认命令

先确认门禁与文档：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-release.ps1 -Light
```

再确认请求头：

- `X-Tenant-Id`
- `X-Workspace-Id`
- `X-User-Lid`
- `X-Role-Codes`
- `X-Trace-Id`

## 止血动作

1. 缺租户头时直接阻断，不允许回退到“查全量”。
2. 权限异常排查期间，禁止临时把特性开关改成永久租户特判。
3. 如需人工放行，必须记录 traceId、用户、角色和有效期。

## 恢复步骤

1. 检查请求上下文是否完整。
2. 通过 `/api/permission/explain` 获取最小权限解释。
3. 区分三类问题：
   - 头部上下文缺失。
   - 角色 / 数据范围配置不匹配。
   - 代码仍处于演示态，没有接入正式权限中心。
4. 如果是缓存 / 版本滞后问题，优先按照 60 秒内收敛边界处理，不做永久放大授权。

## 回滚

- 回滚到旧版本权限配置或旧快照。
- 不允许通过关闭审计或关闭字段裁剪来“临时解决”问题。

## 验证

- 受影响请求再次调用时，返回口径与期望一致。
- 权限解释结果与 README、SaaS/私有化边界文档一致。

## 升级联系人

- 权限 owner。
- 安全 owner。
- 运维值班人。
