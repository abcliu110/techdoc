# T-207 Web表单设计器详细设计

> 版本：v0.2
> 里程碑：M2
> 适用任务：T-207
> 依据：PRD REQ-020~023；`03-设计器与前端设计.md`
> 5A 状态：baseline-approved
> 更新日期：2026-07-07
> 更新说明：合并核心引擎实现、拖拽系统、渲染器设计、数据源服务等技术实现细节

---

## 1. 目标

提供企业级可视化表单设计器，支持拖拽式组件布局、现代Web布局规范、容器嵌套和响应式设计，输出符合前端标准的页面Schema。

## 2. 核心理念

表单设计器本质上是**所见即所得的页面布局工具**，必须：
- 遵循Web布局标准（Flexbox、Grid、Flow Layout）
- 保持设计器预览与运行时渲染完全一致
- 支持容器嵌套和组件化设计
- 输出标准化的页面Schema

## 3. 组件体系

### 3.1 组件分类

```text
容器组件（Container Components）
├─ 根容器（Page Container）
├─ Flex容器
├─ Grid容器
├─ 流式容器（Flow Container）
├─ 分组容器（Fieldset/Card）
├─ 标签页容器（Tabs）
└─ 重复容器（Array Field Container）

表单组件（Form Components）
├─ 输入类：Input、TextArea、Number、Password
├─ 选择类：Select、Radio、Checkbox、Switch
├─ 日期类：DatePicker、TimePicker、DateRange
├─ 文件类：Upload、ImageUpload
├─ 特殊类：Cascader、TreeSelect、Rate、Slider
└─ 展示类：Text、Divider、Alert
```

### 3.2 容器与组件的关系

- **容器**：结构性组件，负责布局和组织，可嵌套
- **表单组件**：功能性组件，负责数据交互，不可嵌套
- **容器可接收**：其他容器 + 表单组件
- **表单组件只能放入容器**

## 4. 布局系统设计

### 4.1 布局模式

```typescript
type LayoutType = 'flex' | 'grid' | 'flow' | 'inline';
```

### 4.2 Flex容器属性

```typescript
interface FlexContainerProps {
  layoutType: 'flex';
  
  // 主轴控制
  flexDirection: 'row' | 'column' | 'row-reverse' | 'column-reverse';
  justifyContent: 'flex-start' | 'center' | 'flex-end' | 
                  'space-between' | 'space-around' | 'space-evenly';
  flexWrap: 'nowrap' | 'wrap' | 'wrap-reverse';
  
  // 交叉轴控制
  alignItems: 'stretch' | 'flex-start' | 'center' | 'flex-end' | 'baseline';
  alignContent: 'flex-start' | 'center' | 'flex-end' | 
                'space-between' | 'space-around' | 'stretch';
  
  // 间距
  gap?: number;
  rowGap?: number;
  columnGap?: number;
}
```

### 4.3 Grid容器属性

```typescript
interface GridContainerProps {
  layoutType: 'grid';
  
  // 网格定义
  gridTemplateColumns: string; // '1fr 1fr' | 'repeat(3, 1fr)' | '200px auto'
  gridTemplateRows: string;
  gridAutoFlow: 'row' | 'column' | 'dense';
  
  // 对齐
  justifyItems: 'start' | 'center' | 'end' | 'stretch';
  alignItems: 'start' | 'center' | 'end' | 'stretch';
  justifyContent: 'start' | 'center' | 'end' | 'space-between' | 
                  'space-around' | 'space-evenly';
  alignContent: 'start' | 'center' | 'end' | 'space-between' | 
                'space-around' | 'space-evenly' | 'stretch';
  
  // 间距
  gap?: number;
  rowGap?: number;
  columnGap?: number;
}
```

### 4.4 流式布局属性

```typescript
interface FlowContainerProps {
  layoutType: 'flow';
  
  // 文本对齐（影响内联子元素）
  textAlign: 'left' | 'center' | 'right' | 'justify';
  
  // 垂直对齐（针对inline-block子元素）
  verticalAlign: 'top' | 'middle' | 'bottom' | 'baseline';
}
```

### 4.5 通用容器属性

```typescript
interface BaseContainerProps {
  // 基础信息
  id: string;
  type: 'container';
  name: string;
  
  // 尺寸
  width?: string | number; // 'auto' | '100%' | 固定值
  height?: string | number;
  minWidth?: string | number;
  maxWidth?: string | number;
  minHeight?: string | number;
  maxHeight?: string | number;
  
  // 内边距
  padding?: number | string;
  paddingTop?: number;
  paddingRight?: number;
  paddingBottom?: number;
  paddingLeft?: number;
  
  // 外边距
  margin?: number | string;
  marginTop?: number;
  marginRight?: number;
  marginBottom?: number;
  marginLeft?: number;
  
  // 样式
  backgroundColor?: string;
  border?: string;
  borderRadius?: number;
  boxShadow?: string;
  
  // 子组件
  children: ComponentSchema[];
  
  // 响应式
  breakpoints?: {
    mobile?: Partial<ContainerProps>;
    tablet?: Partial<ContainerProps>;
    desktop?: Partial<ContainerProps>;
  };
}
```

## 5. 组件Schema设计

### 5.1 根Schema结构

```typescript
interface FormDesignerSchema {
  schemaVersion: 'form-designer-v1';
  formId: string;
  formName: string;
  bindObject?: string; // 绑定的数据对象
  
  // 根容器
  root: ContainerSchema;
  
  // 元数据
  metadata: {
    createdBy: string;
    createdTime: string;
    updatedBy: string;
    updatedTime: string;
    description?: string;
  };
}
```

### 5.2 容器Schema示例

```json
{
  "id": "container-001",
  "type": "container",
  "name": "用户信息区",
  "layoutType": "flex",
  "flexDirection": "row",
  "justifyContent": "space-between",
  "alignItems": "center",
  "gap": 16,
  "padding": "20px",
  "children": [
    {
      "id": "field-001",
      "type": "input",
      "label": "用户名",
      "fieldName": "username",
      "required": true
    },
    {
      "id": "field-002",
      "type": "input",
      "label": "邮箱",
      "fieldName": "email",
      "required": true
    }
  ]
}
```

### 5.3 表单组件Schema

```typescript
interface FormFieldSchema {
  // 基础信息
  id: string;
  type: 'input' | 'select' | 'datepicker' | ...;
  label: string;
  fieldName: string; // 绑定的字段名
  
  // 校验
  required?: boolean;
  rules?: ValidationRule[];
  
  // 显示控制
  placeholder?: string;
  disabled?: boolean;
  readonly?: boolean;
  hidden?: boolean;
  
  // 组件特定属性
  componentProps?: Record<string, any>;
  
  // 联动配置
  dependencies?: {
    fieldName: string;
    condition: Expression;
    action: 'show' | 'hide' | 'enable' | 'disable' | 'setValue';
  }[];
}
```

## 6. 设计器UI架构

### 6.1 三栏布局

```text
+-------------------+------------------------+---------------------+
|   组件面板        |      画布区域          |    属性面板         |
|   (左侧)          |      (中央)            |    (右侧)           |
+-------------------+------------------------+---------------------+
| - 容器组件        | - 拖拽放置区           | - 选中组件属性      |
|   * Flex容器      | - 实时预览             | - 布局属性          |
|   * Grid容器      | - 嵌套结构可视化       | - 样式属性          |
|   * 流式容器      | - 选中状态高亮         | - 校验规则          |
|   * 分组容器      |                        | - 联动配置          |
|                   |                        | - 响应式配置        |
| - 表单组件        |                        |                     |
|   * 输入框        |                        |                     |
|   * 下拉框        |                        |                     |
|   * 日期选择      |                        |                     |
|   * ...           |                        |                     |
+-------------------+------------------------+---------------------+
```

### 6.2 核心交互

**拖拽操作**
- 从组件面板拖拽到画布容器
- 画布内组件拖拽排序
- 拖拽到容器边界时显示插入位置指示器
- 不允许将容器拖入表单组件

**选中与编辑**
- 点击画布组件进入选中状态
- 选中后右侧属性面板展示可配置属性
- 支持多选（Ctrl+点击）进行批量操作

**容器嵌套可视化**
- 容器显示虚线边框和布局模式标识
- 嵌套层级通过缩进和颜色区分
- 悬停时高亮当前容器边界

## 7. 属性配置面板设计

### 7.1 容器属性面板

```text
容器属性
├─ 基础
│  ├─ 名称: [文本输入]
│  └─ 说明: [文本输入]
├─ 布局
│  ├─ 布局模式: [Flex ▼] [Grid ▼] [流式 ▼]
│  ├─ 方向: [横向 ▼] [纵向 ▼]
│  ├─ 主轴对齐: [起始 ▼] [居中 ▼] [末尾 ▼] [两端 ▼] [均分 ▼]
│  ├─ 交叉轴对齐: [拉伸 ▼] [起始 ▼] [居中 ▼] [末尾 ▼]
│  ├─ 换行: [不换行 ▼] [换行 ▼]
│  └─ 间距: [16] px
├─ 尺寸
│  ├─ 宽度: [100] [% ▼]
│  ├─ 高度: [自动 ▼]
│  ├─ 最小宽度: [空]
│  └─ 最大宽度: [空]
├─ 内边距
│  ├─ 统一设置: [16] px
│  └─ 分别设置: [上:16] [右:16] [下:16] [左:16]
├─ 外边距
│  └─ [配置同内边距]
├─ 样式
│  ├─ 背景色: [色板选择]
│  ├─ 边框: [1px solid #d9d9d9]
│  ├─ 圆角: [4] px
│  └─ 阴影: [预设选择]
└─ 响应式
   ├─ [添加断点配置]
   ├─ 手机端 (< 768px): [已配置]
   ├─ 平板端 (768-1024px): [未配置]
   └─ 桌面端 (> 1024px): [未配置]
```

### 7.2 表单组件属性面板

```text
字段属性
├─ 基础
│  ├─ 标签: [文本输入]
│  ├─ 字段名: [fieldName]
│  ├─ 占位符: [文本输入]
│  └─ 默认值: [文本输入]
├─ 校验
│  ├─ 必填: [√]
│  ├─ 最小长度: [空]
│  ├─ 最大长度: [空]
│  ├─ 正则表达式: [空]
│  └─ 自定义校验: [添加规则]
├─ 显示控制
│  ├─ 只读: [ ]
│  ├─ 禁用: [ ]
│  └─ 隐藏: [ ]
├─ 组件配置
│  └─ [根据组件类型显示特定属性]
└─ 联动规则
   └─ [添加联动规则]
      ├─ 触发字段: [选择]
      ├─ 触发条件: [表达式编辑器]
      └─ 执行动作: [显示/隐藏/启用/禁用/设值]
```

## 8. 渲染映射

### 8.1 Schema到HTML/CSS的转换

**Flex容器示例**

Schema输入:
```json
{
  "layoutType": "flex",
  "flexDirection": "row",
  "justifyContent": "space-between",
  "alignItems": "center",
  "gap": 16,
  "padding": "20px"
}
```

HTML/CSS输出:
```html
<div style="
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  padding: 20px;
">
  <!-- 子组件 -->
</div>
```

**Grid容器示例**

Schema输入:
```json
{
  "layoutType": "grid",
  "gridTemplateColumns": "repeat(3, 1fr)",
  "gap": 20,
  "padding": "24px"
}
```

HTML/CSS输出:
```html
<div style="
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  padding: 24px;
">
  <!-- 子组件 -->
</div>
```

### 8.2 响应式渲染

```typescript
// 使用CSS媒体查询
const renderResponsive = (breakpoints) => `
  @media (max-width: 768px) {
    ${generateCSS(breakpoints.mobile)}
  }
  @media (min-width: 769px) and (max-width: 1024px) {
    ${generateCSS(breakpoints.tablet)}
  }
  @media (min-width: 1025px) {
    ${generateCSS(breakpoints.desktop)}
  }
`;
```

## 9. 技术实现

### 9.1 技术栈

```text
前端框架: React 18
UI组件库: Ant Design 5.x
拖拽库: @dnd-kit/core + @dnd-kit/sortable
状态管理: Zustand
表单管理: React Hook Form
Schema验证: Zod
```

### 9.2 核心模块

```text
src/
├─ designer/
│  ├─ ComponentPanel/        # 组件面板
│  ├─ Canvas/                # 画布区域
│  │  ├─ DragLayer.tsx      # 拖拽层
│  │  ├─ DropZone.tsx       # 放置区
│  │  └─ ComponentRenderer/ # 组件渲染器
│  ├─ PropertyPanel/         # 属性面板
│  │  ├─ ContainerProps.tsx
│  │  └─ FieldProps.tsx
│  └─ store/                 # 状态管理
│     ├─ schemaStore.ts
│     └─ selectionStore.ts
├─ runtime/
│  ├─ FormRenderer.tsx       # 运行时渲染器
│  └─ validators/            # 校验器
└─ shared/
   ├─ types/                 # 类型定义
   ├─ constants/             # 常量定义
   └─ utils/                 # 工具函数
```

### 9.3 Monorepo目录结构

采用PNPM Workspace管理多包结构：

```text
form-designer/
├── packages/
│   ├── designer/              # 设计器应用
│   │   ├── src/
│   │   │   ├── components/    # 设计器UI组件
│   │   │   │   ├── Toolbar/   # 工具栏
│   │   │   │   ├── ComponentPanel/  # 组件面板
│   │   │   │   ├── Canvas/    # 画布
│   │   │   │   └── PropertyPanel/   # 属性面板
│   │   │   ├── hooks/         # 自定义Hooks
│   │   │   ├── store/         # 状态管理
│   │   │   └── App.tsx        # 入口组件
│   │   └── package.json
│   │
│   ├── renderer/              # 渲染器（独立包）
│   │   ├── src/
│   │   │   ├── FormRenderer.tsx
│   │   │   └── index.ts
│   │   └── package.json
│   │
│   ├── engine/                # 核心引擎
│   │   ├── src/
│   │   │   ├── registry/      # 组件注册中心
│   │   │   ├── schema/        # Schema管理
│   │   │   ├── expression/    # 表达式引擎
│   │   │   ├── validator/     # 校验引擎
│   │   │   ├── event/         # 事件总线
│   │   │   └── history/       # 历史管理
│   │   └── package.json
│   │
│   ├── components/            # 表单组件库
│   │   ├── src/
│   │   │   ├── basic/         # 基础组件
│   │   │   ├── layout/        # 布局组件
│   │   │   ├── advanced/      # 高级组件
│   │   │   └── index.ts
│   │   └── package.json
│   │
│   ├── shared/                # 共享工具
│   │   ├── src/
│   │   │   ├── types/         # TypeScript类型
│   │   │   ├── utils/         # 工具函数
│   │   │   └── constants/     # 常量
│   │   └── package.json
│   │
│   └── services/              # 服务层
│       ├── src/
│       │   ├── api/           # API服务
│       │   ├── datasource/    # 数据源服务
│       │   └── storage/       # 存储服务
│       └── package.json
│
├── pnpm-workspace.yaml
└── package.json
```

### 9.4 状态管理详细设计

使用**Zustand + Immer**实现状态管理：

```typescript
// packages/designer/src/store/designerStore.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';
import { SchemaManager } from '@form-designer/engine';

interface DesignerState {
  // Schema
  schema: FormDesignerSchema;
  schemaManager: SchemaManager;
  
  // 选中状态
  selectedComponentId: string | null;
  hoveredComponentId: string | null;
  
  // UI状态
  leftPanelCollapsed: boolean;
  rightPanelCollapsed: boolean;
  previewMode: boolean;
  
  // 操作方法
  setSchema: (schema: FormDesignerSchema) => void;
  addComponent: (parentId: string, component: ComponentSchema, index?: number) => void;
  updateComponent: (id: string, updates: Partial<ComponentSchema>) => void;
  removeComponent: (id: string) => void;
  moveComponent: (id: string, targetParentId: string, index: number) => void;
  
  // 选择操作
  selectComponent: (id: string | null) => void;
  hoverComponent: (id: string | null) => void;
  clearSelection: () => void;
  
  // UI控制
  toggleLeftPanel: () => void;
  toggleRightPanel: () => void;
  setPreviewMode: (enabled: boolean) => void;
  
  // 撤销/重做
  undo: () => void;
  redo: () => void;
  canUndo: () => boolean;
  canRedo: () => boolean;
  
  // 导入/导出
  importSchema: (schema: FormDesignerSchema) => void;
  exportSchema: () => FormDesignerSchema;
}

export const useDesignerStore = create<DesignerState>()(
  immer((set, get) => {
    const schemaManager = new SchemaManager();
    
    return {
      schema: schemaManager.getSchema(),
      schemaManager,
      selectedComponentId: null,
      hoveredComponentId: null,
      leftPanelCollapsed: false,
      rightPanelCollapsed: false,
      previewMode: false,
      
      setSchema: (schema) => set((state) => {
        state.schema = schema;
        state.schemaManager.setSchema(schema);
      }),
      
      addComponent: (parentId, component, index) => set((state) => {
        state.schemaManager.addField(component, { parentId, index });
        state.schema = state.schemaManager.getSchema();
      }),
      
      updateComponent: (id, updates) => set((state) => {
        state.schemaManager.updateField(id, updates);
        state.schema = state.schemaManager.getSchema();
      }),
      
      removeComponent: (id) => set((state) => {
        state.schemaManager.deleteField(id);
        state.schema = state.schemaManager.getSchema();
        if (state.selectedComponentId === id) {
          state.selectedComponentId = null;
        }
      }),
      
      moveComponent: (id, targetParentId, index) => set((state) => {
        state.schemaManager.moveField(id, { parentId: targetParentId, index });
        state.schema = state.schemaManager.getSchema();
      }),
      
      selectComponent: (id) => set((state) => {
        state.selectedComponentId = id;
      }),
      
      hoverComponent: (id) => set((state) => {
        state.hoveredComponentId = id;
      }),
      
      clearSelection: () => set((state) => {
        state.selectedComponentId = null;
      }),
      
      toggleLeftPanel: () => set((state) => {
        state.leftPanelCollapsed = !state.leftPanelCollapsed;
      }),
      
      toggleRightPanel: () => set((state) => {
        state.rightPanelCollapsed = !state.rightPanelCollapsed;
      }),
      
      setPreviewMode: (enabled) => set((state) => {
        state.previewMode = enabled;
      }),
      
      undo: () => set((state) => {
        const schema = state.schemaManager.undo();
        if (schema) {
          state.schema = schema;
        }
      }),
      
      redo: () => set((state) => {
        const schema = state.schemaManager.redo();
        if (schema) {
          state.schema = schema;
        }
      }),
      
      canUndo: () => get().schemaManager.canUndo(),
      canRedo: () => get().schemaManager.canRedo(),
      
      importSchema: (schema) => set((state) => {
        state.schemaManager.setSchema(schema);
        state.schema = schema;
      }),
      
      exportSchema: () => get().schema,
    };
  })
);
```

## 10. 核心引擎实现

本节详细描述表单设计器核心引擎的实现细节，包括组件注册、Schema管理、表达式计算、校验、事件和历史记录等关键模块。

### 10.1 组件注册中心

组件注册中心负责管理所有可用组件的元数据，提供组件查询、分类、搜索等能力。

```typescript
// packages/engine/src/registry/ComponentRegistry.ts

export interface ComponentMeta {
  type: string;                    // 组件类型：input, select等
  name: string;                    // 组件名称
  category: ComponentCategory;     // 分类
  icon: React.ReactNode;           // 图标
  order: number;                   // 排序
  defaultSchema: FieldSchema;      // 默认Schema
  propsSchema: PropConfig[];       // 属性配置Schema
  events: string[];                // 支持的事件
  component: React.ComponentType<any>;  // 渲染组件
}

export enum ComponentCategory {
  BASIC = 'basic',        // 基础组件
  LAYOUT = 'layout',      // 布局容器
  ADVANCED = 'advanced',  // 高级组件
  DATA = 'data',          // 数据展示
  BUSINESS = 'business',  // 业务组件
  DISPLAY = 'display',    // 辅助组件
}

export class ComponentRegistry {
  private components: Map<string, ComponentMeta> = new Map();
  
  // 注册组件
  register(meta: ComponentMeta): void {
    if (this.components.has(meta.type)) {
      console.warn(`组件 ${meta.type} 已存在，将被覆盖`);
    }
    this.components.set(meta.type, meta);
  }
  
  // 批量注册
  registerAll(metas: ComponentMeta[]): void {
    metas.forEach(meta => this.register(meta));
  }
  
  // 获取组件
  getComponent(type: string): ComponentMeta | undefined {
    return this.components.get(type);
  }
  
  // 按分类获取组件
  getByCategory(category: ComponentCategory): ComponentMeta[] {
    return Array.from(this.components.values())
      .filter(c => c.category === category)
      .sort((a, b) => a.order - b.order);
  }
  
  // 获取所有组件
  getAll(): ComponentMeta[] {
    return Array.from(this.components.values());
  }
  
  // 搜索组件
  search(keyword: string): ComponentMeta[] {
    const lowerKeyword = keyword.toLowerCase();
    return Array.from(this.components.values())
      .filter(c => 
        c.name.toLowerCase().includes(lowerKeyword) ||
        c.type.toLowerCase().includes(lowerKeyword)
      );
  }
}

// 单例导出
export const componentRegistry = new ComponentRegistry();
```

**组件注册示例**：

```typescript
// packages/components/src/basic/Input/register.ts
import { ComponentMeta, ComponentCategory } from '@form-designer/engine';

export const InputMeta: ComponentMeta = {
  type: 'input',
  name: '单行输入',
  category: ComponentCategory.BASIC,
  icon: <InputIcon />,
  order: 1,
  
  defaultSchema: {
    id: '',
    type: 'input',
    key: '',
    label: '输入框',
    props: {
      placeholder: '请输入',
      allowClear: true,
    },
  },
  
  propsSchema: [
    { key: 'label', label: '标题', type: 'input', category: 'basic', required: true },
    { key: 'key', label: '字段标识', type: 'input', category: 'basic', required: true },
    { key: 'placeholder', label: '占位符', type: 'input', category: 'basic' },
    { key: 'maxLength', label: '最大长度', type: 'number', category: 'advanced' },
    { key: 'allowClear', label: '允许清除', type: 'switch', category: 'advanced' },
  ],
  
  events: ['onChange', 'onBlur', 'onFocus'],
  component: InputComponent,
};
```

### 10.2 Schema管理器

Schema管理器负责管理表单Schema的CRUD操作，并提供变更通知机制。

```typescript
// packages/engine/src/schema/SchemaManager.ts

export class SchemaManager {
  private schema: FormSchema;
  private listeners: Set<SchemaChangeListener> = new Set();
  private historyManager: HistoryManager;
  
  constructor(initialSchema?: FormSchema) {
    this.schema = initialSchema || this.createEmptySchema();
    this.historyManager = new HistoryManager();
    this.historyManager.push(this.schema);
  }
  
  // 获取Schema
  getSchema(): FormSchema {
    return JSON.parse(JSON.stringify(this.schema));
  }
  
  // 设置Schema
  setSchema(schema: FormSchema): void {
    this.schema = schema;
    this.historyManager.push(schema);
    this.notify('set', schema);
  }
  
  // 添加字段
  addField(field: FieldSchema, position?: InsertPosition): void {
    if (position?.parentId) {
      const parent = this.findField(position.parentId);
      if (parent) {
        parent.children = parent.children || [];
        parent.children.splice(position.index || parent.children.length, 0, field);
      }
    } else {
      this.schema.fields.splice(position?.index || this.schema.fields.length, 0, field);
    }
    this.historyManager.push(this.schema);
    this.notify('add', field);
  }
  
  // 更新字段
  updateField(fieldId: string, updates: Partial<FieldSchema>): void {
    const field = this.findField(fieldId);
    if (field) {
      Object.assign(field, updates);
      this.historyManager.push(this.schema);
      this.notify('update', field);
    }
  }
  
  // 删除字段
  deleteField(fieldId: string): void {
    const result = this.removeField(this.schema.fields, fieldId);
    if (result) {
      this.historyManager.push(this.schema);
      this.notify('delete', { fieldId });
    }
  }
  
  // 移动字段
  moveField(fieldId: string, newPosition: InsertPosition): void {
    const field = this.findField(fieldId);
    if (!field) return;
    
    this.removeField(this.schema.fields, fieldId);
    this.addField(field, newPosition);
  }
  
  // 查找字段（递归）
  findField(fieldId: string): FieldSchema | null {
    return this.findFieldRecursive(this.schema.fields, fieldId);
  }
  
  private findFieldRecursive(fields: FieldSchema[], fieldId: string): FieldSchema | null {
    for (const field of fields) {
      if (field.id === fieldId) return field;
      if (field.children) {
        const found = this.findFieldRecursive(field.children, fieldId);
        if (found) return found;
      }
    }
    return null;
  }
  
  // 撤销
  undo(): FormSchema | null {
    const schema = this.historyManager.undo();
    if (schema) {
      this.schema = schema;
      this.notify('undo', schema);
      return schema;
    }
    return null;
  }
  
  // 重做
  redo(): FormSchema | null {
    const schema = this.historyManager.redo();
    if (schema) {
      this.schema = schema;
      this.notify('redo', schema);
      return schema;
    }
    return null;
  }
  
  canUndo(): boolean {
    return this.historyManager.canUndo();
  }
  
  canRedo(): boolean {
    return this.historyManager.canRedo();
  }
  
  // 订阅变化
  subscribe(listener: SchemaChangeListener): () => void {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  }
  
  private notify(type: string, payload: any): void {
    this.listeners.forEach(listener => listener(type, payload));
  }
  
  private createEmptySchema(): FormSchema {
    return {
      formId: generateId(),
      formName: '未命名表单',
      version: '1.0.0',
      config: { layout: 'horizontal', labelWidth: 120, size: 'default' },
      fields: [],
    };
  }
  
  private removeField(fields: FieldSchema[], fieldId: string): boolean {
    const index = fields.findIndex(f => f.id === fieldId);
    if (index >= 0) {
      fields.splice(index, 1);
      return true;
    }
    for (const field of fields) {
      if (field.children && this.removeField(field.children, fieldId)) {
        return true;
      }
    }
    return false;
  }
}
```

### 10.3 表达式引擎

表达式引擎支持字段联动、动态显示/隐藏、计算字段等功能。

```typescript
// packages/engine/src/expression/ExpressionEngine.ts

export class ExpressionEngine {
  private context: ExpressionContext;
  private functions: Map<string, Function> = new Map();
  
  constructor() {
    this.context = { formData: {}, userInfo: {}, permissions: [] };
    this.registerBuiltInFunctions();
  }
  
  // 执行表达式
  execute(expression: string | boolean, formData?: any): any {
    if (typeof expression === 'boolean') return expression;
    if (!expression || typeof expression !== 'string') return expression;
    
    // 解析表达式 ${...}
    if (!expression.startsWith('${') || !expression.endsWith('}')) {
      return expression;
    }
    
    const code = expression.slice(2, -1).trim();
    
    try {
      const ctx = {
        ...this.context,
        formData: formData || this.context.formData,
        ...this.getFunctionsObject(),
      };
      
      const fn = new Function(...Object.keys(ctx), `return ${code}`);
      return fn(...Object.values(ctx));
    } catch (error) {
      console.error('表达式执行错误:', error, expression);
      return undefined;
    }
  }
  
  // 注册内置函数
  private registerBuiltInFunctions(): void {
    // 数学函数
    this.functions.set('SUM', (...args: number[]) => args.reduce((a, b) => a + b, 0));
    this.functions.set('AVG', (arr: number[]) => arr.reduce((a, b) => a + b, 0) / arr.length);
    this.functions.set('MAX', (...args: number[]) => Math.max(...args));
    this.functions.set('MIN', (...args: number[]) => Math.min(...args));
    
    // 字符串函数
    this.functions.set('CONCAT', (...args: any[]) => args.join(''));
    this.functions.set('UPPER', (str: string) => str.toUpperCase());
    this.functions.set('LOWER', (str: string) => str.toLowerCase());
    
    // 逻辑函数
    this.functions.set('IF', (condition: boolean, trueValue: any, falseValue: any) => 
      condition ? trueValue : falseValue
    );
    this.functions.set('AND', (...args: boolean[]) => args.every(v => v));
    this.functions.set('OR', (...args: boolean[]) => args.some(v => v));
  }
  
  private getFunctionsObject(): Record<string, Function> {
    const obj: Record<string, Function> = {};
    this.functions.forEach((fn, name) => { obj[name] = fn; });
    return obj;
  }
}
```

### 10.4 校验引擎

详见第11节"校验规则"。

### 10.5 事件总线

事件总线用于组件间通信和状态变化通知。

```typescript
// packages/engine/src/event/EventBus.ts

export class EventBus {
  private listeners: Map<string, Set<EventListener>> = new Map();
  
  on(event: string, listener: EventListener): () => void {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, new Set());
    }
    this.listeners.get(event)!.add(listener);
    return () => this.off(event, listener);
  }
  
  off(event: string, listener: EventListener): void {
    this.listeners.get(event)?.delete(listener);
  }
  
  emit(event: string, payload?: any): void {
    this.listeners.get(event)?.forEach(listener => {
      try {
        listener(payload);
      } catch (error) {
        console.error(`事件 ${event} 监听器执行错误:`, error);
      }
    });
  }
  
  once(event: string, listener: EventListener): void {
    const wrappedListener: EventListener = (payload) => {
      listener(payload);
      this.off(event, wrappedListener);
    };
    this.on(event, wrappedListener);
  }
}

// 预定义事件类型
export enum DesignerEvents {
  SCHEMA_CHANGE = 'schema:change',
  FIELD_ADD = 'field:add',
  FIELD_UPDATE = 'field:update',
  FIELD_DELETE = 'field:delete',
  FIELD_SELECT = 'field:select',
  DRAG_START = 'drag:start',
  DRAG_END = 'drag:end',
}
```

### 10.6 历史管理器

历史管理器实现撤销/重做功能。

```typescript
// packages/engine/src/history/HistoryManager.ts

export class HistoryManager {
  private history: HistorySnapshot[] = [];
  private currentIndex: number = -1;
  private maxHistory: number = 50;
  
  push(schema: FormSchema): void {
    if (this.currentIndex < this.history.length - 1) {
      this.history = this.history.slice(0, this.currentIndex + 1);
    }
    
    this.history.push({
      schema: JSON.parse(JSON.stringify(schema)),
      timestamp: Date.now(),
    });
    
    if (this.history.length > this.maxHistory) {
      this.history.shift();
    } else {
      this.currentIndex++;
    }
  }
  
  undo(): FormSchema | null {
    if (!this.canUndo()) return null;
    this.currentIndex--;
    return this.getCurrentSchema();
  }
  
  redo(): FormSchema | null {
    if (!this.canRedo()) return null;
    this.currentIndex++;
    return this.getCurrentSchema();
  }
  
  canUndo(): boolean {
    return this.currentIndex > 0;
  }
  
  canRedo(): boolean {
    return this.currentIndex < this.history.length - 1;
  }
  
  getCurrentSchema(): FormSchema | null {
    if (this.currentIndex >= 0 && this.currentIndex < this.history.length) {
      return JSON.parse(JSON.stringify(this.history[this.currentIndex].schema));
    }
    return null;
  }
}
```

## 11. 拖拽系统详细设计

### 11.1 拖拽库选择

使用 **@dnd-kit** 而不是 react-dnd：
- 更好的性能（使用现代API）
- 更好的可访问性支持
- 更灵活的配置
- 更小的包体积

### 11.2 拖拽实现

```typescript
// packages/designer/src/hooks/useDragDrop.ts

import { DndContext, DragEndEvent, useSensor, useSensors, PointerSensor } from '@dnd-kit/core';

export function useDragDrop() {
  const schemaManager = useSchemaManager();
  const componentRegistry = useComponentRegistry();
  
  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: { distance: 8 },
    })
  );
  
  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;
    if (!over) return;
    
    if (active.data.current?.type === 'component') {
      // 从组件面板拖拽到画布：新增字段
      const componentType = active.data.current.componentType;
      const position = calculatePosition(over);
      addFieldToCanvas(componentType, position);
    } else if (active.data.current?.type === 'field') {
      // 在画布中拖拽：移动字段
      const fieldId = active.id as string;
      const newPosition = calculatePosition(over);
      moveFieldInCanvas(fieldId, newPosition);
    }
  };
  
  const addFieldToCanvas = (componentType: string, position: InsertPosition) => {
    const componentMeta = componentRegistry.getComponent(componentType);
    if (!componentMeta) return;
    
    const newField: FieldSchema = {
      ...componentMeta.defaultSchema,
      id: generateId(),
      key: generateFieldKey(componentType),
    };
    
    schemaManager.addField(newField, position);
  };
  
  return { sensors, handleDragEnd };
}
```

## 12. 渲染器设计

### 12.1 运行时渲染器

渲染器独立于设计器，可单独部署或嵌入到其他应用。

```typescript
// packages/renderer/src/FormRenderer.tsx

export interface FormRendererProps {
  schema: FormDesignerSchema;
  initialData?: Record<string, any>;
  onSubmit?: (data: Record<string, any>) => void;
  onChange?: (data: Record<string, any>) => void;
  mode?: 'edit' | 'view';
}

export const FormRenderer: React.FC<FormRendererProps> = ({
  schema,
  initialData = {},
  onSubmit,
  onChange,
  mode = 'edit',
}) => {
  const [formData, setFormData] = useState(initialData);
  const expressionEngine = useMemo(() => new ExpressionEngine(), []);
  const validatorEngine = useMemo(() => new ValidatorEngine(), []);
  
  const handleFieldChange = (fieldKey: string, value: any) => {
    const newData = { ...formData, [fieldKey]: value };
    setFormData(newData);
    onChange?.(newData);
  };
  
  const renderContainer = (container: ContainerSchema) => {
    const style = buildContainerStyle(container);
    
    return (
      <div style={style} className={getContainerClass(container)}>
        {container.children?.map(child => renderComponent(child))}
      </div>
    );
  };
  
  const renderField = (field: FieldSchema) => {
    const ComponentMeta = componentRegistry.getComponent(field.type);
    if (!ComponentMeta) return null;
    
    // 计算显示条件
    const visible = expressionEngine.execute(field.display?.visible, formData);
    if (visible === false) return null;
    
    // 计算禁用条件
    const disabled = mode === 'view' || 
      expressionEngine.execute(field.display?.disabled, formData);
    
    return (
      <ComponentMeta.component
        key={field.id}
        {...field.props}
        value={formData[field.key]}
        onChange={(value) => handleFieldChange(field.key, value)}
        disabled={disabled}
      />
    );
  };
  
  return (
    <Form onFinish={() => onSubmit?.(formData)}>
      {renderContainer(schema.root)}
    </Form>
  );
};
```

### 12.2 设计器与渲染器分离

**设计时**：
- 完整的编辑功能
- 拖拽、属性配置、实时预览
- 依赖所有engine包

**运行时**：
- 仅渲染和数据交互
- 不依赖设计器UI组件
- 体积更小，性能更好

### 12.3 部署方案

**独立部署**：
```bash
npm install @form-designer/renderer
```

**嵌入集成**：
```typescript
import { FormRenderer } from '@form-designer/renderer';

<FormRenderer 
  schema={loadedSchema} 
  onSubmit={handleSubmit} 
/>
```

## 13. 数据源服务

### 13.1 数据源类型

```typescript
interface DataSource {
  id: string;
  name: string;
  type: 'static' | 'api' | 'sql' | 'function';
  
  // 静态数据
  data?: any[];
  
  // API数据源
  url?: string;
  method?: 'GET' | 'POST';
  headers?: Record<string, string>;
  mapping?: DataMapping;
  
  // SQL数据源
  sql?: string;
  
  // 函数数据源
  handler?: (params: any) => Promise<any[]>;
}
```

### 13.2 数据源服务实现

```typescript
// packages/services/src/datasource/DataSourceService.ts

export class DataSourceService {
  private dataSources: Map<string, DataSource> = new Map();
  
  registerDataSource(ds: DataSource) {
    this.dataSources.set(ds.id, ds);
  }
  
  async query(dataSourceId: string, params?: any): Promise<any[]> {
    const ds = this.dataSources.get(dataSourceId);
    if (!ds) throw new Error(`数据源 ${dataSourceId} 不存在`);
    
    switch (ds.type) {
      case 'static':
        return ds.data || [];
      case 'api':
        return await this.queryApi(ds, params);
      case 'function':
        return await ds.handler?.(params) || [];
      default:
        return [];
    }
  }
  
  private async queryApi(ds: DataSource, params: any): Promise<any[]> {
    const response = await fetch(ds.url!, {
      method: ds.method || 'GET',
      headers: ds.headers,
      body: ds.method === 'POST' ? JSON.stringify(params) : undefined,
    });
    
    const data = await response.json();
    return this.mapData(data, ds.mapping);
  }
  
  private mapData(data: any, mapping?: DataMapping): any[] {
    if (!mapping) return data;
    
    let items = mapping.dataPath ? getNestedValue(data, mapping.dataPath) : data;
    
    return items.map(item => ({
      label: getNestedValue(item, mapping.labelField || 'label'),
      value: getNestedValue(item, mapping.valueField || 'value'),
    }));
  }
}
```

## 14. 校验规则

### 10.1 设计时校验

保存草稿时返回warning，发布时必须阻断:

```text
结构校验
├─ 根容器必须存在
├─ 组件ID不能重复
├─ 字段名不能重复
├─ 容器不能为空（至少包含一个子组件）
└─ 嵌套深度不超过10层

引用校验
├─ 联动规则引用的字段必须存在
├─ 绑定的数据对象必须存在
└─ 字段类型与组件类型必须匹配

布局校验
├─ Grid容器的gridTemplateColumns必须有效
├─ 尺寸值必须符合CSS规范
└─ 响应式断点不能重叠

业务校验
├─ 必填字段不能设为隐藏
├─ 只读字段不能同时设为禁用
└─ 表单必须至少有一个可编辑字段
```

### 10.2 运行时校验

```typescript
// 字段校验规则
interface ValidationRule {
  type: 'required' | 'minLength' | 'maxLength' | 'pattern' | 'custom';
  message: string;
  params?: any;
}

// 自定义校验示例
{
  type: 'custom',
  message: '两次密码输入不一致',
  validator: (value, formData) => {
    return value === formData.password;
  }
}
```

## 15. 典型场景示例

### 11.1 简单表单（流式布局）

```json
{
  "root": {
    "layoutType": "flow",
    "children": [
      {"type": "input", "label": "姓名", "fieldName": "name"},
      {"type": "input", "label": "邮箱", "fieldName": "email"},
      {"type": "select", "label": "性别", "fieldName": "gender"}
    ]
  }
}
```

### 11.2 两列表单（Grid布局）

```json
{
  "root": {
    "layoutType": "grid",
    "gridTemplateColumns": "1fr 1fr",
    "gap": 16,
    "children": [
      {"type": "input", "label": "姓", "fieldName": "firstName"},
      {"type": "input", "label": "名", "fieldName": "lastName"},
      {"type": "input", "label": "手机", "fieldName": "phone"},
      {"type": "input", "label": "邮箱", "fieldName": "email"}
    ]
  }
}
```

### 11.3 分组表单（嵌套容器）

```json
{
  "root": {
    "layoutType": "flow",
    "children": [
      {
        "type": "container",
        "name": "基本信息",
        "layoutType": "grid",
        "gridTemplateColumns": "1fr 1fr",
        "children": [
          {"type": "input", "label": "姓名", "fieldName": "name"},
          {"type": "input", "label": "邮箱", "fieldName": "email"}
        ]
      },
      {
        "type": "container",
        "name": "地址信息",
        "layoutType": "flow",
        "children": [
          {"type": "input", "label": "省份", "fieldName": "province"},
          {"type": "input", "label": "城市", "fieldName": "city"},
          {"type": "textarea", "label": "详细地址", "fieldName": "address"}
        ]
      }
    ]
  }
}
```

### 11.4 响应式表单

```json
{
  "root": {
    "layoutType": "grid",
    "gridTemplateColumns": "repeat(3, 1fr)",
    "gap": 16,
    "breakpoints": {
      "mobile": {
        "gridTemplateColumns": "1fr"
      },
      "tablet": {
        "gridTemplateColumns": "1fr 1fr"
      },
      "desktop": {
        "gridTemplateColumns": "repeat(3, 1fr)"
      }
    },
    "children": [...]
  }
}
```

## 16. 性能优化

### 12.1 渲染优化

```text
- 使用React.memo避免不必要的重渲染
- 虚拟滚动处理大量组件
- 防抖延迟属性更新
- 懒加载组件面板的组件列表
```

### 12.2 Schema优化

```text
- Schema增量更新，不全量替换
- 使用Immer简化不可变更新
- 压缩存储JSON Schema
```

## 17. 验收标准

### 13.1 功能验收

1. 支持拖拽添加容器和表单组件
2. 支持Flex、Grid、Flow三种布局模式
3. 容器可嵌套，最大深度10层
4. 属性面板实时同步选中组件属性
5. 支持撤销/重做（最多50步）
6. 导出的Schema可被运行时正确渲染
7. 设计器预览与运行时效果一致
8. 响应式配置在不同断点正确生效

### 13.2 体验验收

1. 拖拽操作流畅，插入位置明确可见
2. 选中状态清晰，支持键盘导航
3. 属性配置项分组合理，常用项优先
4. 错误提示准确定位到具体组件
5. 大型表单（100+组件）操作无明显卡顿

### 13.3 兼容性验收

1. 支持Chrome、Edge、Firefox、Safari最新版
2. 设计器分辨率最小支持1366x768
3. 运行时支持移动端浏览器
4. Schema版本向后兼容

## 18. 5A门禁补齐

### 14.1 需求引用

| requirementId | storyId | 承接说明 |
|---|---|---|
| REQ-020 | US-UI-001 | 可视化表单设计器核心功能 |
| REQ-021 | US-UI-001 | 容器布局系统和响应式支持 |
| REQ-022 | US-UI-001 | 组件属性配置和校验规则 |
| REQ-023 | US-UI-001 | Schema导入导出和版本管理 |

### 14.2 ADR与决策矩阵引用

| 来源 | 承接行 |
|---|---|
| `../04-架构决策/UI-and-Component-Decision-Matrix.md` | 设计器架构、组件体系、Schema协议 |
| `../04-架构决策/Form-Layout-Decision-Matrix.md` | 布局系统、容器属性、响应式策略 |

### 14.3 UI设计系统对照

设计器采用Ant Design组件构建，包括：
- Layout: 三栏布局
- Tree: 组件树导航
- Form: 属性配置表单
- Tabs: 分组切换
- Drawer: 高级配置抽屉
- DndKit: 拖拽交互

### 14.4 可访问性规则

| 规则 | 验收方式 |
|---|---|
| 键盘导航 | Tab键可遍历所有交互元素，Enter/Space可激活 |
| 拖拽替代 | 提供上移/下移/删除按钮作为拖拽替代操作 |
| 屏幕阅读器 | 组件标签、属性名称可被正确朗读 |
| 焦点可见 | 焦点状态有明显视觉反馈 |
| 颜色对比 | 文本与背景对比度≥4.5:1 |

### 14.5 状态组合

| 权限状态 | 数据状态 | 交互状态 | 设计器行为 |
|---|---|---|---|
| design none | any | any | 不允许进入设计器 |
| design read | published | idle | 只读预览模式，不可编辑 |
| design write | draft | editing | 可编辑，自动保存草稿 |
| design write | dirty | submitting | 校验并发布，阻断式错误提示 |
| design write | error | conflict | 显示冲突内容，要求手动合并 |

### 14.6 失败模式

| 失败模式 | 处置 |
|---|---|
| 组件ID重复 | 发布前阻断，高亮重复组件 |
| 字段名重复 | 发布前阻断，提示修改字段名 |
| 引用不存在字段 | 发布前阻断，定位到联动规则 |
| 容器嵌套超过10层 | 禁止继续嵌套，提示层级限制 |
| Schema版本不兼容 | 阻断发布，提供升级工具 |
| 必填字段设为隐藏 | 发布前阻断，提示逻辑冲突 |
| Grid列定义无效 | 实时提示，回退到默认值 |

### 14.7 5.0自检

| 检查项 | 结果 |
|---|---|
| 完整性 | 已补需求引用、ADR/矩阵引用、设计系统、可访问性、状态组合、失败模式 |
| 一致性 | 与现有Schema协议和组件体系一致 |
| 可测试性 | 已映射到拖拽、校验、渲染、响应式、键盘导航测试 |
| 可追溯性 | 需由CapabilityTraceMatrix登记T-207与矩阵关系 |

## 19. 后续扩展

### 15.1 M3计划

```text
- 自定义组件注册机制
- 表单模板市场
- 多人协作编辑
- 版本历史和回滚
- AI辅助布局建议
```

### 15.2 高级特性

```text
- 条件显示表达式编辑器
- 动态数据源绑定
- 表单联动可视化配置
- 主题定制系统
- 国际化支持
```

---

**文档状态**: baseline-approved
**最后更新**: 2026-07-07
**审批人**: [待填写]
