/**
 * 共享类型定义
 * 所有包的契约来源
 */

// ================================ 布局控件类型 ================================

/** 布局控件类型枚举 */
export type LayoutControlType =
  | 'gridContainer'   // P0 网格布局
  | 'flexContainer'   // P0 弹性布局
  | 'dockContainer'   // P0 停靠布局
  | 'splitContainer'  // P0 分割布局
  | 'scrollContainer' // P0 滚动布局
  | 'stickyContainer' // P0 固定布局
  | 'tabsContainer'   // P0 页签布局
  | 'portalContainer' // P0 浮层布局
  | 'responsiveContainer' // P0 响应式布局
  | 'masterDetailContainer' // P0 主从布局
  | 'formGridContainer'     // P0 表单网格
  | 'stackContainer'        // P1 堆叠布局
  | 'accordionContainer'    // P1 折叠布局
  | 'cardGridContainer'     // P1 卡片网格
  | 'drawerContainer'       // P1 抽屉布局
  | 'dialogContainer';      // P1 弹窗布局

/** 布局控件优先级 */
export type ControlPriority = 'P0' | 'P1' | 'P2';

/** 插槽定义 */
export interface SlotDef {
  /** 插槽名称 */
  name: string;
  /** 插槽显示名 */
  label: string;
  /** 是否必须 */
  required?: boolean;
  /** 可接受的子控件类型 */
  accepts?: LayoutControlType[];
}

/** 布局控件元数据 */
export interface LayoutControlMeta {
  type: LayoutControlType;
  label: string;
  icon: string;
  description: string;
  priority: ControlPriority;
  slots: SlotDef[];
  /** 渲染时的默认样式 */
  defaultStyle?: Record<string, string>;
}

/** 布局控件属性定义 */
export interface PropertyDef {
  name: string;
  label: string;
  type: 'string' | 'number' | 'boolean' | 'select' | 'css';
  defaultValue?: unknown;
  options?: Array<{ label: string; value: unknown }>;
  category?: string;
}

// ================================ 设计器节点 ================================

/** 设计器节点（布局控件实例） */
export interface LayoutNode {
  /** 唯一节点 ID */
  id: string;
  /** 节点类型 */
  type: LayoutControlType;
  /** 显示名称 */
  label: string;
  /** 节点编码（用于属性面板标识） */
  nodeId: string;
  /** CSS 样式属性 */
  style?: Record<string, string>;
  /** 布局特有属性 */
  props?: Record<string, unknown>;
  /** 子插槽内容 */
  slots?: Record<string, LayoutNode[]>;
  /** 是否可见 */
  visible?: boolean;
  /** 业务对象绑定 */
  boBinding?: string;
  /** 权限 */
  permission?: {
    view?: string[];
    edit?: string[];
  };
  /** 扩展数据 */
  [key: string]: unknown;
}

// ================================ 表单元素 ================================

export type ElementCategory = 'basic' | 'advanced' | 'display';

export type ElementType =
  // 基础输入
  | 'input' | 'inputNumber' | 'textarea' | 'datePicker' | 'timePicker'
  | 'rangePicker'
  // 选择引用
  | 'select' | 'checkbox' | 'radio' | 'switch' | 'autoComplete'
  | 'cascader' | 'tree' | 'transfer' | 'slider' | 'rate'
  // 上传展示
  | 'upload' | 'colorPicker' | 'richText'
  // 业务语义
  | 'subTable'
  // 展示
  | 'tag' | 'divider' | 'calendar';

// ================================ 字段数据（业务字段） ================================

export interface FieldOption {
  label: string;
  value: string | number;
  disabled?: boolean;
}

export interface TreeNode {
  label: string;
  value: string | number;
  children?: TreeNode[];
  disabled?: boolean;
}

export interface ColumnDef {
  title: string;
  dataIndex: string;
  width?: number | string;
  frozen?: 'left' | 'right';
  editable?: boolean;
}

/** 业务字段节点（用于画布中的叶子节点） */
export interface DesignerFieldData {
  /** 唯一节点 ID */
  id: string;
  /** 节点类型 */
  type: ElementType;
  /** 字段标签 */
  label: string;
  /** 字段编码 */
  fieldId: string;
  /** 业务对象绑定 */
  boField?: string;
  /** 默认值 */
  defaultValue?: unknown;
  /** 占位提示 */
  placeholder?: string;
  /** 帮助文本 */
  helpText?: string;
  /** 错误提示 */
  errorMessage?: string;

  // 布局属性
  display?: 'block' | 'inline-block' | 'flex' | 'grid';
  flexDirection?: 'row' | 'row-reverse' | 'column' | 'column-reverse';
  justifyContent?: string;
  alignItems?: string;
  flexWrap?: string;
  gap?: string;
  gridTemplateColumns?: string;
  gridTemplateRows?: string;
  gridGap?: string;
  padding?: string;
  margin?: string;
  childLayout?: 'vertical' | 'horizontal' | 'grid';
  gridColumns?: number;

  // 尺寸
  width?: string;
  height?: string;
  minWidth?: string;
  maxWidth?: string;
  minHeight?: string;
  maxHeight?: string;

  // 校验
  required?: boolean;
  disabled?: boolean;
  readonly?: boolean;
  hidden?: boolean;
  minLength?: number;
  maxLength?: number;
  pattern?: string;
  autoSize?: boolean;
  showCount?: boolean;

  // 选项
  options?: FieldOption[];
  treeData?: TreeNode[];
  multiple?: boolean;

  // 组件特有
  format?: string;
  buttonType?: string;
  htmlType?: string;
  accept?: string;
  maxCount?: number;
  count?: number;
  allowHalf?: boolean;
  min?: number;
  max?: number;
  step?: number;
  range?: boolean;
  closable?: boolean;
  dividerType?: 'horizontal' | 'vertical';
  orientation?: 'left' | 'center' | 'right';
  plain?: boolean;
  fullscreen?: boolean;
  mode?: string;
  accordion?: boolean;
  tabPosition?: string;
  columns?: ColumnDef[];
  formula?: string;
  treeSelectMode?: string;

  // 扩展
  [key: string]: unknown;
}

// ================================ 表单定义 ================================

/** 页面 Schema 节点 — 统一布局控件节点和业务字段节点 */
export type SchemaNode = LayoutNode | DesignerFieldData;

export interface PageSchema {
  nodeId: string;
  type: string;
  children?: SchemaNode[];
  [key: string]: unknown;
}

export interface FormDefinition {
  /** 表单 ID */
  id: string;
  /** 表单名称 */
  name: string;
  /** 版本号 */
  revision: number;
  /** 表单类型 */
  type: 'form' | 'page' | 'bill';
  /** 页面 Schema */
  schema: PageSchema;
  /** 是否草稿 */
  draft: boolean;
  /** 创建时间 */
  createdTime?: string;
  /** 更新时间 */
  updatedTime?: string;
}

// ================================ 视图模式 ================================

export type ViewMode = 'design' | 'preview' | 'code';

// ================================ 校验问题 ================================

export type ProblemSeverity = 'error' | 'warning' | 'info';

export interface ValidationProblem {
  id: string;
  severity: ProblemSeverity;
  code: string;
  message: string;
  category: 'layout' | 'permission' | 'rule' | 'schema' | 'binding';
  nodeId?: string;
}

// ================================ 拖拽 ================================

export type DraggableItemType = ElementType | LayoutControlType;

export interface DragItem {
  type: DraggableItemType;
  label: string;
  /** 是否为布局控件 */
  isLayout?: boolean;
}

/** 判断是否为布局控件 */
export function isLayoutControl(type: string): type is LayoutControlType {
  return [
    'gridContainer', 'flexContainer', 'dockContainer', 'splitContainer',
    'scrollContainer', 'stickyContainer', 'tabsContainer', 'portalContainer',
    'responsiveContainer', 'masterDetailContainer', 'formGridContainer',
    'stackContainer', 'accordionContainer', 'cardGridContainer',
    'drawerContainer', 'dialogContainer',
  ].includes(type);
}
