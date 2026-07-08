/**
 * 表单设计器类型定义
 * 统一管理设计器相关的所有类型、组件元数据、字段模型
 */

/** ================================ 元素类型 ================================ */

/** 基础组件 */
export type BasicElementType =
  | 'input'           // 单行输入框
  | 'inputNumber'     // 数字输入框
  | 'select'          // 下拉选择
  | 'datePicker'      // 日期选择
  | 'checkbox'        // 复选框（单选时）/复选组（多选时）
  | 'radio'           // 单选框组
  | 'switch'          // 开关
  | 'button'          // 按钮
  | 'textarea';       // 多行文本

/** 高级组件 */
export type AdvancedElementType =
  | 'upload'          // 文件上传
  | 'cascader'        // 级联选择
  | 'timePicker'      // 时间选择
  | 'rangePicker'     // 日期范围选择
  | 'autoComplete'    // 自动完成
  | 'rate'            // 评分
  | 'subTable'        // 子表格（数据表格）
  | 'richText'        // 富文本编辑器
  | 'tree'            // 树形选择
  | 'transfer'        // 穿梭框
  | 'slider'          // 滑块
  | 'colorPicker';    // 颜色选择器

/** 布局组件（可容纳子组件） */
export type LayoutElementType =
  | 'card'            // 卡片容器
  | 'tabs'            // 标签页容器
  | 'collapse';       // 折叠面板容器

/** 展示组件 */
export type DisplayElementType =
  | 'tag'             // 标签
  | 'divider';        // 分割线

/** 日历 */
export type CalendarType = 'calendar';

/** 全部元素类型 */
export type ElementType =
  | BasicElementType
  | AdvancedElementType
  | LayoutElementType
  | DisplayElementType
  | CalendarType;

/** ================================ 元素分类 ================================ */

export type ElementCategory = 'basic' | 'advanced' | 'layout' | 'display';

/** 元素元数据 */
export interface ElementMeta {
  type: ElementType;
  /** 中文展示名称 */
  label: string;
  /** 分类 */
  category: ElementCategory;
  /** 是否可容纳子组件 */
  acceptsChildren: boolean;
  /** 图标（emoji） */
  icon: string;
  /** 优先级（影响面板分组） */
  priority: 0 | 1 | 2;
}

/** ================================ 字段模型 ================================ */

/** 字段选项（用于 select/radio/checkbox/autoComplete/tree 等） */
export interface FieldOption {
  label: string;
  value: string;
}

/** 树形数据节点 */
export interface TreeNode {
  label: string;
  value: string;
  children?: TreeNode[];
}

/** 单个设计字段 */
export interface DesignerField {
  /** 唯一标识（稳定 lid） */
  id: string;
  /** 字段编码（业务标识） */
  fieldId: string;
  /** 字段标签 */
  label: string;
  /** 组件类型 */
  type: ElementType;
  /** 组件唯一标识（供 AI 定位） */
  nodeId?: string;
}

/** 设计器字段（完整版，含所有属性） */
export interface DesignerFieldData extends DesignerField {
  /** 占位提示 */
  placeholder?: string;
  /** 默认值 */
  defaultValue?: string | number | boolean | string[];
  /** 是否必填 */
  required?: boolean;
  /** 是否禁用 */
  disabled?: boolean;
  /** 是否只读 */
  readonly?: boolean;
  /** 是否隐藏 */
  hidden?: boolean;
  /** 帮助文本 */
  helpText?: string;
  /** 错误提示 */
  errorMessage?: string;
  /** 最小长度 */
  minLength?: number;
  /** 最大长度 */
  maxLength?: number;
  /** 正则表达式 */
  pattern?: string;

  // === 选项配置（select/radio/checkbox/autoComplete/tree/transfer/tag） ===
  /** 选项列表 */
  options?: FieldOption[];
  /** 树形数据 */
  treeData?: TreeNode[];
  /** 多选（select/checkbox） */
  multiple?: boolean;

  // === 尺寸配置（所有元素支持完整 CSS 单位） ===
  /** 宽度，支持 px/%/rem/em/vw/vh/auto 等 */
  width?: string;
  /** 高度，支持 px/%/rem/em/vh/auto 等 */
  height?: string;
  /** 最小宽度 */
  minWidth?: string;
  /** 最大宽度 */
  maxWidth?: string;
  /** 最小高度 */
  minHeight?: string;
  /** 最大高度 */
  maxHeight?: string;

  // === CSS 布局配置（布局组件 card/tabs/collapse 使用） ===
  /** 布局模式：block | inline-block | flex | grid */
  display?: 'block' | 'inline-block' | 'flex' | 'grid';
  /** Flex 主轴方向 */
  flexDirection?: 'row' | 'row-reverse' | 'column' | 'column-reverse';
  /** Flex 换行 */
  flexWrap?: 'nowrap' | 'wrap' | 'wrap-reverse';
  /** Flex 主轴对齐 */
  justifyContent?: 'flex-start' | 'center' | 'flex-end' | 'space-between' | 'space-around' | 'space-evenly';
  /** Flex 交叉轴对齐 */
  alignItems?: 'stretch' | 'flex-start' | 'center' | 'flex-end' | 'baseline';
  /** Flex 多行对齐 */
  alignContent?: 'stretch' | 'flex-start' | 'center' | 'flex-end' | 'space-between' | 'space-around';
  /** 间距（gap） */
  gap?: string;
  /** Grid 列定义 */
  gridTemplateColumns?: string;
  /** Grid 行定义 */
  gridTemplateRows?: string;
  /** Grid 单元格间距 */
  gridGap?: string;
  /** 内边距 */
  padding?: string;
  /** 外边距 */
  margin?: string;

  // === 子组件布局（兼容旧逻辑，与 display 互斥时 display 优先） ===
  /** 子组件布局方式 */
  childLayout?: 'vertical' | 'horizontal' | 'grid';
  /** Grid 列数 */
  gridColumns?: number;

  // === 高级配置 ===
  /** 绑定的 BO 字段 */
  boField?: string;
  /** 计算表达式 */
  formula?: string;

  // === 容器子组件 ===
  /** 子组件列表（仅容器组件使用） */
  children?: DesignerFieldData[];
}

/** ================================ 表单定义 ================================ */

/** 表单布局 */
export interface FormLayout {
  type: 'horizontal' | 'vertical' | 'inline';
  /** 栅格列数 */
  columns?: number;
  /** 标签宽度 */
  labelWidth?: string;
}

/** 表单定义 */
export interface FormDefinition {
  /** 表单 ID */
  formId: string;
  /** 表单名称 */
  formName: string;
  /** 业务对象 ID */
  boId?: string;
  /** 表单类型 */
  formType?: 'edit' | 'view' | 'add' | 'detail';
  /** 版本 */
  version?: string;
  /** 布局 */
  layout?: FormLayout;
  /** 字段列表 */
  fields: DesignerFieldData[];
}

/** ================================ 视图模式 ================================ */

export type ViewMode = 'design' | 'preview' | 'code';

/** ================================ 操作类型 ================================ */

/** 设计器支持的 7 种操作 */
export type OperationName =
  | 'add'      // 添加
  | 'select'   // 选中
  | 'drag'     // 拖拽排序
  | 'configureProps'  // 配置属性
  | 'resize'   // 调整尺寸
  | 'delete'   // 删除
  | 'preview'; // 预览

/** ================================ 元素元数据注册表 ================================ */

/** 全部 29 个元素的中文名称 */
export const ELEMENT_LABELS: Record<ElementType, string> = {
  // 基础
  input: '单行输入',
  inputNumber: '数字输入',
  select: '下拉选择',
  datePicker: '日期选择',
  checkbox: '复选框',
  radio: '单选框',
  switch: '开关',
  button: '按钮',
  textarea: '多行文本',
  // 高级
  upload: '文件上传',
  cascader: '级联选择',
  timePicker: '时间选择',
  rangePicker: '日期范围',
  autoComplete: '自动完成',
  rate: '评分',
  subTable: '子表格',
  richText: '富文本',
  tree: '树形选择',
  transfer: '穿梭框',
  slider: '滑块',
  colorPicker: '颜色选择',
  // 布局
  card: '卡片容器',
  tabs: '标签页容器',
  collapse: '折叠面板',
  // 展示
  tag: '标签',
  divider: '分割线',
  // 特殊
  calendar: '日历',
};

/** 全部 29 个元素的分类 */
export const ELEMENT_CATEGORIES: Record<ElementType, ElementCategory> = {
  input: 'basic',
  inputNumber: 'basic',
  select: 'basic',
  datePicker: 'basic',
  checkbox: 'basic',
  radio: 'basic',
  switch: 'basic',
  button: 'basic',
  textarea: 'basic',
  upload: 'advanced',
  cascader: 'advanced',
  timePicker: 'advanced',
  rangePicker: 'advanced',
  autoComplete: 'advanced',
  rate: 'advanced',
  subTable: 'advanced',
  richText: 'advanced',
  tree: 'advanced',
  transfer: 'advanced',
  slider: 'advanced',
  colorPicker: 'advanced',
  card: 'layout',
  tabs: 'layout',
  collapse: 'layout',
  tag: 'display',
  divider: 'display',
  calendar: 'display',
};

/** 全部 29 个元素是否接受子组件 */
export const CONTAINER_TYPES: Set<ElementType> = new Set(['card', 'tabs', 'collapse']);
