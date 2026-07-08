/**
 * 表单设计器元素能力矩阵
 * 定义 29 个元素的 7 种操作（add/select/drag/configureProps/resize/delete/preview）
 * 以及对应的 AI 自动化测试抓手（data-testid）
 * 本文件是设计器元素能力的唯一事实源
 */

import type {
  ElementType,
  ElementCategory,
  OperationName,
} from './types';

// ================================ 常量 ================================

export const ELEMENT_TYPES = [
  // 基础 (9)
  'input',
  'inputNumber',
  'select',
  'datePicker',
  'checkbox',
  'radio',
  'switch',
  'button',
  'textarea',
  // 高级 (12)
  'upload',
  'cascader',
  'timePicker',
  'rangePicker',
  'autoComplete',
  'rate',
  'subTable',
  'richText',
  'tree',
  'transfer',
  'slider',
  'colorPicker',
  // 布局 (3)
  'card',
  'tabs',
  'collapse',
  // 展示 (2)
  'tag',
  'divider',
  // 特殊 (1)
  'calendar',
] as const satisfies readonly ElementType[];

export type { ElementType };
export type { ElementCategory };
export type { OperationName };

// ================================ 类型 ================================

export interface OperationCapability {
  /** 人类操作描述 */
  humanAction: string;
  /** AI 操作步骤（真实浏览器交互） */
  aiAction: string;
  /** 断言（验证操作成功） */
  assertion: string;
}

export interface ElementCapability {
  type: ElementType;
  /** 中文标签 */
  label: string;
  /** 分类 */
  category: ElementCategory;
  /** 是否接受子组件（容器） */
  acceptsChildren: boolean;
  /** 需要的属性控件 */
  propertyControls: string[];
  /** 测试抓手 ID */
  testIds: {
    palette: string;
    canvasNode: string;
    dragHandle: string;
    deleteButton: string;
    propertyPanel: string;
    dropZone?: string;
    resizeHandle?: string;
  };
  /** 各操作能力 */
  operations: Record<OperationName, OperationCapability>;
}

// ================================ 能力矩阵 ================================

function buildOperations(type: ElementType, label: string): Record<OperationName, OperationCapability> {
  return {
    add: {
      humanAction: `从左侧组件面板拖动或点击"${label}"到画布。`,
      aiAction: `定位 data-testid="palette-${type}"，使用 click 或 dragTo 到 data-testid="canvas-root"。`,
      assertion: `画布出现 data-testid="canvas-node" 且 data-node-type="${type}" 的节点。`,
    },
    select: {
      humanAction: `点击画布中的"${label}"节点。`,
      aiAction: `点击 data-testid="canvas-node" 中 data-node-type="${type}" 的节点。`,
      assertion: '节点进入选中状态，属性面板显示该节点属性。',
    },
    drag: {
      humanAction: '抓住节点拖拽手柄移动到新的排序位置或容器放置区。',
      aiAction: '定位 data-testid="drag-handle"，使用真实 mouse 或 dragTo 完成拖拽。',
      assertion: '节点在画布中的可见顺序或父容器位置发生变化。',
    },
    configureProps: {
      humanAction: '在右侧属性面板修改标签、字段、校验、默认值、选项等配置。',
      aiAction: '使用 property panel 内真实 input、select、switch、button 控件完成填写或点击。',
      assertion: '画布节点、预览态或 JSON 视图显示修改后的可见结果。',
    },
    resize: {
      humanAction: '通过宽高输入框或尺寸调整手柄修改组件尺寸。',
      aiAction: '填写 data-testid="prop-width"、data-testid="prop-height" 或拖动 resize handle。',
      assertion: '通过 boundingBox 验证节点宽度或高度变化。',
    },
    delete: {
      humanAction: '选中节点后点击删除按钮。',
      aiAction: '点击 data-testid="delete-node-button"。',
      assertion: '对应画布节点消失，字段数量减少。',
    },
    preview: {
      humanAction: '切换到预览模式并操作该组件。',
      aiAction: '点击预览模式标签，按组件真实控件形态输入、选择或点击。',
      assertion: '预览态控件可见且能够通过真实表单交互产生可见结果。',
    },
  };
}

const OPTION_TYPES = new Set<ElementType>([
  'select',
  'checkbox',
  'radio',
  'cascader',
  'autoComplete',
  'tag',
  'tree',
  'transfer',
]);

const CONTAINER_TYPES = new Set<ElementType>(['card', 'tabs', 'collapse']);

const COMMON_PROPERTY_CONTROLS = [
  'label',
  'fieldId',
  'placeholder',
  'required',
  'disabled',
  'readonly',
  'hidden',
  'helpText',
  'errorMessage',
  'minLength',
  'maxLength',
  'pattern',
  'width',
  'height',
  'minWidth',
  'maxWidth',
  'minHeight',
  'maxHeight',
  'defaultValue',
  'boField',
  'formula',
];

const OPTION_PROPERTY_CONTROLS = ['options', 'treeData', 'multiple'];

const CONTAINER_PROPERTY_CONTROLS = [
  'display',
  'flexDirection',
  'flexWrap',
  'justifyContent',
  'alignItems',
  'alignContent',
  'gap',
  'gridTemplateColumns',
  'gridTemplateRows',
  'gridGap',
  'padding',
  'margin',
  'childLayout',
  'gridColumns',
];

const SUBTABLE_PROPERTY_CONTROLS = ['columns', 'rowActions', 'addRowText', 'deleteRowText'];

const RICH_TEXT_PROPERTY_CONTROLS = ['toolbar', 'content', 'height'];

function buildPropertyControls(type: ElementType): string[] {
  const controls = [...COMMON_PROPERTY_CONTROLS];
  if (OPTION_TYPES.has(type)) controls.push(...OPTION_PROPERTY_CONTROLS);
  if (CONTAINER_TYPES.has(type)) controls.push(...CONTAINER_PROPERTY_CONTROLS);
  if (type === 'subTable') controls.push(...SUBTABLE_PROPERTY_CONTROLS);
  if (type === 'richText') controls.push(...RICH_TEXT_PROPERTY_CONTROLS);
  if (type === 'input' || type === 'textarea') {
    controls.push('minLength', 'maxLength', 'pattern', 'errorMessage');
  }
  return controls;
}

function buildCapability(type: ElementType, label: string): ElementCapability {
  const acceptsChildren = CONTAINER_TYPES.has(type);
  return {
    type,
    label,
    category: (
      type === 'card' || type === 'tabs' || type === 'collapse' ? 'layout'
      : type === 'tag' || type === 'divider' || type === 'calendar' ? 'display'
      : ['input', 'inputNumber', 'select', 'datePicker', 'checkbox', 'radio', 'switch', 'button', 'textarea'].includes(type) ? 'basic'
      : 'advanced'
    ),
    acceptsChildren,
    propertyControls: buildPropertyControls(type),
    testIds: {
      palette: `palette-${type}`,
      canvasNode: 'canvas-node',
      dragHandle: 'drag-handle',
      deleteButton: 'delete-node-button',
      propertyPanel: 'property-panel',
      dropZone: acceptsChildren ? `drop-zone-${type}` : undefined,
      resizeHandle: `resize-handle-${type}`,
    },
    operations: buildOperations(type, label),
  };
}

// ================================ 能力矩阵（29 元素） ================================

const LABELS: Record<ElementType, string> = {
  input: '单行输入',
  inputNumber: '数字输入',
  select: '下拉选择',
  datePicker: '日期选择',
  checkbox: '复选框',
  radio: '单选框',
  switch: '开关',
  button: '按钮',
  textarea: '多行文本',
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
  card: '卡片容器',
  tabs: '标签页容器',
  collapse: '折叠面板',
  tag: '标签',
  divider: '分割线',
  calendar: '日历',
};

export const ELEMENT_CAPABILITY_MATRIX = Object.fromEntries(
  ELEMENT_TYPES.map((type) => [type, buildCapability(type, LABELS[type])])
) as Record<ElementType, ElementCapability>;

export function getElementCapability(type: ElementType): ElementCapability {
  return ELEMENT_CAPABILITY_MATRIX[type];
}
