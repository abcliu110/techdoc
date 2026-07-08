export const ELEMENT_TYPES = [
  'input',
  'inputNumber',
  'select',
  'datePicker',
  'checkbox',
  'radio',
  'switch',
  'button',
  'textarea',
  'upload',
  'cascader',
  'timePicker',
  'rangePicker',
  'autoComplete',
  'rate',
  'tag',
  'card',
  'tabs',
  'collapse',
  'divider',
  'subTable',
  'richText',
  'tree',
  'transfer',
  'slider',
  'colorPicker',
  'calendar',
] as const;

export type ElementType = (typeof ELEMENT_TYPES)[number];

export type ElementCategory = 'basic' | 'advanced' | 'layout' | 'display';

export type OperationName =
  | 'add'
  | 'select'
  | 'drag'
  | 'configureProps'
  | 'resize'
  | 'delete'
  | 'preview';

export interface OperationCapability {
  humanAction: string;
  aiAction: string;
  assertion: string;
}

export interface ElementCapability {
  type: ElementType;
  label: string;
  category: ElementCategory;
  acceptsChildren: boolean;
  propertyControls: string[];
  testIds: {
    palette: string;
    canvasNode: string;
    dragHandle: string;
    deleteButton: string;
    propertyPanel: string;
    dropZone?: string;
    resizeHandle?: string;
  };
  operations: Record<OperationName, OperationCapability>;
}

const COMMON_PROPERTY_CONTROLS = [
  'label',
  'fieldId',
  'placeholder',
  'required',
  'disabled',
  'readonly',
  'helpText',
  'width',
  'height',
] as const;

const OPTION_PROPERTY_CONTROLS = ['options', 'defaultValue'] as const;
const CONTAINER_PROPERTY_CONTROLS = ['childLayout', 'gap', 'gridColumns', 'gridGap', 'padding'] as const;

const LABELS: Record<ElementType, string> = {
  input: '输入框',
  inputNumber: '数字输入框',
  select: '下拉选择',
  datePicker: '日期选择',
  checkbox: '复选框',
  radio: '单选框',
  switch: '开关',
  button: '按钮',
  textarea: '多行文本',
  upload: '上传',
  cascader: '级联选择',
  timePicker: '时间选择',
  rangePicker: '日期范围',
  autoComplete: '自动完成',
  rate: '评分',
  tag: '标签',
  card: '卡片容器',
  tabs: '选项卡容器',
  collapse: '折叠面板容器',
  divider: '分割线',
  subTable: '子表格',
  richText: '富文本',
  tree: '树选择',
  transfer: '穿梭框',
  slider: '滑块',
  colorPicker: '颜色选择',
  calendar: '日历',
};

const CATEGORIES: Record<ElementType, ElementCategory> = {
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
  tag: 'display',
  card: 'layout',
  tabs: 'layout',
  collapse: 'layout',
  divider: 'display',
  subTable: 'advanced',
  richText: 'advanced',
  tree: 'advanced',
  transfer: 'advanced',
  slider: 'advanced',
  colorPicker: 'advanced',
  calendar: 'display',
};

const CONTAINER_TYPES = new Set<ElementType>(['card', 'tabs', 'collapse']);

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

function buildOperations(type: ElementType, label: string): Record<OperationName, OperationCapability> {
  return {
    add: {
      humanAction: `从左侧组件面板拖动或点击“${label}”到画布。`,
      aiAction: `定位 data-testid="palette-${type}"，使用 click 或 dragTo 到 data-testid="canvas-root"。`,
      assertion: `画布出现 data-testid="canvas-node" 且 data-node-type="${type}" 的节点。`,
    },
    select: {
      humanAction: `点击画布中的“${label}”节点。`,
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
      aiAction: '使用 property panel 内真实 input、select、checkbox、button 控件完成填写或点击。',
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

function buildPropertyControls(type: ElementType): string[] {
  const controls = [...COMMON_PROPERTY_CONTROLS];

  if (OPTION_TYPES.has(type)) {
    controls.push(...OPTION_PROPERTY_CONTROLS);
  }

  if (CONTAINER_TYPES.has(type)) {
    controls.push(...CONTAINER_PROPERTY_CONTROLS);
  }

  if (type === 'subTable') {
    controls.push('columns', 'rowActions');
  }

  if (type === 'richText') {
    controls.push('toolbar', 'content');
  }

  return controls;
}

function buildCapability(type: ElementType): ElementCapability {
  const label = LABELS[type];
  const acceptsChildren = CONTAINER_TYPES.has(type);

  return {
    type,
    label,
    category: CATEGORIES[type],
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

export const ELEMENT_CAPABILITY_MATRIX = Object.fromEntries(
  ELEMENT_TYPES.map((type) => [type, buildCapability(type)])
) as Record<ElementType, ElementCapability>;

export function getElementCapability(type: ElementType): ElementCapability {
  return ELEMENT_CAPABILITY_MATRIX[type];
}
