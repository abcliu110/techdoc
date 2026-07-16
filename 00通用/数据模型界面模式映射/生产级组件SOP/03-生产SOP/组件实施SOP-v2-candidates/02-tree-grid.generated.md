<!-- GENERATED FILE: 请勿手工编辑 -->

# TreeGrid v2 候选实施 SOP

- 源：`02-tree-grid.implementation-sop.json`
- SOP 版本：`0.2.0`
- 规范版本：`0.2.0`
- Digest：`sha256:111ed9054c71c02062eaf18088235c7542eb6f826b223ef6bcd04e43ac5a687e`
- 状态：`ReviewReady`

## 执行步骤

### 1. bindExecution

动作：`bind`

读取目标仓库规则和真实命令，绑定规范、两层流程、DataGrid 基础候选、源码修订、依赖锁和证据目录；任一输入缺失即停止。

实施引用：`/compatibility/v1Authority`、`/risk/upgradeTriggers`

验证引用：无

证据：`repository-binding`、`source-revision`、`dependency-digest`、`command-manifest`

### 2. identityAndHierarchy

动作：`implement-and-verify`

先建立节点、父关系、列和层级列的失败夹具，观察目标失败后实现最小身份与可见树核心；每个结构错误都运行相关回归。

实施引用：`/api/props/columns`、`/api/props/data`、`/api/props/getNodeId`、`/api/props/treeColumnId`、`/behavior/identity/column`、`/behavior/identity/row`

验证引用：`/quality/oracles/invalidHierarchyBlocksInteraction`、`/quality/oracles/activeNodeRecoveryUsesHierarchy`

证据：`red-output`、`green-output`、`contract-error-test`、`hierarchy-model-test`

### 3. expansionAndBranchRequests

动作：`implement-and-verify`

为展开、折叠、分支加载、迟到结果、失败保留和重试逐项建立可控失败注入；一次只完成一个状态切片并保存请求身份轨迹。

实施引用：`/api/features/expansion`、`/api/events/childrenRequest`、`/api/events/retry`、`/behavior/states`、`/behavior/transitions`、`/behavior/recoveryActions`、`/behavior/exceptionFlows`

验证引用：`/quality/oracles/staleBranchResultDoesNotOverwrite`、`/quality/oracles/branchFailureRetainsOtherBranches`

证据：`red-output`、`green-output`、`failure-injection`、`request-identity-log`、`state-transition-test`

### 4. rootQueryCapabilities

动作：`implement-and-verify`

先证明排序与筛选当前缺少正确用户意图或远程根协调，再依次接入完整查询和结果身份；每项完成后运行本地与远程组合回归。

实施引用：`/api/features/sorting`、`/api/features/filtering`、`/api/events/queryChange`、`/api/props/data`

验证引用：`/quality/oracles/sortProducesSingleIntent`、`/quality/oracles/filterPreservesSelection`、`/quality/oracles/remoteRootQueryUsesIdentity`

证据：`red-output`、`green-output`、`interaction-test`、`event-count-test`、`stale-result-test`

### 5. selectionSemantics

动作：`implement-and-verify`

建立独立、级联、排除、未加载后代和 mixed 呈现的失败夹具，确认选择不按可见索引后实现最小语义表达式与受控状态路径。

实施引用：`/api/features/nodeSelection`、`/api/events/nodeSelectionChange`、`/api/controlledState`

验证引用：`/quality/oracles/subtreeSelectionPreservesMeaning`、`/quality/oracles/controlledCapabilitiesDoNotSpeculate`、`/quality/oracles/filterPreservesSelection`

证据：`red-output`、`green-output`、`selection-expression-test`、`controlled-state-test`、`combination-test`

### 6. geometryAndResponsive

动作：`implement-and-verify`

固定深层级、长文本、主题、缩放、视口和滚动夹具，再接入固定列与列宽；每次改变后运行几何、裁切、命中区和可达性扫描。

实施引用：`/api/features/columnPinning`、`/api/features/columnSizing`、`/view/regions`、`/view/regions/header`、`/view/regions/body`、`/view/layout`、`/view/statePresentation`、`/view/tokens`、`/view/responsive`

验证引用：`/quality/visualOracles/headerBodyAlignment`、`/quality/visualOracles/fixedColumnBoundary`、`/quality/visualOracles/scrollReachability`、`/quality/visualOracles/noHierarchyClipping`、`/quality/visualOracles/forcedColorsVisibility`

证据：`red-output`、`green-output`、`geometry-assertion`、`viewport-matrix`、`theme-screenshot`、`clipping-scan`

### 7. keyboardAndAccessibility

动作：`implement-and-verify`

先为层级方向键、首尾导航、单一活动目标、焦点恢复、结构语义和一次性播报建立失败测试，再实现并执行自动与人工复核。

实施引用：`/accessibility/keyboardModel`、`/accessibility/semantics`、`/accessibility/announcements`、`/api/props/ariaLabel`、`/api/props/localeText`

验证引用：`/quality/oracles/hierarchyKeyboardNavigation`、`/quality/oracles/activeNodeRecoveryUsesHierarchy`、`/quality/visualOracles/forcedColorsVisibility`、`/quality/visualOracles/scrollReachability`

证据：`red-output`、`green-output`、`keyboard-test`、`accessibility-scan`、`manual-review`、`focus-trace`

### 8. measureQuality

动作：`measure`

使用规范引用的固定树规模重复采样，保存原始数据、环境、统计方法与包分析；预算失败回到所属能力修复后重测。

实施引用：`/quality/scaleFixtures`、`/quality/performanceBudgets`

验证引用：无

证据：`benchmark-raw-data`、`environment-manifest`、`bundle-report`、`resource-leak-report`

### 9. reviewCandidate

动作：`review`

汇总指针覆盖、失败与恢复证据、DataGrid 回归、风险不变量和未决项，由独立角色逐项评审；作者不得替代批准人。

实施引用：`/risk/invariants`、`/security/rules`

验证引用：`/quality/oracles/sortProducesSingleIntent`、`/quality/oracles/filterPreservesSelection`、`/quality/oracles/hierarchyKeyboardNavigation`、`/quality/oracles/staleBranchResultDoesNotOverwrite`、`/quality/oracles/branchFailureRetainsOtherBranches`、`/quality/oracles/invalidHierarchyBlocksInteraction`、`/quality/oracles/subtreeSelectionPreservesMeaning`、`/quality/oracles/activeNodeRecoveryUsesHierarchy`、`/quality/oracles/remoteRootQueryUsesIdentity`、`/quality/oracles/controlledCapabilitiesDoNotSpeculate`、`/quality/visualOracles/headerBodyAlignment`、`/quality/visualOracles/fixedColumnBoundary`、`/quality/visualOracles/scrollReachability`、`/quality/visualOracles/noHierarchyClipping`、`/quality/visualOracles/forcedColorsVisibility`

证据：`traceability-matrix`、`independent-review`、`risk-review`、`open-item-register`

### 10. packageCandidate

动作：`package`

只从已验证源码和锁定 DataGrid 候选构建产物，运行子路径隔离消费、演示、回滚和完整回归，并将摘要绑定到同一证据清单。

实施引用：`/api/status`、`/compatibility/breakingSurfaces`

验证引用：无

证据：`artifact-digest`、`isolated-consumer-test`、`demo-evidence`、`rollback-test`、`regression-output`
