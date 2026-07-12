# T-203 Model Builder 详细设计

> 版本：v0.1
> 里程碑：M2
> 适用任务：T-203
> 依据：`../03-需求/PRD-产品需求规格说明书.md` REQ-001~013、REQ-070~078；`../04-架构决策/01-元模型设计.md`、`../04-架构决策/03-设计器与前端设计.md`
> 5A 状态：baseline-approved。`../04-架构决策/UI-and-Component-Decision-Matrix.md` 已人工接受；本设计作为 M2 UI 详细设计基线，禁止提前在 M0/M1 实现。
> 决策门禁：REQ-070~REQ-078 的产品边界已确认，但下文 `ObjectExtension` 等商用预留项的名称、字段和交互结构来自 proposed ADR。对应 ADR accepted 前只能展示不锁定数据结构的“未运行能力”占位，不得反向固化后端契约。

---

## 1. 目标

提供对象与字段建模 UI，使设计者通过表格式编辑完成业务对象、字段、关系、扩展预留和发布前校验。

## 2. 页面结构

```text
对象列表
  -> 对象详情
     -> 字段表格
     -> 关系视图
     -> 状态/动作入口
     -> 权限入口
     -> 发布影响分析
```

## 3. 字段表格

列：

```text
code
name
fieldType
required
unique
defaultValue
options summary
inList
inFilter
permLevel
sortNo
```

高级配置走抽屉，按 fieldType 动态展示 options schema。

## 4. 关系建模

link/table/multilink 字段保存时自动生成 RelationDef。关系视图只读展示：

```text
sourceObject
sourceField
relationType
targetObject
onDelete
```

onDelete 必须显式选择，默认 restrict。

## 5. 商用预留能力 UI

M2 只提供只读或草稿配置入口：

```text
ObjectExtension
Conversion/WriteBack/LinkTrace
FlexField/OrgRelation/CodeRule
Report/Print/Menu/I18n
Package/License
```

界面必须明确标注“预留，未运行”，发布时按后端 M0/M1 能力阻断或纳入快照。

## 6. 校验反馈

保存草稿：允许不完整配置，但返回 warning。

发布前校验：必须阻断：

```text
重复 code
悬空 link
非法 field options
循环公式
页面 schema 悬空字段
权限引用不存在角色
M0/M1/M2 未支持的运行能力
```

## 7. 验收

1. 设计者可用表格创建 `customer/order/order_item`。
2. 字段类型切换时 options 表单随类型变化。
3. link/table 字段自动生成关系。
4. 删除或改 code 对已发布对象给出影响分析。
5. 商用预留配置不能误导为已运行能力。

## 8. 5A 门禁补齐

### 8.1 需求引用

| requirementId | storyId | 承接说明 |
|---|---|---|
| REQ-001~REQ-013 | US-MODEL-001、US-MODEL-002 | 对象、字段、关系、状态、动作、规则、发布前校验 |
| REQ-070~REQ-078 | US-COMMERCIAL-001、US-PACKAGE-001 | 商用预留能力只采集配置和阻断误执行 |

### 8.2 ADR 与决策矩阵引用

| 来源 | 承接行 |
|---|---|
| `../04-架构决策/Domain-Model-Decision-Matrix.md` | BusinessObject 聚合边界、标准对象与客户扩展、关系与单据链路 |
| `../04-架构决策/UI-and-Component-Decision-Matrix.md` | 设计器交互范式 |
| `../04-架构决策/Data-Model-Decision-Matrix.md` | 字段类型与物理列映射、元数据版本 |
| `../04-架构决策/ADR/ADR-LOWCODE-DM-001-minimal-domain-model.md` | 最小业务元模型 |

### 8.3 UI 设计系统对照

Model Builder 采用表格编辑 + 抽屉高级配置。AntD Table/Form/Drawer 只作为底座；字段类型 options 表单由平台 schema 驱动，不能写死在页面组件中。

### 8.4 可访问性规则

| 规则 | 验收方式 |
|---|---|
| 字段表格可键盘编辑 | 行切换、下拉、保存、取消可键盘完成 |
| 抽屉焦点管理 | 打开时聚焦首个控件，关闭后回到触发行 |
| 校验结果可感知 | warning/blocking 通过文本、图标和 aria-live 提示 |
| 影响分析可扫读 | 删除/改 code 的影响列表提供对象、字段、页面、权限引用 |

### 8.5 状态组合

| 权限状态 | 数据状态 | 交互状态 | Model Builder 行为 |
|---|---|---|---|
| design none | draft/published | any | 不允许进入对象编辑 |
| design read | published | idle | 只读查看对象和字段，不能保存草稿 |
| design write | draft/dirty/error | editing/submitting | 可编辑，保存草稿返回 warning，发布前 blocking 阻断 |
| design admin | conflict/stale | conflict | 显示版本冲突和影响分析，不自动覆盖 |

### 8.6 失败模式

| 失败模式 | 处置 |
|---|---|
| 字段 code 重复或改名破坏已发布引用 | 保存 warning，发布 blocking；输出影响分析 |
| link/table 生成关系失败 | 阻断发布并提示源字段、目标对象、onDelete |
| 商用预留能力被误认为可运行 | UI 明确标注“预留，未运行”，发布时由后端能力矩阵阻断 |
| 字段类型 options 不兼容 | 按 FieldType Capability Vector 校验并阻断 |

### 8.7 5.0 自检

| 检查项 | 结果 |
|---|---|
| 完整性 | 已补需求引用、ADR/矩阵引用、设计系统、可访问性、状态组合、失败模式 |
| 一致性 | 与 UI 矩阵 Mixed Builder 和领域模型矩阵一致 |
| 可测试性 | 已映射到字段表格、关系生成、影响分析、商用预留阻断测试 |
| 可追溯性 | 需由 CapabilityTraceMatrix 登记 T-203 与矩阵关系 |
