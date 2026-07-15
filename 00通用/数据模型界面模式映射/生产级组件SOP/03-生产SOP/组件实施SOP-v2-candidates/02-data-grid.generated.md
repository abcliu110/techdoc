<!-- GENERATED FILE: 请勿手工编辑 -->

# DataGrid v2 候选实施 SOP

- 源：`02-data-grid.implementation-sop.json`
- SOP 版本：`0.2.0`
- 规范版本：`0.3.0`
- Digest：`sha256:12f5c61fdd777648af75b60ef8dc9f926976952725000fc7ae0ce55df1c358ea`
- 状态：`Draft`

## 执行步骤

### 1. bindExecution

动作：`bind`

读取目标仓库规则和真实命令，将源码修订、规范版本、两层 SOP 版本与证据目录绑定到同一执行记录；任一输入未绑定即停止。

实施引用：`/compatibility/v1Authority`、`/risk/upgradeTriggers`

验证引用：无

证据：`repository-binding`、`source-revision`、`command-manifest`

### 2. identityCore

动作：`implement-and-verify`

先建立行列身份和重复身份的失败夹具，确认失败原因后实现最小核心，再运行相关回归。

实施引用：`/api/props/columns`、`/api/props/getRowId`、`/behavior/identity/column`、`/behavior/identity/row`

验证引用：`/quality/oracles/duplicateRowIdBlocksInteraction`、`/quality/oracles/selectionStableAfterSort`

证据：`red-output`、`green-output`、`unit-test`、`contract-error-test`

### 3. asyncRecovery

动作：`implement-and-verify`

依次为状态转换、迟到结果、失败保留和重试建立失败注入；每个切片通过后才进入下一个切片。

实施引用：`/api/actions/retryQuery`、`/api/events/queryChange`、`/api/events/retry`、`/api/props/data`、`/behavior/exceptionFlows`、`/behavior/recoveryActions`、`/behavior/states`、`/behavior/transitions`

验证引用：`/quality/oracles/refreshFailureRetainsContext`、`/quality/oracles/staleResultDoesNotOverwrite`、`/quality/visualOracles/stateRetention`

证据：`red-output`、`green-output`、`state-transition-test`、`failure-injection`、`focus-test`

### 4. queryCapabilities

动作：`implement-and-verify`

按排序、筛选、分页的顺序逐项完成失败测试、最小实现和组合回归，不并行冻结多个能力。

实施引用：`/api/features/filtering`、`/api/features/pagination`、`/api/features/sorting`

验证引用：`/quality/oracles/filterPreservesSelection`、`/quality/oracles/remoteQueryIsNotAppliedLocally`、`/quality/oracles/sortProducesSingleIntent`

证据：`red-output`、`green-output`、`interaction-test`、`event-count-test`、`combination-test`

### 5. selectionCapability

动作：`implement-and-verify`

在查询能力回归保持通过的前提下增加选择失败夹具，覆盖排序、筛选和翻页后的身份保持，再实现最小选择切片。

实施引用：`/api/events/rowSelectionChange`、`/api/features/rowSelection`

验证引用：`/quality/oracles/filterPreservesSelection`、`/quality/oracles/selectionStableAfterSort`

证据：`red-output`、`green-output`、`interaction-test`、`combination-test`

### 6. geometryCapabilities

动作：`implement-and-verify`

先固定几何夹具和像素比较方法，再分别接入固定列与列宽能力，并在每次改变后重跑滚动组合测试。

实施引用：`/api/features/columnPinning`、`/api/features/columnSizing`、`/view/layout`、`/view/regions`、`/view/regions/body`、`/view/regions/header`

验证引用：`/quality/visualOracles/fixedColumnBoundary`、`/quality/visualOracles/headerBodyAlignment`、`/quality/visualOracles/scrollReachability`

证据：`red-output`、`green-output`、`geometry-assertion`、`viewport-screenshot`、`scroll-test`

### 7. responsiveStates

动作：`implement-and-verify`

以规范声明的视口、相邻宽度、内容和主题夹具形成状态矩阵；逐格验证后保存截图和可达性记录。

实施引用：`/view/responsive`、`/view/statePresentation`、`/view/tokens`

验证引用：`/quality/visualOracles/noClipping`、`/quality/visualOracles/stateRetention`

证据：`viewport-matrix`、`state-matrix`、`theme-screenshot`、`clipping-scan`

### 8. keyboardAccessibility

动作：`implement-and-verify`

先建立主路径、错误路径和恢复路径的键盘失败测试，再实现单一活动目标、语义和播报；自动扫描后执行人工键盘复核。

实施引用：`/accessibility/announcements`、`/accessibility/keyboardModel`、`/accessibility/semantics`、`/api/props/ariaLabel`、`/view/statePresentation`

验证引用：`/quality/visualOracles/focusVisibility`、`/quality/visualOracles/scrollReachability`

证据：`red-output`、`green-output`、`keyboard-test`、`accessibility-scan`、`manual-review`

### 9. measureQuality

动作：`measure`

使用规范引用的固定夹具重复采样，保存原始数据、环境和统计脚本；任何预算失败都回到对应能力切片修复后重测。

实施引用：`/quality/performanceBudgets`、`/quality/scaleFixtures`

验证引用：无

证据：`benchmark-raw-data`、`environment-manifest`、`bundle-report`

### 10. reviewCandidate

动作：`review`

汇总规范覆盖、测试输出、交互证据、风险复核与未决项，由独立角色逐项检查；作者不得替代批准人。

实施引用：`/risk/invariants`、`/security/rules`

验证引用：`/quality/oracles/duplicateRowIdBlocksInteraction`、`/quality/oracles/filterPreservesSelection`、`/quality/oracles/refreshFailureRetainsContext`、`/quality/oracles/remoteQueryIsNotAppliedLocally`、`/quality/oracles/selectionStableAfterSort`、`/quality/oracles/sortProducesSingleIntent`、`/quality/oracles/staleResultDoesNotOverwrite`、`/quality/visualOracles/fixedColumnBoundary`、`/quality/visualOracles/focusVisibility`、`/quality/visualOracles/headerBodyAlignment`、`/quality/visualOracles/noClipping`、`/quality/visualOracles/scrollReachability`、`/quality/visualOracles/stateRetention`

证据：`traceability-matrix`、`independent-review`、`risk-review`、`open-item-register`

### 11. packageCandidate

动作：`package`

只从已验证的源码修订构建候选，使用打包产物运行隔离消费、回滚和完整回归，并把产物摘要写入同一证据包。

实施引用：`/api/status`、`/compatibility/breakingSurfaces`

验证引用：无

证据：`artifact-digest`、`isolated-consumer-test`、`rollback-test`、`regression-output`
