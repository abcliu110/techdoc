/**
 * 共享常量
 */

import type { ElementType, ElementCategory, LayoutControlMeta, LayoutControlType } from './types';

export const ELEMENT_LABELS: Record<ElementType, string> = {
  // 基础输入
  input: '文本输入',
  inputNumber: '数字输入',
  textarea: '多行文本',
  datePicker: '日期选择',
  timePicker: '时间选择',
  rangePicker: '日期范围',
  // 选择引用
  select: '下拉选择',
  checkbox: '复选框',
  radio: '单选框',
  switch: '开关',
  autoComplete: '自动完成',
  cascader: '级联选择',
  tree: '树形选择',
  transfer: '穿梭框',
  slider: '滑块',
  rate: '评分',
  // 上传展示
  upload: '文件上传',
  colorPicker: '颜色选择',
  richText: '富文本',
  // 业务语义
  subTable: '子表格',
  // 展示
  tag: '标签',
  divider: '分割线',
  calendar: '日历',
};

export const ELEMENT_CATEGORIES: Record<ElementType, ElementCategory> = {
  input: 'basic',
  inputNumber: 'basic',
  textarea: 'basic',
  datePicker: 'basic',
  timePicker: 'basic',
  rangePicker: 'basic',
  select: 'basic',
  checkbox: 'basic',
  radio: 'basic',
  switch: 'basic',
  autoComplete: 'advanced',
  cascader: 'advanced',
  tree: 'advanced',
  transfer: 'advanced',
  slider: 'advanced',
  rate: 'advanced',
  upload: 'advanced',
  colorPicker: 'advanced',
  richText: 'advanced',
  subTable: 'advanced',
  tag: 'display',
  divider: 'display',
  calendar: 'display',
};

export const ELEMENT_TYPES = Object.keys(ELEMENT_LABELS) as ElementType[];

/** 控件库分类 */
export interface PaletteCategory {
  key: string;
  label: string;
  types: ElementType[];
}

export const PALETTE_CATEGORIES: PaletteCategory[] = [
  {
    key: 'basic',
    label: '基础字段',
    types: ['input', 'inputNumber', 'textarea', 'datePicker', 'timePicker', 'rangePicker', 'select', 'checkbox', 'radio', 'switch'],
  },
  {
    key: 'advanced',
    label: '高级字段',
    types: ['autoComplete', 'cascader', 'tree', 'transfer', 'slider', 'rate', 'upload', 'colorPicker', 'richText', 'subTable'],
  },
  {
    key: 'display',
    label: '展示控件',
    types: ['tag', 'divider', 'calendar'],
  },
];

/** 控件图标 */
export const ELEMENT_ICONS: Record<ElementType, string> = {
  input: 'T',
  inputNumber: '#',
  textarea: '¶',
  datePicker: '📅',
  timePicker: '⏰',
  rangePicker: '⬌',
  select: '▾',
  checkbox: '☐',
  radio: '○',
  switch: '⊜',
  autoComplete: '…',
  cascader: '⊞',
  tree: '⊢',
  transfer: '⇄',
  slider: '━',
  rate: '★',
  upload: '↑',
  colorPicker: '◐',
  richText: '✎',
  subTable: '≡',
  tag: '◇',
  divider: '—',
  calendar: '▦',
};

// ================================ 布局控件注册表 ================================

/** P0 布局控件注册表 — 全部 10 种 */
export const LAYOUT_CONTROLS: LayoutControlMeta[] = [
  {
    type: 'gridContainer',
    label: 'GridLayout',
    icon: 'G',
    description: '24列、area、minmax、gap、断点',
    priority: 'P0',
    slots: [
      { name: 'default', label: '主区域', required: true },
      { name: 'header', label: '顶部区域' },
      { name: 'footer', label: '底部区域' },
    ],
    defaultStyle: { display: 'grid', gridTemplateColumns: 'repeat(24, 1fr)', gap: '8px' },
  },
  {
    type: 'formGridContainer',
    label: 'FormGridContainer',
    icon: 'FG',
    description: '表单网格，自动生成 label + editor + validation',
    priority: 'P0',
    slots: [
      { name: 'default', label: '字段区域', required: true },
    ],
    defaultStyle: { display: 'grid', gridTemplateColumns: 'repeat(24, 1fr)', gap: '6px 8px', padding: '22px 8px 8px' },
  },
  {
    type: 'flexContainer',
    label: 'FlexLayout',
    icon: 'F',
    description: 'row/column/wrap/grow/shrink',
    priority: 'P0',
    slots: [
      { name: 'default', label: '流式区域', required: true },
      { name: 'left', label: '左侧工具组' },
      { name: 'right', label: '右侧工具组' },
    ],
    defaultStyle: { display: 'flex', flexWrap: 'wrap', gap: '8px' },
  },
  {
    type: 'dockContainer',
    label: 'DockLayout',
    icon: 'D',
    description: 'top/left/right/bottom/fill 停靠',
    priority: 'P0',
    slots: [
      { name: 'top', label: '顶部' },
      { name: 'left', label: '左侧导航' },
      { name: 'right', label: '右侧信息' },
      { name: 'bottom', label: '底部' },
      { name: 'fill', label: '主体内容', required: true },
    ],
    defaultStyle: { display: 'grid', height: '100%' },
  },
  {
    type: 'splitContainer',
    label: 'SplitPane',
    icon: 'SP',
    description: '左右/上下分割、拖拽比例',
    priority: 'P0',
    slots: [
      { name: 'primary', label: '主面板' },
      { name: 'secondary', label: '次面板' },
    ],
    defaultStyle: { display: 'grid', gap: '4px' },
  },
  {
    type: 'scrollContainer',
    label: 'ScrollContainer',
    icon: 'SC',
    description: '局部滚动、滚动阴影、焦点滚动',
    priority: 'P0',
    slots: [
      { name: 'header', label: '吸顶头部' },
      { name: 'default', label: '滚动内容', required: true },
    ],
    defaultStyle: { overflowY: 'auto' },
  },
  {
    type: 'stickyContainer',
    label: 'StickyRegion',
    icon: 'ST',
    description: 'top/bottom 固定、z-index 层叠',
    priority: 'P0',
    slots: [
      { name: 'stickyTop', label: '顶部固定' },
      { name: 'body', label: '滚动内容', required: true },
      { name: 'stickyBottom', label: '底部固定' },
    ],
    defaultStyle: { display: 'grid', gridTemplateRows: 'auto 1fr auto' },
  },
  {
    type: 'tabsContainer',
    label: 'TabsContainer',
    icon: 'TB',
    description: '懒加载、权限隐藏、错误标记',
    priority: 'P0',
    slots: [
      { name: 'panels', label: 'TabPanel[]', required: true },
    ],
    defaultStyle: { display: 'grid', gridTemplateRows: '34px 1fr' },
  },
  {
    type: 'portalContainer',
    label: 'PortalContainer',
    icon: 'PT',
    description: '弹窗、抽屉、下拉、右键菜单统一层',
    priority: 'P0',
    slots: [
      { name: 'root', label: '根页面' },
      { name: 'overlay', label: '浮层区域' },
    ],
    defaultStyle: { position: 'relative' },
  },
  {
    type: 'responsiveContainer',
    label: 'ResponsiveContainer',
    icon: 'RS',
    description: 'PC 断点 1280/1440/1600 覆盖规则',
    priority: 'P0',
    slots: [
      { name: 'default', label: '默认/主布局', required: true },
    ],
    defaultStyle: {},
  },
  {
    type: 'masterDetailContainer',
    label: 'MasterDetail',
    icon: 'MD',
    description: '主从、列表详情、树详情',
    priority: 'P0',
    slots: [
      { name: 'master', label: '主表/列表' },
      { name: 'detail', label: '明细/详情' },
    ],
    defaultStyle: { display: 'grid', gap: '8px' },
  },
  {
    type: 'stackContainer',
    label: 'StackContainer',
    icon: 'SK',
    description: '纵向堆叠、区块顺序、区块高度约束',
    priority: 'P1',
    slots: [
      { name: 'sections', label: 'Section[]', required: true },
    ],
    defaultStyle: { display: 'grid', gap: '8px' },
  },
  {
    type: 'accordionContainer',
    label: 'AccordionContainer',
    icon: 'AC',
    description: '折叠分组、单开/多开、懒渲染',
    priority: 'P1',
    slots: [
      { name: 'items', label: 'AccordionItem[]', required: true },
    ],
    defaultStyle: { display: 'grid', gap: '0' },
  },
  {
    type: 'cardGridContainer',
    label: 'CardGrid',
    icon: 'CG',
    description: '卡片网格、最小宽度、自适应列',
    priority: 'P1',
    slots: [
      { name: 'cards', label: 'Card[]', required: true },
    ],
    defaultStyle: { display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '8px' },
  },
  {
    type: 'drawerContainer',
    label: 'DrawerContainer',
    icon: 'DR',
    description: 'left/right/top/bottom 抽屉、可调整宽度',
    priority: 'P1',
    slots: [
      { name: 'base', label: '底层页面' },
      { name: 'drawer', label: '抽屉内容' },
    ],
    defaultStyle: { position: 'relative' },
  },
  {
    type: 'dialogContainer',
    label: 'DialogContainer',
    icon: 'DG',
    description: '模态弹窗、焦点边界、底部动作',
    priority: 'P1',
    slots: [
      { name: 'title', label: '标题栏' },
      { name: 'body', label: '弹窗内容' },
      { name: 'footer', label: '底部动作' },
    ],
    defaultStyle: { position: 'fixed', width: '600px' },
  },
];

/** 布局控件注册表映射 */
export const LAYOUT_CONTROL_MAP = new Map<LayoutControlType, LayoutControlMeta>(
  LAYOUT_CONTROLS.map(c => [c.type, c])
);

/** 按优先级分组 */
export const LAYOUT_CONTROLS_P0 = LAYOUT_CONTROLS.filter(c => c.priority === 'P0');
export const LAYOUT_CONTROLS_P1 = LAYOUT_CONTROLS.filter(c => c.priority === 'P1');

/** 布局控件图标 */
export const LAYOUT_CONTROL_ICONS: Record<LayoutControlType, string> = {
  gridContainer: 'G',
  formGridContainer: 'FG',
  flexContainer: 'F',
  dockContainer: 'D',
  splitContainer: 'SP',
  scrollContainer: 'SC',
  stickyContainer: 'ST',
  tabsContainer: 'TB',
  portalContainer: 'PT',
  responsiveContainer: 'RS',
  masterDetailContainer: 'MD',
  stackContainer: 'SK',
  accordionContainer: 'AC',
  cardGridContainer: 'CG',
  drawerContainer: 'DR',
  dialogContainer: 'DG',
};
