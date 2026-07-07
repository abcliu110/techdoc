# 插件升级失败 Runbook

## 症状

- 插件升级、卸载、License 降级或私有化验收流程失败。
- 插件处于 `DEGRADED`、`UNINSTALLED` 或“无可回滚版本”的状态。

## 影响

- 当前仓库已有 M4/M5 插件、应用包和 License 生命周期最小内核，但仍主要存在于模块服务和测试中。
- 若误把模块内核当成完整生产链路，可能忽略升级依赖、离线授权和回滚边界。

## 确认命令

先执行轻量门禁：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-release.ps1 -Light
```

再确认：

- 插件 code / version / previousVersion
- 是否存在依赖插件
- 当前 License 策略与降级模式
- 是否已有最近一次成功版本

## 止血动作

1. 停止继续安装或升级同一插件。
2. 若已进入降级态，先维持只读保留，不要删业务数据。
3. 记录 operator、traceId、插件版本、依赖版本和 License 模式。

## 恢复步骤

1. 判定失败类型：
   - 依赖插件不满足。
   - License 降级阻断。
   - 私有化验收项未完成。
   - 没有可回滚版本。
2. 若存在上一个稳定版本，优先回滚到 `previousVersion`。
3. 若仅是授权问题，先恢复离线授权或降级到只读策略，再决定是否继续升级。
4. 若是私有化边界不满足，联动 `docs/compliance/saas-private-boundary.md` 检查离线授权、观测关闭、备份恢复演练等要求。

## 回滚

- 插件升级回滚优先恢复到上一个稳定版本。
- 数据默认保留，不做自动删除式回滚。
- 无可回滚版本时，保持降级只读并人工介入。

## 验证

- 插件状态回到 `ENABLED` 或受控 `DEGRADED`。
- 再次执行轻量门禁通过。
- 回滚和降级边界已记录到发布说明。

## 升级联系人

- 插件生命周期 owner。
- License / 商业策略 owner。
- 私有化交付 owner。
