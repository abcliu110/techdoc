# GL总账进化实施规格文档

> 基于 K3Cloud GL总账元规范分析
> 状态：**已采纳全部4项EVO-E建议**
> 版本：v1.0 | 日期：2026-08-06

---

## 文档结构

- §1 EVO-E-GL-001B：确认契约模式
- §2 EVO-E-GL-002A：钩稽关系状态机
- §3 EVO-E-GL-003：会话状态显式化
- §4 EVO-E-GL-004：财务责任边界显式化
- §5 依赖关系与实施顺序
- §6 风险与回退计划

---

## §1 EVO-E-GL-001B：确认契约模式

### 1.1 背景与目标

**源问题**：K3Cloud凭证生成采用异步两阶段模式（Floating窗口 + 后台生成），用户无法感知凭证生成进度，导致"凭证已生成但业务端不知道"的双向盲区。

**EVO-T支撑**：EVO-T-GL-001 财务确认从"时点"到"区间"。

**目标**：将异步Floating窗口替换为确认契约模式，契约在两端同时锁定，消除双向盲区。

### 1.2 契约Schema定义

```
ContractSchema:
  ID: UUID（契约唯一标识）
  SourceBillID: String（业务单据ID）
  SourceFormID: String（业务单据类型）
  VoucherID: String/null（GL凭证ID，null=待确认）
  Status: Enum[Proposed, Confirmed, Failed, Cancelled]
  ProposedAt: DateTime（契约提议时间）
  ConfirmedAt: DateTime/null（确认时间）
  ExpiresAt: DateTime（契约过期时间，超时未确认自动取消）
  TimeoutPolicy: Enum[Cancel, Notify, Escalate]
  ProposedBy: String（提议方系统/用户）
  ConfirmedBy: String/null（确认方）
  LockVersion: Int64（乐观锁版本）
  History: List<ContractEvent>（契约事件历史）
```

### 1.3 契约状态机

```
┌─────────────┐  GenerateSuccess   ┌─────────────┐
│  Proposed   │ ─────────────────→ │  Confirmed  │
│  (提议中)    │                    │  (已确认)    │
└─────────────┘                    └─────────────┘
      │                                   ▲
      │ GenerateFailed                    │ Reconcile
      ▼                                   │
┌─────────────┐                    ┌─────────────┐
│   Failed    │ ─────────────────→ │  Cancelled  │
│  (生成失败)  │   Cancel            │  (已取消)   │
└─────────────┘                    └─────────────┘

超时策略触发路径：
Proposed ──(Timeout)──→ Cancelled
Proposed ──(Timeout+Escalate)──→ Notify(Supervisor)──→ Cancelled
```

### 1.4 业务操作接口

#### 1.4.1 契约提议（业务单据审核时）

```csharp
// IConfirmationContractService.Propose()
Contract ProposeContract(
    string sourceBillID,
    string sourceFormID,
    TimeSpan? timeout = null,
    TimeoutPolicy policy = TimeoutPolicy.Cancel)
{
    // 1. 检查是否已有活跃契约
    var existing = FindActiveContract(sourceBillID);
    if (existing != null)
        throw new ContractAlreadyExistsException(existing.ID);

    // 2. 创建契约，状态=Proposed
    var contract = new Contract
    {
        ID = Guid.NewGuid().ToString(),
        SourceBillID = sourceBillID,
        SourceFormID = sourceFormID,
        Status = ContractStatus.Proposed,
        ProposedAt = DateTime.Now,
        ExpiresAt = DateTime.Now.Add(timeout ?? TimeSpan.FromMinutes(30)),
        TimeoutPolicy = policy,
        ProposedBy = GetCurrentSystemID()
    };

    // 3. 发布契约提议事件
    EventBus.Publish(new ContractProposedEvent(contract));

    return contract;
}
```

#### 1.4.2 契约确认（凭证生成成功时）

```csharp
// IConfirmationContractService.Confirm()
Contract ConfirmContract(
    string contractID,
    string voucherID,
    string confirmedBy)
{
    var contract = LoadContract(contractID);

    // 乐观锁检查
    if (contract.Status != ContractStatus.Proposed)
        throw new InvalidContractStateException(contractID, contract.Status);

    if (DateTime.Now > contract.ExpiresAt)
        throw new ContractExpiredException(contractID);

    // 更新契约状态
    contract.VoucherID = voucherID;
    contract.Status = ContractStatus.Confirmed;
    contract.ConfirmedAt = DateTime.Now;
    contract.ConfirmedBy = confirmedBy;
    contract.LockVersion++;

    // 发布契约确认事件
    EventBus.Publish(new ContractConfirmedEvent(contract));

    // 级联更新业务单据
    UpdateSourceBillStatus(contract.SourceBillID, "ContractConfirmed");

    return contract;
}
```

#### 1.4.3 契约超时处理

```csharp
// IScheduledJob: ContractTimeoutHandler（每分钟执行）
void HandleContractTimeouts()
{
    var expired = FindExpiredContracts();

    foreach (var contract in expired)
    {
        switch (contract.TimeoutPolicy)
        {
            case TimeoutPolicy.Cancel:
                CancelContract(contract.ID, "Timeout");
                break;

            case TimeoutPolicy.Notify:
                NotifyOwner(contract);
                // 宽限期后再检查，仍未确认则取消
                break;

            case TimeoutPolicy.Escalate:
                EscalateToSupervisor(contract);
                NotifyOwner(contract);
                break;
        }
    }
}
```

### 1.5 与现有系统的迁移路径

#### 阶段1：双轨制（并行运行）
- 保留现有异步Floating窗口机制
- 新契约服务在后台记录契约提议
- 契约状态对用户不可见（影子模式）
- 收集契约日志但不触发告警

#### 阶段2：契约可见化
- 业务单据审核后显示"确认中"状态
- 用户可查看契约倒计时
- 契约超时后给出明确提示

#### 阶段3：完全切换
- 移除异步Floating窗口
- 契约超时触发正式告警流程
- 支持契约重提（Cancel后重新Propose）

### 1.6 失败预览（Failure Preview）

| 失败模式 | 条件 | 影响 | 缓解措施 |
|----------|------|------|----------|
| 契约重复提议 | 并发审核同一单据 | 数据不一致 | 唯一约束 + 幂等检查 |
| 凭证生成后契约已超时 | 网络延迟 + 30min太短 | 凭证无法关联 | 动态超时计算 |
| 契约服务单点故障 | 服务重启 | 新契约无法提议 | 数据库持久化 + 服务HA |
| 事件总线消息丢失 | 网络分区 | 状态不一致 | 事件溯源 + 补偿机制 |

### 1.7 数据库变更

```sql
-- 新增契约表
CREATE TABLE GL_ConfirmationContract (
    FID NVARCHAR(36) PRIMARY KEY,
    FSourceBillID NVARCHAR(36) NOT NULL,
    FSourceFormID NVARCHAR(50) NOT NULL,
    FVoucherID NVARCHAR(36) NULL,
    FStatus INT NOT NULL DEFAULT 0,  -- 0=Proposed,1=Confirmed,2=Failed,3=Cancelled
    FProposedAt DATETIME NOT NULL,
    FConfirmedAt DATETIME NULL,
    FExpiresAt DATETIME NOT NULL,
    FTimeoutPolicy INT NOT NULL DEFAULT 0,
    FProposedBy NVARCHAR(100) NOT NULL,
    FConfirmedBy NVARCHAR(100) NULL,
    FLockVersion BIGINT NOT NULL DEFAULT 0,
    FCreatedBy NVARCHAR(100) NOT NULL,
    FCreatedAt DATETIME NOT NULL,
    FUpdatedAt DATETIME NOT NULL
);

CREATE UNIQUE INDEX IX_Contract_SourceBill ON GL_ConfirmationContract(FSourceBillID)
WHERE FStatus IN (0, 1);  -- 仅对活跃契约强制唯一

-- 事件历史表
CREATE TABLE GL_ContractEventLog (
    FID BIGINT IDENTITY(1,1) PRIMARY KEY,
    FContractID NVARCHAR(36) NOT NULL,
    FEventType NVARCHAR(50) NOT NULL,
    FEventData NVARCHAR(MAX) NULL,
    FEventAt DATETIME NOT NULL,
    FEventBy NVARCHAR(100) NULL
);
```

---

## §2 EVO-E-GL-002A：钩稽关系状态机

### 2.1 背景与目标

**源问题**：BAS_BusinessVoucher 映射表是业务单据与GL凭证之间的多对多关系，但K3Cloud未对钩稽关系本身进行状态管理——关系的存在与否就是全部语义，无法表达"钩稽中"、"已确认"、"已解除"等中间状态。

**EVO-T支撑**：EVO-T-GL-002 钩稽关系作为第一公民。

**目标**：为钩稽关系引入状态机，将BAS_BusinessVoucher从简单的关联表升级为有状态的生命周期管理实体。

### 2.2 钩稽关系状态机

```
                      ┌──────────────────────────────┐
                      │      PENDING_CONFIRMATION   │
                      │      (待确认钩稽)             │
                      └──────────────┬───────────────┘
                                     │ Confirm(ConfirmedBy)
                                     ▼
┌───────────────┐  Reject(Reason)  ┌──────────────────────────────┐
│   REJECTED    │ ◄──────────────── │     CONFIRMED               │
│  (已拒绝)      │                  │     (已确认钩稽)              │
└───────────────┘                  └──────────────┬───────────────┘
                                                  │
                                                  │ Break(Reason)
                                                  ▼
                                         ┌──────────────────────────────┐
                                         │     BROKEN                  │
                                         │     (已解除钩稽)              │
                                         └──────────────────────────────┘
                                                  │
                                                  │ ReLink(NewVoucherID)
                                                  ▼
                                         ┌──────────────────────────────┐
                                         │   PENDING_CONFIRMATION       │
                                         │   (重新钩稽待确认)            │
                                         └──────────────────────────────┘
```

### 2.3 BAS_BusinessVoucher扩展字段

```sql
-- 在BAS_BusinessVoucher表上增加状态管理字段
ALTER TABLE BAS_BusinessVoucher
ADD FHookStatus INT NOT NULL DEFAULT 1,      -- 钩稽状态: 0=待确认,1=已确认,2=已拒绝,3=已解除
    FConfirmedBy NVARCHAR(100) NULL,          -- 确认人
    FConfirmedAt DATETIME NULL,               -- 确认时间
    FRejectReason NVARCHAR(500) NULL,         -- 拒绝/解除原因
    FStatusChangeAt DATETIME NULL,            -- 状态变更时间
    FLockVersion BIGINT NOT NULL DEFAULT 0;   -- 乐观锁版本

-- 新增钩稽关系变更历史表
CREATE TABLE BAS_BusinessVoucherHistory (
    FID BIGINT IDENTITY(1,1) PRIMARY KEY,
    FBusinessVoucherID NVARCHAR(36) NOT NULL,
    FFromStatus INT NULL,
    FToStatus INT NOT NULL,
    FChangedBy NVARCHAR(100) NOT NULL,
    FChangedAt DATETIME NOT NULL,
    FReason NVARCHAR(500) NULL,
    FExtendData NVARCHAR(MAX) NULL  -- 变更上下文JSON
);

CREATE INDEX IX_BVHistory_BVID ON BAS_BusinessVoucherHistory(FBusinessVoucherID);
```

### 2.4 核心服务接口

```csharp
// IHookRelationshipService
public interface IHookRelationshipService
{
    // 发起钩稽（业务单据审核时自动调用）
    HookRelationship Propose(string sourceBillID, string sourceBillKey,
                             string voucherID, string glVoucherID);

    // 确认钩稽（财务人员确认后）
    HookRelationship Confirm(long hookID, string confirmedBy, string remark = null);

    // 拒绝/解除钩稽
    HookRelationship Break(long hookID, string reason, string brokenBy);

    // 重新钩稽（原凭证作废，新凭证替代）
    HookRelationship ReLink(long hookID, string newVoucherID, string newGlVoucherID,
                            string reLinkReason);

    // 查询钩稽历史
    List<HookRelationshipHistory> GetHistory(long hookID);

    // 批量状态查询（报表使用）
    Dictionary<long, HookStatus> BatchGetStatus(List<long> hookIDs);
}
```

### 2.5 状态变更规则

| 源状态 | 目标状态 | 触发条件 | 权限要求 | 副作用 |
|--------|----------|----------|----------|--------|
| PENDING | CONFIRMED | 财务人员确认 | GL凭证查看权 | 更新业务单据钩稽状态 |
| PENDING | REJECTED | 财务人员拒绝 | GL凭证查看权 | 记录拒绝原因 |
| CONFIRMED | BROKEN | 原凭证作废/调整 | GL凭证修改权 | 级联断开关联 |
| BROKEN | PENDING | 重新生成凭证 | GL凭证生成权 | 创建新钩稽记录 |
| REJECTED | PENDING | 重新提议 | GL凭证生成权 | 复用原记录，状态回退 |

### 2.6 业务规则引擎集成

```csharp
// 钩稽确认规则引擎
public class HookConfirmationRuleEngine
{
    public HookConfirmResult Evaluate(long hookID, string userID)
    {
        var hook = LoadHook(hookID);
        var voucher = LoadVoucher(hook.FGLVoucherID);
        var accountBook = LoadAccountBook(voucher.FAccountBookID);

        var result = new HookConfirmResult { CanConfirm = true, Warnings = new List<string>() };

        // R1: 凭证已审核
        if (voucher.FDocumentStatus != AuditStatus.Audited)
            result.CanConfirm = false;
            result.BlockReason = "凭证未审核，无法确认钩稽";

        // R2: 业务单据与凭证金额匹配（容差±0.01）
        var sourceAmount = GetSourceBillAmount(hook.FSourceBillID);
        var voucherAmount = GetVoucherEntryAmount(hook.FGLVoucherID, hook.FAccountID);
        if (Math.Abs(sourceAmount - voucherAmount) > 0.01m)
            result.Warnings.Add($"金额存在差异：业务单据{sourceAmount} vs 凭证分录{voucherAmount}");

        // R3: 科目体系一致性
        var sourceAccountSystem = GetBillAccountSystem(hook.FSourceBillID);
        if (voucher.FAccountBookID != sourceAccountSystem)
            result.BlockReason = "凭证账簿与业务单据科目体系不一致";

        return result;
    }
}
```

### 2.7 失败预览

| 失败模式 | 条件 | 影响 | 缓解措施 |
|----------|------|------|----------|
| 并发确认同一钩稽 | 双财务同时确认 | 数据不一致 | 乐观锁 + 幂等确认接口 |
| 凭证删除后钩稽悬空 | 原凭证被物理删除 | 钩稽关系引用失效 | 软删除凭证，钩稽状态级联变更 |
| 多对多关系状态歧义 | 一张凭证钩稽多个单据，部分确认 | 状态不一致 | 引入"部分确认"状态 |
| 历史记录过大 | 高频调整场景 | 存储膨胀 | 历史归档策略（按年分区） |

### 2.8 与EVO-E-GL-001B的集成

钩稽关系状态机与确认契约模式深度集成：

```
契约提议(Proposed) ──→ 钩稽关系创建(Pending)
契约确认(Confirmed) ──→ 钩稽关系确认(Confirmed)
契约取消(Cancelled) ──→ 钩稽关系解除(Broken)
```

契约ID与钩稽关系ID一一对应，形成完整的端到端追踪链。

---

## §3 EVO-E-GL-003：会话状态显式化

### 3.1 背景与目标

**源问题**：K3Cloud报表钻取依赖IUserParameterService管理方案ID（NextEntrySchemeId），但方案ID是浏览器会话级隐式状态——用户关闭浏览器后状态丢失，钻取路径断裂，用户无法恢复"从哪个报表的哪一行钻到了哪个层级"的上下文。

**EVO-T支撑**：EVO-T-GL-003 报表即状态机。

**目标**：将会话级隐式状态升级为服务器端持久化状态，支持会话恢复和跨会话断点续传。

### 3.2 状态持久化Schema

```csharp
// 报表会话状态
public class ReportSessionState
{
    public string SessionID { get; set; }           // 会话唯一标识
    public string UserID { get; set; }              // 用户
    public string ReportFormID { get; set; }        // 报表FormID
    public string RootReportID { get; set; }        // 起始报表实例ID
    public string CurrentReportID { get; set; }     // 当前报表实例ID
    public string CurrentEntrySchemeID { get; set; }// 当前方案ID（来自S4）
    public List<DrillPathNode> DrillPath { get; set; }  // 钻取路径
    public DrillContext CurrentContext { get; set; }    // 当前钻取上下文
    public DateTime CreatedAt { get; set; }
    public DateTime LastAccessedAt { get; set; }
    public int MaxDepth { get; set; } = 10;
    public SessionStatus Status { get; set; }
}

public class DrillPathNode
{
    public int Depth { get; set; }
    public string ReportID { get; set; }
    public string EntrySchemeID { get; set; }
    public string FilterParams { get; set; }       // 当时钻取使用的过滤参数
    public string ClickedCellInfo { get; set; }    // 点击的单元格位置信息
    public DateTime DrilledAt { get; set; }
}
```

### 3.3 服务接口

```csharp
public interface IReportSessionStateService
{
    // 创建会话（报表首次加载时）
    ReportSessionState CreateSession(string userID, string reportFormID,
                                     string rootReportID, string initialSchemeID);

    // 推进钻取（钻入下级报表时）
    ReportSessionState DrillDown(string sessionID, string nextReportID,
                                  string nextSchemeID, DrillContext context);

    // 回退钻取（返回上级）
    ReportSessionState DrillUp(string sessionID, int targetDepth);

    // 获取会话状态
    ReportSessionState GetSession(string sessionID);

    // 恢复会话（用户重新打开浏览器）
    ReportSessionState RestoreSession(string userID, string sessionID);

    // 列出用户最近会话（用于恢复）
    List<ReportSessionSummary> ListRecentSessions(string userID, int limit = 10);

    // 销毁会话
    void DestroySession(string sessionID);
}
```

### 3.4 钻取流程集成

```
报表Cell点击 ──→ 获取当前SessionID
    │
    ├── Session存在 ──→ DrillDown(SessionID, targetReport, schemeID)
    │                      │
    │                      ├── 持久化新钻取节点
    │                      ├── 更新CurrentReportID/CurrentSchemeID
    │                      └── 返回新报表数据
    │
    └── Session不存在 ──→ CreateSession → DrillDown → 返回新报表数据
                              │
                              └── 新Session写入Cookie/URL参数
```

### 3.5 状态持久化表设计

```sql
CREATE TABLE GL_ReportSessionState (
    FSessionID NVARCHAR(36) PRIMARY KEY,
    FUserID NVARCHAR(100) NOT NULL,
    FReportFormID NVARCHAR(50) NOT NULL,
    FRootReportID NVARCHAR(36) NOT NULL,
    FCurrentReportID NVARCHAR(36) NOT NULL,
    FCurrentEntrySchemeID NVARCHAR(100) NOT NULL,
    FDrillPathJSON NVARCHAR(MAX) NOT NULL,  -- DrillPath序列化
    FCurrentContextJSON NVARCHAR(MAX) NULL,
    FMaxDepth INT NOT NULL DEFAULT 10,
    FStatus INT NOT NULL DEFAULT 0,  -- 0=Active,1=Completed,2=Expired
    FCreatedAt DATETIME NOT NULL,
    FLastAccessedAt DATETIME NOT NULL,
    FExpiresAt DATETIME NOT NULL
);

CREATE INDEX IX_Session_UserID ON GL_ReportSessionState(FUserID);
CREATE INDEX IX_Session_UserStatus ON GL_ReportSessionState(FUserID, FStatus)
WHERE FStatus = 0;

-- 清理过期会话（每天执行）
DELETE FROM GL_ReportSessionState
WHERE FExpiresAt < DATEADD(DAY, -7, GETDATE()) AND FStatus != 0;
```

### 3.6 会话恢复UI

当用户重新打开浏览器访问报表时：

1. 检测到URL中无SessionID或SessionID已过期
2. 查询该用户最近7天内的Active会话列表
3. 显示会话恢复对话框：
   ```
   ┌─────────────────────────────────────────┐
   │  恢复报表钻取会话                          │
   ├─────────────────────────────────────────┤
   │  检测到您有未完成的钻取会话：               │
   │                                          │
   │  ○ 总账 → 明细账 → 凭证联查               │
   │    2026-08-06 14:32  |  3层深度          │
   │                                          │
   │  ○ 科目余额表 → 总账                      │
   │    2026-08-06 10:15  |  2层深度          │
   │                                          │
   │  [恢复会话]  [开始新会话]  [清除记录]      │
   └─────────────────────────────────────────┘
   ```

### 3.7 失败预览

| 失败模式 | 条件 | 影响 | 缓解措施 |
|----------|------|------|----------|
| 会话数据过大 | 钻取深度过深 | 存储和序列化开销 | 深度限制（MaxDepth=10）+路径裁剪 |
| 会话过期数据残留 | 用户长时间不操作 | 存储浪费 | 7天过期 + 主动清理 |
| 钻取参数与当前数据不匹配 | 数据刷新后钻取 | 参数失效 | 加载时校验参数有效性，无效则重置 |
| 并发钻取同一会话 | 多Tab打开 | 路径分叉 | 每个Tab独立Session，共享RootReportID |

---

## §4 EVO-E-GL-004：财务责任边界显式化

### 4.1 背景与目标

**源问题**：K3Cloud凭证联查需要两级权限降级（GL子系统凭证权限 → 子系统独立权限），说明凭证的所有权与业务单据的所有权不在同一责任边界内，但系统未显式表达这一分离。

**EVO-T支撑**：EVO-T-GL-003 责任边界不重合。

**目标**：显式化财务责任边界，定义凭证归属规则和跨边界访问控制策略，使权限模型可预测、可解释。

### 4.2 责任边界模型

```
┌─────────────────────────────────────────────────────────────────┐
│                    财务责任边界模型                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  业务子系统边界          │  财务子系统边界                        │
│  (AP/AR/CM/...)         │  (GL总账)                             │
│                         │                                       │
│  业务单据所有权 ─────────┼──→ 凭证所有权                          │
│  FCreateOrgId           │  FAccountBookID                       │
│                         │                                       │
│  业务操作权限 ───────────┼──→ 财务操作权限                        │
│  子系统独立权限项         │  GL_VOUCHER权限项                     │
│                         │                                       │
│  ┌───────────────────┐  │  ┌───────────────────┐               │
│  │ AP应付单 #AP2024001│  │  │ 凭证 #GJ-2024-0032 │               │
│  │ 销售员:张三        │  │  │ 会计:李四          │               │
│  │ 供应商:甲公司      │  │  │ 账簿:销售账        │               │
│  └───────────────────┘  │  └───────────────────┘               │
│         │               │         │                            │
│         └───────────────┼─────────┘                            │
│                    BAS_BusinessVoucher                          │
│                    (跨边界钩稽关系)                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 4.3 凭证归属规则

```csharp
// 凭证归属算法
public class VoucherOwnershipResolver
{
    public VoucherOwnership ResolveOwnership(string voucherID)
    {
        var voucher = LoadVoucher(voucherID);
        var accountBook = LoadAccountBook(voucher.FAccountBookID);

        return new VoucherOwnership
        {
            VoucherID = voucherID,
            // 主归属：账簿（财务责任边界）
            PrimaryOwner = new OwnershipEntity
            {
                Type = OwnershipType.AccountBook,
                ID = accountBook.FID,
                Name = accountBook.FName,
                OrgID = accountBook.FCreateOrgId
            },
            // 次归属：来源业务（溯源需要）
            SecondaryOwners = GetSourceBillOwners(voucherID),
            // 责任人人：当前处理人
            ResponsiblePerson = voucher.FApproverID ?? voucher.FCreatorID,
            // 边界标记
            IsCrossBoundary = HasCrossBoundarySources(voucherID),
            BoundaryClarification = GetBoundaryClarification(voucherID)
        };
    }

    // 跨边界凭证识别
    private bool HasCrossBoundarySources(string voucherID)
    {
        var mappings = LoadBusinessVouchers(voucherID);
        var sourceOrgs = mappings.Select(m => GetSourceOrg(m.FSourceBillID)).Distinct().ToList();
        return sourceOrgs.Count > 1;
    }

    // 边界澄清说明
    private string GetBoundaryClarification(string voucherID)
    {
        var mappings = LoadBusinessVouchers(voucherID);
        if (mappings.Count == 0)
            return "自制凭证，无业务来源，归属账簿责任边界";
        if (mappings.Count > 1)
            return $"多业务来源凭证，跨越{mappings.Count}个业务边界，归属账簿财务边界";
        var sourceFormID = mappings[0].FSourceFormID;
        return $"来源于{sourceFormID}，跨越业务→财务边界";
    }
}
```

### 4.4 权限检查增强

```csharp
// 增强后的凭证权限检查（替代原来的两级降级）
public class EnhancedVoucherPermissionChecker
{
    public PermissionCheckResult CheckPermission(
        string voucherID,
        string userID,
        string requestedPermission)
    {
        var ownership = _resolver.ResolveOwnership(voucherID);

        // 规则1: 账簿权限优先（财务责任边界内）
        var accountBookResult = CheckAccountBookPermission(
            ownership.PrimaryOwner.ID, userID, requestedPermission);
        if (accountBookResult.Granted)
            return new PermissionCheckResult
            {
                Granted = true,
                GrantedBy = "AccountBook",
                Ownership = ownership,
                Explanation = $"用户拥有账簿[{ownership.PrimaryOwner.Name}]的{requestedPermission}权限"
            };

        // 规则2: 业务来源权限兜底（仅查看，不含财务操作）
        if (requestedPermission == "View")
        {
            foreach (var secondary in ownership.SecondaryOwners)
            {
                var bizResult = CheckBusinessPermission(
                    secondary.ID, userID, "View");
                if (bizResult.Granted)
                    return new PermissionCheckResult
                    {
                        Granted = true,
                        GrantedBy = $"BusinessSource:{secondary.Type}",
                        Ownership = ownership,
                        Explanation = $"通过业务来源[{secondary.Name}]的查看权限访问凭证（财务边界外操作受限）",
                        RestrictedPermissions = new[] { "Edit", "Delete", "Approve" }
                    };
            }
        }

        // 规则3: 无权限
        return new PermissionCheckResult
        {
            Granted = false,
            Ownership = ownership,
            Explanation = $"用户对凭证[{voucherID}]既无账簿权限也无业务来源查看权限"
        };
    }
}
```

### 4.5 边界可视化

在凭证查看界面增加责任边界指示器：

```
┌─────────────────────────────────────────────────────────────┐
│  凭证 #GJ-2024-0032  [已审核]  [已过账]                    │
├─────────────────────────────────────────────────────────────┤
│  责任边界：财务边界（账簿：销售账）                         │
│  归属组织：销售部                                           │
│  业务来源：AR_收款单 #AR2024001（应收模块）                 │
│  跨边界标记：否                                             │
│  责任人：李四（会计）                                       │
│                                                             │
│  [查看凭证]  [查看来源单据]  [查看钩稽历史]                │
└─────────────────────────────────────────────────────────────┘
```

### 4.6 失败预览

| 失败模式 | 条件 | 影响 | 缓解措施 |
|----------|------|------|----------|
| 权限检查复杂度上升 | 账簿+业务双重检查 | 性能下降 | 缓存ownership结果，TTL=5分钟 |
| 权限边界模糊场景 | 自制凭证无业务来源 | 归属规则歧义 | 明确定义"自制凭证=纯财务边界" |
| 组织架构调整 | 账簿移交时凭证归属 | 历史凭证责任不清 | 凭证归属历史快照，不可更改 |
| 委托代理场景 | 跨组织代账 | 边界模型冲突 | 支持"代理账簿"特殊边界类型 |

---

## §5 依赖关系与实施顺序

### 5.1 依赖图

```
EVO-E-GL-001B (确认契约模式)
    │
    ├── 依赖：无（基础能力，可最先实施）
    │
    └── 为以下提供基础：
        └── EVO-E-GL-002A（钩稽状态机）

EVO-E-GL-002A (钩稽关系状态机)
    │
    ├── 依赖：EVO-E-GL-001B（契约→钩稽联动）
    │
    └── 为以下提供数据：
        └── EVO-E-GL-004（边界可视化需要钩稽状态）

EVO-E-GL-003 (会话状态显式化)
    │
    ├── 依赖：无（独立模块，可并行实施）
    │
    └── 影响：报表钻取流程变更，需要回归测试

EVO-E-GL-004 (财务责任边界显式化)
    │
    ├── 依赖：EVO-E-GL-002A（钩稽状态影响边界判断）
    │
    └── 影响：权限模型变更，需要权限测试
```

### 5.2 推荐实施顺序

```
第一阶段（并行）
  ├── EVO-E-GL-001B：确认契约模式（基础）
  └── EVO-E-GL-003：会话状态显式化（独立）
        ↓
第二阶段
  └── EVO-E-GL-002A：钩稽关系状态机（依赖契约模式）
        ↓
第三阶段
  └── EVO-E-GL-004：财务责任边界显式化（依赖钩稽状态机）
```

---

## §6 风险与回退计划

### 6.1 总体风险矩阵

| 风险 | 可能性 | 影响 | 风险值 | 缓解策略 |
|------|--------|------|--------|----------|
| 契约服务影响凭证生成性能 | 中 | 高 | 高 | 异步事件，非关键路径隔离 |
| 钩稽状态机引入循环依赖 | 低 | 高 | 中 | 状态机单向，禁止反向触发 |
| 会话持久化存储膨胀 | 高 | 低 | 中 | 7天过期 + 定期归档 |
| 权限模型变更影响现有用户 | 高 | 高 | 高 | 双轨制渐进切换，保持向后兼容 |

### 6.2 回退策略

| EVO-E | 回退触发条件 | 回退步骤 |
|-------|-------------|----------|
| GL-001B | 契约表异常率>1% | 关闭契约提议，业务回退到原异步Floating窗口 |
| GL-002A | 钩稽确认失败率>5% | FHookStatus字段默认值=1（已确认），兼容旧数据 |
| GL-003 | 会话恢复成功率<95% | 降级为URL参数传递，禁用服务器端Session |
| GL-004 | 权限投诉>10次/周 | 保留原两级降级逻辑，新规则仅在日志中记录 |

### 6.3 测试验收标准

```
GL-001B 测试用例：
  [ ] 契约提议→确认→超时→取消 全流程
  [ ] 并发提议同一单据，检测唯一约束
  [ ] 契约过期后凭证生成仍可正常完成（允许延迟确认）
  [ ] 契约服务重启后，未确认契约不丢失

GL-002A 测试用例：
  [ ] 钩稽状态：Pending→Confirmed→Broken 状态转换
  [ ] 状态变更记录完整（BAS_BusinessVoucherHistory）
  [ ] 凭证作废时钩稽状态自动级联变更
  [ ] 多对多关系下部分确认的场景处理

GL-003 测试用例：
  [ ] 钻取→关闭浏览器→重新打开→会话恢复
  [ ] 钻取→返回上级→继续钻取新路径
  [ ] 会话过期后开始新会话
  [ ] 多Tab并发钻取不互相干扰

GL-004 测试用例：
  [ ] 业务来源凭证：用户有业务权限但无账簿权限，可查看不可编辑
  [ ] 纯财务凭证：无业务来源，仅通过账簿权限访问
  [ ] 跨边界凭证：可视化正确显示多来源标记
  [ ] 权限降级逻辑与原系统完全一致（回归测试）
```

---

## 附录A：术语对照表

| 术语 | 英文 | 定义 |
|------|------|------|
| 确认契约 | Confirmation Contract | 业务单据审核与GL凭证生成之间的双向承诺协议 |
| 钩稽关系 | Hook Relationship | 业务单据与GL凭证之间的多对多关联 |
| 会话状态 | Session State | 报表钻取路径的服务器端持久化上下文 |
| 责任边界 | Responsibility Boundary | 凭证归属的业务/财务分界线 |
| 状态机 | State Machine | 具有有限状态和状态转换规则的形式化模型 |

## 附录B：参考文献

1. K3Cloud GL总账元规范分析.md（原始溯因分析文档）
2. GL总账快速参考卡.md（实体速查）
3. K3Cloud财务业务进化提炼.md（AP/AR/GL/CN/CB综合分析）
4. 元规范-既有业务系统评估、进化与重构规范.md（L1统一规范v1.7）
5. 元规范-业务进化分析规范.md（路径A Profile）

---

*文档生成：基于S-M0-Δ-H-P-F溯因链分析*
*最后更新：2026-08-06*
