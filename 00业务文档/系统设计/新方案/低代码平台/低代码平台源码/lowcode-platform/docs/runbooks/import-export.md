# 导入导出 Runbook

## 症状

- 运行态数据导入预览、导入提交、导出请求出现失败或结果与预期不一致。
- 应用包 / 插件包导入边界不清，导致把演示能力误当成正式包管理。

## 影响

- 数据导入导出本身属于高风险链路，失败可能引发重复创建、字段越权导出或审计缺失。
- 当前仓库的“应用包 / 插件包 / License 生命周期”仍以模块内核和测试为主，不代表已经具备正式市场能力。

## 确认命令

优先跑轻量门禁：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-release.ps1 -Light
```

再确认当前边界：

- 运行态 HTTP 已暴露 `export`、`importPreview`、`importCommit`。
- 应用包与插件升级目前以 `lowcode-plugin` 模块内核和测试为主。
- 当前还新增了最小市场安装门面：`/api/packages/install`、`/api/packages`、`/api/packages/{packageCode}/disable`、`/api/packages/{packageCode}/uninstall-dry-run`。
- 以上市场安装链路当前只做 manifest / 依赖 / license / runtime 约束校验，并把安装状态保存在内存仓储中，不代表正式持久化市场能力。

## 止血动作

1. 出现部分成功时，先暂停重复导入，保留 taskId、traceId 和失败行信息。
2. 不允许用手工 SQL 搬运代替应用包导入。
3. 不允许把无签名、无来源登记的压缩包当作正式应用包。

## 恢复步骤

1. 区分两类导入导出：
   - 运行态业务数据导入导出。
   - 应用包 / 插件包导入导出。
2. 对运行态数据：
   - 先做预览。
   - 再做提交。
   - 检查是否启用了幂等键和字段级权限裁剪。
3. 对应用包 / 插件包：
   - 先核对 `docs/compliance/dependency-admission.md` 和 `docs/compliance/license-sbom.md`。
   - 当前版本只接受受控演练；可使用最小安装 / 列表 / 禁用 / 卸载预检接口做验证，但不当作正式市场安装链路。

## 回滚

- 数据导入：以业务级回滚为准，避免直接删库式回退。
- 应用包：按插件升级 / 卸载回滚策略处理，不允许跳过依赖和 License 检查。
- 当前最小市场安装链路使用内存态安装记录；回滚方式是重启进程或回退本次变更，不涉及持久化数据修复。

## 验证

- 再跑 `verify-release.ps1 -Light`。
- 确认导入导出边界已经在 README 和合规文档中明确。
- 如果验证市场安装最小链路，额外确认：
  - `POST /api/packages/install` 能返回稳定的 `installed/errors/state` 结构。
  - `GET /api/packages` 能列出同租户安装状态。
  - `POST /api/packages/{packageCode}/disable` 与 `POST /api/packages/{packageCode}/uninstall-dry-run` 只操作当前租户作用域。

## 升级联系人

- 运行态数据 owner。
- 插件 / 应用包 owner。
- 安全与合规 owner。
