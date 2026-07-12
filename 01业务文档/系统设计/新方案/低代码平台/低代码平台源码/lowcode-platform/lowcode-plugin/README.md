# lowcode-plugin

插件 SPI 边界模块。

## 当前真实范围

- 插件商业能力最小内核：
  - manifest 校验
  - install / enable / disable / uninstall dry-run / uninstall
  - upgrade / rollback 生命周期审计
  - 多次升级后的逐级 rollback 栈
  - 租户内安装状态、依赖版本和审计事件
  - 仓储快照导出 / 导入契约，用于后续持久化替换前回放安装状态、rollback 栈与审计轨迹

## 未上线边界

- 当前仓储仍是内存实现，不代表正式市场持久化。
- 当前没有真实插件代码加载、类加载隔离、签名制品校验或沙箱执行。
- 当前 rollback 栈只覆盖内存状态，不包含数据库迁移、资源文件或外部副作用补偿。
- 当前 License、应用包、市场安装能力仍是最小服务内核，不代表完整商业交付链路。
