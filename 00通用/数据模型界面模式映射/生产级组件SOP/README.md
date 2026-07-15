# 生产级组件 SOP

本目录集中管理现有 309 项复杂 UI 规范迁移为 React + TypeScript 生产组件时使用的治理规则、类别门禁、单组件 SOP 和机器索引。

## 当前事实

- 范围：13 类、309 个组件，类别为 01-09、15-18。
- 原型复杂度：B 级 279 个，C 级 30 个。
- 单组件 SOP：309 份。
- 认证状态：全部为 `Draft / not-certified`。
- 暂定风险：R1 80、R2 174、R3 55；最终风险在 Gate 1 冻结。
- 原型基线存在已复现缺口：统一壳层动作被计入主路径，且 `middle-renderers.test.mjs` 当前失败。因此旧 PASS 报告不能作为生产认证证据。

## 目录

```text
生产级组件SOP/
├─ README.md
├─ 00-治理总纲/
├─ 01-类别SOP/              # 13 份
├─ 02-组件SOP/              # 309 份，按 13 类分目录
├─ 03-机器索引/
├─ 04-模板与证据规范/
└─ 05-维护工具/
```

实际运行证据不存放在本目录，仍按版本进入：

`quality/evidence/<component-id>/<component-version>/`

## 使用顺序

1. 阅读[治理与认证规则](00-治理总纲/组件SOP治理与认证规则.md)。
2. 从[机器索引](03-机器索引/component-sops.json)定位组件 SOP。
3. Gate 1 冻结最终风险和责任人，Gate 2 冻结 React 公开契约。
4. 严格执行 RED、GREEN、风险加固、规范迁移和候选发布。
5. 证据写入版本化证据包，再更新索引状态。

## 完整性验证

```powershell
node .\生产级组件SOP\05-维护工具\verify-component-sops.mjs
```

生成器只用于从结构化 catalog 重建文档。修改模板或风险规则后，应先更新校验器，再运行生成器：

```powershell
node .\生产级组件SOP\05-维护工具\generate-component-sops.mjs
node .\生产级组件SOP\05-维护工具\verify-component-sops.mjs
```

类别计数：`{"15":20,"16":20,"17":20,"18":30,"01":25,"02":34,"03":20,"04":30,"05":20,"06":25,"07":20,"08":20,"09":25}`。
