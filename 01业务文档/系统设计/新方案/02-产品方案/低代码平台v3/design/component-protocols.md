# V3 表单设计器组件协议

## 1. 目标

本协议定义 V3 组件库的设计期物料、Schema 节点、合法嵌套、数据绑定、状态权限和运行时能力。组件只有同时满足下列条件才算“可用”，不能仅在组件面板显示图标：

1. 可从组件面板搜索、拖入并通过键盘添加。
2. 拖入后真实修改 Schema，可序列化并反显。
3. 画布、大纲、面包屑和属性面板共享同一节点选择状态。
4. 对 `before / inside / after` 落点执行合法父子校验。
5. 支持撤销、重做、复制、移动和删除。
6. 具备数据绑定、校验、权限、状态和设备布局协议。
7. 在设计态、预览态和运行态有明确降级与错误边界。

## 2. 统一物料协议

```ts
type ComponentKind =
  | 'layout'
  | 'field'
  | 'data'
  | 'business'
  | 'navigation'
  | 'content'
  | 'analytics'
  | 'extension';

interface ComponentMaterial {
  type: string;
  title: string;
  kind: ComponentKind;
  icon: string;
  keywords: string[];
  platforms: Array<'desktop' | 'tablet' | 'mobile'>;
  pageTypes: Array<'master-data' | 'bill' | 'dynamic-form' | 'report'>;
  accepts: string[];
  requires?: Requirement[];
  creates?: ChildTemplate[];
  defaultProps: Record<string, unknown>;
  propertyPanels: Array<'property' | 'layout' | 'data' | 'rule' | 'permission' | 'event'>;
  capabilities: Capability[];
}

interface ComponentNode {
  id: string;
  type: string;
  parentId: string | null;
  children: string[];
  props: Record<string, unknown>;
  binding?: DataBinding;
  permission?: PermissionPolicy;
  stateOverrides?: Record<string, Record<string, unknown>>;
  deviceOverrides?: Record<string, Record<string, unknown>>;
}
```

物料协议和运行时组件协议必须分开。物料负责面板分类、图标、拖拽、创建模板、属性编辑和准入；运行时组件只负责根据 Schema 渲染及产生标准事件。

## 3. 组件目录

V3 注册表当前枚举 106 个组件，其中 103 个属于本地交互原型冻结范围，3 个属于明确禁用的规划项。下列协议表按核心协议族归纳，完整逐成员清单以 `prototype/component-registry.mjs` 和完整性账本 `variant-inventory.yaml` 为准。`P0` 为首批必须具备完整交互的组件，`P1` 为企业能力扩展，`P2` 为授权或外部服务依赖组件。

### 3.1 布局容器（13）

| 优先级 | 组件 | Schema 类型 | 子节点约束 | 关键能力 |
|---|---|---|---|---|
| P0 | 字段布局 | `FieldLayout` | 仅字段、字段组 | 1-6 列、整行、响应式换行 |
| P0 | 字段组 | `FieldGroup` | 字段、内联字段组 | 标题、折叠、摘要、状态控制 |
| P0 | Flex 容器 | `Flex` | 除页面根外的通用节点 | 方向、换行、对齐、间距、伸缩 |
| P0 | 分区 | `Section` | 字段布局、容器、业务组件 | 语义标题、工具栏、内容区 |
| P0 | 分栏 | `Columns` | 仅 `Column` | 列比例、断点、最小宽度 |
| P0 | 栏 | `Column` | 通用节点 | 宽度、跨列、设备覆盖 |
| P0 | 页签 | `Tabs` | 仅 `TabPane` | 水平/垂直、关闭、锁定、溢出 |
| P0 | 页签页 | `TabPane` | 通用节点 | 标题、徽标、懒加载、可见规则 |
| P0 | 向导 | `Wizard` | 仅 `WizardStep` | 步骤状态、前进校验、分支 |
| P0 | 向导步骤 | `WizardStep` | 通用节点 | 完成条件、进入/离开事件 |
| P1 | 分割容器 | `SplitPane` | 2 个 `SplitRegion` | 横纵分割、最小尺寸、位置记忆 |
| P1 | 高级面板 | `AdvancedPanel` | 摘要、工具栏、内容区插槽 | 标题摘要、操作区、按需加载 |
| P1 | 栅格卡片容器 | `DashboardGrid` | 仅 `DashboardCard` | 12 列卡片编排、位置序列化 |

轮播容器属于展示型页面能力，列入内容组件，不作为企业表单的首选布局。

### 3.2 字段组件（23）

| 优先级 | 组件 | Schema 类型 | 绑定值 | 特有协议 |
|---|---|---|---|---|
| P0 | 单行文本 | `TextField` | `string` | 长度、掩码、前后缀 |
| P0 | 多行文本 | `TextArea` | `string` | 字数、自动高度 |
| P0 | 多语言文本 | `LocaleText` | locale map | 默认语言、缺失回退 |
| P0 | 整数 | `IntegerField` | `integer` | 步进、范围、千分位 |
| P0 | 小数 | `DecimalField` | `decimal` | 精度、舍入、单位 |
| P0 | 金额 | `MoneyField` | decimal + currency | 币种、精度、汇率语义 |
| P0 | 百分比 | `PercentField` | `decimal` | 存储值/显示值转换 |
| P0 | 日期 | `DateField` | ISO date | 业务日、范围限制 |
| P0 | 日期时间 | `DateTimeField` | ISO datetime | 时区、精度 |
| P0 | 时间 | `TimeField` | ISO time | 步长、范围 |
| P0 | 下拉单选 | `SelectField` | scalar | 静态/查询选项、空值 |
| P0 | 下拉多选 | `MultiSelectField` | scalar array | 上限、标签折叠 |
| P0 | 单选组 | `RadioGroup` | scalar | 横纵排列 |
| P0 | 复选组 | `CheckboxGroup` | scalar array | 全选、互斥规则 |
| P0 | 开关 | `SwitchField` | boolean | 真/假业务值映射 |
| P0 | 基础资料 | `ReferenceField` | reference id | 编码/名称映射、过滤、权限 |
| P0 | 组织 | `OrganizationField` | org id | 组织权限、业务范围 |
| P0 | 人员 | `PersonField` | person id | 组织过滤、在职状态 |
| P0 | 树选择 | `TreePicker` | node id(s) | 展开、勾选、父子联动、懒加载 |
| P1 | 上级基础资料 | `ParentReferenceField` | self reference id | 禁止自身及后代、路径展示 |
| P1 | 主数据内码 | `MasterDataKeyField` | immutable key | 只读、跨系统映射 |
| P1 | 地址 | `AddressField` | structured address | 级联地区、详细地址、标准化 |
| P1 | 地理位置 | `GeoField` | longitude/latitude | 定位授权、精度、地图联动 |

所有字段统一支持：必填、只读、隐藏、默认值、帮助、占位、校验、值变化事件、初始/新增/修改/查看/提交/审核状态覆盖和角色权限裁剪。

### 3.3 数据与单据组件（10）

| 优先级 | 组件 | Schema 类型 | 实体关系 | 特有协议 |
|---|---|---|---|---|
| P0 | 数据表格 | `DataGrid` | 查询结果或集合 | 列、排序、过滤、选择、分页、汇总 |
| P0 | 单据体 | `EntryGrid` | 主实体的一对多子实体 | 行状态、增删复制、批量填充、提交差量 |
| P0 | 子单据体 | `SubEntryGrid` | 分录实体的一对多子实体 | 必须绑定父单据体、当前父行联动 |
| P0 | 树形单据体 | `TreeEntryGrid` | 自关联分录实体 | 层级编辑、插入、拖拽、循环校验 |
| P1 | 树形子单据体 | `TreeSubEntryGrid` | 父分录下的树形子实体 | 父分录绑定 + 树父键双约束 |
| P1 | 卡片分录 | `CardEntry` | 主实体的一对多子实体 | 每行一张卡片、卡片模板 |
| P1 | 子卡片分录 | `SubCardEntry` | 卡片行的一对多子实体 | 父卡片选中联动 |
| P0 | TreeGrid | `TreeGrid` | 层级查询或自关联实体 | 展开、焦点、选择、编辑、加载、拖拽分态 |
| P1 | 普通表格 | `Table` | 非实体二维数据 | 轻量呈现、无单据状态机 |
| P2 | 电子表格 | `Spreadsheet` | 单元格模型 | 公式、冻结、合并、打印、授权降级 |

#### 子单据体启用条件

组件面板只有在当前 Schema 中存在可绑定的父 `EntryGrid` 或 `TreeEntryGrid` 时才启用 `SubEntryGrid`。创建事务必须同时写入：

- `parentEntryNodeId`：设计树中的父分录节点；
- `parentEntityId`：父分录实体；
- `entityId`：子分录实体；
- `relation.parentKey` 与 `relation.foreignKey`：持久化关系。

视觉父子关系和数据父子关系分别保存，不能从 DOM 嵌套反推实体关系。删除父行必须级联处理未保存子行；服务端必须再次校验父子归属。

### 3.4 业务与流程组件（7）

| 优先级 | 组件 | Schema 类型 | 关键能力 |
|---|---|---|---|
| P0 | 操作栏 | `ActionBar` | 命令、可用条件、权限、忙碌态 |
| P0 | 查询过滤 | `QueryFilter` | 快速条件、查询方案、重置、保存视图 |
| P1 | 状态条 | `StatusBar` | 单据状态、流程状态、风险提示 |
| P1 | 审批记录 | `ApprovalHistory` | 节点、处理人、意见、附件、时间线 |
| P1 | 流程操作 | `WorkflowActions` | 提交、撤回、同意、驳回、转交 |
| P1 | 附件 | `AttachmentField` | 上传、预览、版本、权限、病毒扫描状态 |
| P1 | 操作日志 | `OperationLog` | 操作人、时间、字段差异、来源 |

### 3.5 导航、内容、分析与扩展组件（11）

| 优先级 | 组件 | Schema 类型 | 关键能力 |
|---|---|---|---|
| P1 | 树浏览器 | `TreeBrowser` | 单选/多选、搜索定位、懒加载、主从联动 |
| P1 | 分栏浏览器 | `ColumnBrowser` | 逐层钻取、路径、层级缓存 |
| P1 | 导航菜单 | `NavigationMenu` | 权限裁剪、激活路由、折叠 |
| P1 | 富文本 | `RichText` | 格式、粘贴清洗、只读预览 |
| P1 | Markdown | `MarkdownEditor` | 编辑/预览、链接安全 |
| P1 | 图片 | `Image` | 上传/URL、裁切、替代文本 |
| P2 | 音视频 | `MediaPlayer` | 播放控制、字幕、失败边界 |
| P1 | 轮播 | `Carousel` | 页面/媒体项、自动播放可关闭 |
| P1 | 图表 | `Chart` | 维度、指标、筛选、联动、空状态 |
| P2 | 轻分析 | `AnalyticsWorkspace` | 数据集、钻取、联动、移动/大屏 |
| P2 | IFrame/HTML 扩展 | `ExtensionHost` | 域名白名单、鉴权、CSRF、沙箱、错误边界 |

## 4. 合法嵌套规则

校验器采用“默认拒绝、显式允许”。任何未知组件类型或未声明关系都不能落入画布。

| 父节点 | 允许子节点 | 禁止项 |
|---|---|---|
| `FormPage` | Section、FieldLayout、Flex、Tabs、Wizard、SplitPane、业务组件 | 字段列节点、WizardStep、TabPane |
| `FieldLayout` | 字段、FieldGroup | DataGrid、EntryGrid、页面、导航 |
| `Columns` | Column | 其他全部节点 |
| `Tabs` | TabPane | 其他全部节点 |
| `Wizard` | WizardStep | 其他全部节点 |
| `SplitPane` | 恰好 2 个 SplitRegion | 第 3 个区域、字段直接子节点 |
| `EntryGrid` | EntryColumn、SubEntryGrid（详情插槽） | 页面根、普通字段直接子节点 |
| `TreeEntryGrid` | EntryColumn、SubEntryGrid、TreeSubEntryGrid | 自身及祖先节点 |
| `DataGrid/TreeGrid` | GridColumn、工具栏插槽 | 表单字段直接子节点 |

所有移动事务还必须拒绝：

- 把节点放入自身或后代，形成循环；
- 把仅桌面组件放入移动专属页面且无降级策略；
- 把单据体放入基础资料页面但未配置实体关系；
- 把子单据体放入没有父分录绑定的容器；
- 在只读或发布锁定状态修改 Schema；
- 跨页面移动后产生重复节点 ID、字段绑定冲突或实体越权。

失败时必须保持原 Schema 不变，并在落点旁说明具体原因。

## 5. 拖放事务

```ts
interface DropIntent {
  source: { kind: 'material' | 'node'; id: string };
  targetId: string;
  position: 'before' | 'inside' | 'after';
}

interface DropResult {
  accepted: boolean;
  nextSchema?: FormSchema;
  selectedNodeId?: string;
  reasonCode?: string;
  message?: string;
}
```

处理顺序固定为：解析意图、检查编辑锁、解析目标、校验父子、校验实体依赖、生成不可变变更、校验全树、压入撤销栈、切换选择、同步四个视图。拖动动画和 DOM 位置不能作为成功证据，序列化后的 Schema 才是权威结果。

键盘等价操作为：组件面板聚焦物料后按 Enter 打开可用落点列表；选择目标和位置后确认添加。大纲节点通过“上移、下移、移入、移出”命令完成同等移动。

## 6. 状态、权限与设备协议

组件最终属性按以下优先级合并：

```text
组件默认值
< 页面 Schema 属性
< 设备覆盖（desktop/tablet/mobile）
< 业务状态覆盖（initial/create/edit/view/submit/approve）
< 角色权限裁剪
< 运行时安全裁剪
```

后层只能收紧安全权限，不能扩大服务端授权。桌面、平板和手机共享业务模型与规则，但允许独立保存布局、顺序、尺寸、可见性及交互呈现。`SplitPane`、`DashboardGrid`、`Spreadsheet` 等仅桌面能力必须声明移动端替代组件或阻止发布。

## 7. 组件成熟度门禁

每个组件使用四级成熟度，组件面板必须显示状态而不是混淆：

- `catalogued`：已进入目录和知识库，不能拖入。
- `designable`：可拖入、配置、序列化、反显及撤销。
- `previewable`：预览 Renderer、事件和状态覆盖可用。
- `production-ready`：完成权限、安全、性能、可访问性和服务端契约验证。

注册表中的 `ready / preview / planned` 仅表示物料是否允许在当前本地原型中拖入或是否明确禁用，不是上述成熟度证明。成熟度必须由逐组件设计、配置、预览、运行和专项审查证据计算，不能从目录状态直接推断。

首批发布门禁：所有 P0 组件至少达到 `previewable`；未达到 `designable` 的组件不能伪装成可用物料。P2 组件在缺少许可证或外部服务时必须显示依赖说明和可验证的降级状态。

## 8. 验收证据

组件扩展完成需同时提供：

1. 注册表数量、分类与搜索测试。
2. 每个 P0 容器至少一个合法和一个非法嵌套测试。
3. 组件新增、同级排序、跨容器移动、撤销和重做测试。
4. Schema 序列化后重新载入的结构等价测试。
5. 子单据体父实体依赖、父行切换和级联删除测试。
6. TreeGrid 展开、焦点、选择、编辑、加载和拖拽独立状态测试。
7. 桌面、平板、手机的截图与文本溢出检查。
8. 键盘添加和移动组件的可访问性测试。
9. 画布、大纲、面包屑和属性面板选择同步测试。
10. UTF-8、替换字符、连续问号和凭据泄露扫描。

## 9. 证据来源与边界

本协议吸收本地知识库中已确认的金蝶分录族、容器族、复杂控件和状态权限模型，以及 Mendix、OutSystems、Power Apps、Retool、Appian、DevExpress 的设计树、领域模型、调试与 TreeGrid 协议。商业软件只作为能力证据，V3 的 Schema、视觉、交互和代码均独立实现。

尚未实测的产品细节不作为兼容承诺。尤其是金蝶所有单据体属性、向导完整属性、部分移动端行为以及商业授权组件的版本差异，仍需按证据等级管理。
