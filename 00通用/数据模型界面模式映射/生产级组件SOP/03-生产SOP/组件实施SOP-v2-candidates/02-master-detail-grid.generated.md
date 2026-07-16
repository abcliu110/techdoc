<!-- GENERATED FILE: 请勿手工编辑 -->

# MasterDetailGrid v2 候选实施 SOP

- 源：`02-master-detail-grid.implementation-sop.json`
- SOP 版本：`0.2.0`
- 规范版本：`0.2.0`
- Digest：`sha256:c3ef6690cf067d49a724588e06b0e0ea7c2787ceea459c50e8a544e9aaf74b15`
- 状态：`ReviewReady`

## 执行步骤

### 1. bindExecution

动作：`bind`

读取目标仓库规则和真实命令，绑定规范、两层流程、DataGrid 基础候选、源码修订、依赖锁与证据目录；任一输入缺失即停止。

实施引用：`/compatibility/v1Authority`、`/risk/upgradeTriggers`

验证引用：无

证据：`repository-binding`、`source-revision`、`dependency-digest`、`command-manifest`

### 2. compositionAndIdentity

动作：`implement-and-verify`

先建立双表格、主身份、复合明细身份和私有实现泄漏的失败夹具，再仅用公开 DataGrid 边界完成最小组合核心并运行 DataGrid 回归。

实施引用：`/api/props/ariaLabel`、`/api/props/master`、`/api/props/detail`、`/behavior/identity/column`、`/behavior/identity/row`

验证引用：`/quality/oracles/detailIdentityIsMasterScoped`

证据：`red-output`、`green-output`、`public-contract-test`、`declaration-scan`、`composition-test`

### 3. activeMasterContext

动作：`implement-and-verify`

为主激活、主选择、嵌套控件、受控未接受、非受控初始和主行移除逐项建立失败测试，再实现稳定主身份协调器。

实施引用：`/api/features/activeMaster`、`/api/events/activeMasterChange`、`/api/events/activeMasterInvalid`、`/api/controlledState`

验证引用：`/quality/oracles/activationIsIndependentFromSelection`、`/quality/oracles/invalidActiveMasterDoesNotGuess`、`/quality/oracles/activeMasterControlledStateDoesNotSpeculate`

证据：`red-output`、`green-output`、`event-count-test`、`controlled-state-test`、`state-trace`

### 4. detailRequestCoordination

动作：`implement-and-verify`

使用可控请求建立主切换、查询变化、原子分页重置、乱序、初始失败、刷新失败和重试切片；每次只实现一个请求状态转换。

实施引用：`/api/features/detailQuery`、`/api/events/detailRequest`、`/api/actions/retryDetail`、`/behavior/states`、`/behavior/transitions`、`/behavior/recoveryActions`、`/behavior/exceptionFlows`

验证引用：`/quality/oracles/staleDetailResultDoesNotOverwrite`、`/quality/oracles/detailQueryProducesSingleRequest`、`/quality/oracles/detailRefreshFailureRetainsContext`

证据：`red-output`、`green-output`、`failure-injection`、`request-identity-log`、`state-transition-test`、`focus-test`

### 5. masterScopedDetailState

动作：`implement-and-verify`

建立主记录切换下查询、选择、活动单元格和焦点串用的失败夹具，再以稳定主身份隔离明细状态并组合独立明细表格。

实施引用：`/api/props/detail`、`/behavior/identity/row`、`/view/regions/detailGrid`、`/view/regions/detailStatus`

验证引用：`/quality/oracles/detailIdentityIsMasterScoped`、`/quality/oracles/staleDetailResultDoesNotOverwrite`、`/quality/oracles/detailRefreshFailureRetainsContext`

证据：`red-output`、`green-output`、`namespace-isolation-test`、`combination-test`、`console-clean-scan`

### 6. layoutAndRegions

动作：`implement-and-verify`

先固定分栏、堆叠、分隔器、双滚动容器和状态布局夹具，再接入单一尺寸命令、响应式区域和资源清理；每次改变后运行几何扫描。

实施引用：`/api/features/layout`、`/api/events/layoutChange`、`/view/regions`、`/view/layout`、`/view/statePresentation`、`/view/tokens`、`/view/responsive`

验证引用：`/quality/oracles/separatorControlledStateDoesNotSpeculate`、`/quality/visualOracles/splitAndStackReachability`、`/quality/visualOracles/separatorGeometry`、`/quality/visualOracles/detailStateRetention`

证据：`red-output`、`green-output`、`geometry-assertion`、`viewport-matrix`、`listener-leak-test`、`state-matrix`

### 7. keyboardAndAccessibility

动作：`implement-and-verify`

为区域循环、两个独立活动单元格、分隔器键盘、焦点恢复、命名和一次性播报建立失败测试，再执行自动扫描和人工复核。

实施引用：`/accessibility/keyboardModel`、`/accessibility/semantics`、`/accessibility/announcements`、`/view/regions/masterGrid`、`/view/regions/separator`、`/view/regions/detailGrid`

验证引用：`/quality/oracles/f6NavigationKeepsGridContextsSeparate`、`/quality/oracles/invalidActiveMasterDoesNotGuess`、`/quality/visualOracles/focusVisibility`、`/quality/visualOracles/splitAndStackReachability`

证据：`red-output`、`green-output`、`keyboard-test`、`focus-trace`、`accessibility-scan`、`manual-review`

### 8. measureQuality

动作：`measure`

使用规范引用的主从规模和快速切换夹具重复采样，保存原始数据、环境、统计方法、包增量和资源清理结果；失败回到所属能力修复后重测。

实施引用：`/quality/scaleFixtures`、`/quality/performanceBudgets`

验证引用：无

证据：`benchmark-raw-data`、`environment-manifest`、`bundle-report`、`resource-leak-report`

### 9. reviewCandidate

动作：`review`

汇总规范覆盖、请求身份、双表格组合、视觉、风险不变量和未决项，由独立角色逐项检查；作者不得替代批准人。

实施引用：`/risk/invariants`、`/security/rules`

验证引用：`/quality/oracles/activationIsIndependentFromSelection`、`/quality/oracles/staleDetailResultDoesNotOverwrite`、`/quality/oracles/detailQueryProducesSingleRequest`、`/quality/oracles/detailRefreshFailureRetainsContext`、`/quality/oracles/detailIdentityIsMasterScoped`、`/quality/oracles/invalidActiveMasterDoesNotGuess`、`/quality/oracles/f6NavigationKeepsGridContextsSeparate`、`/quality/oracles/separatorControlledStateDoesNotSpeculate`、`/quality/oracles/activeMasterControlledStateDoesNotSpeculate`、`/quality/visualOracles/splitAndStackReachability`、`/quality/visualOracles/separatorGeometry`、`/quality/visualOracles/detailStateRetention`、`/quality/visualOracles/focusVisibility`

证据：`traceability-matrix`、`independent-review`、`risk-review`、`open-item-register`

### 10. packageCandidate

动作：`package`

只从已验证源码和锁定 DataGrid 候选构建产物，运行子路径隔离消费、真实异常演示、回滚和完整回归，并把产物摘要绑定到同一证据清单。

实施引用：`/api/status`、`/compatibility/breakingSurfaces`

验证引用：无

证据：`artifact-digest`、`isolated-consumer-test`、`demo-evidence`、`rollback-test`、`regression-output`
