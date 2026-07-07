/**
 * Form Components Library
 * 37个表单组件，基于Ant Design封装
 *
 * 组件分类：
 * - P0（8个）：Input, InputNumber, Select, DatePicker, Checkbox, Radio, Switch, Button
 * - P1（15个）：Upload, TextArea, Cascader, Grid, Card, Tabs, SubTable等
 * - P2（14个）：RichText, ColorPicker, Slider, Tree, Transfer等
 *
 * 所有组件遵循统一接口：
 * interface ComponentProps {
 *   value: any;
 *   onChange: (value: any) => void;
 *   disabled?: boolean;
 *   readonly?: boolean;
 * }
 */

// P0基础组件（已在FieldRenderer中实现）
export { Input, InputNumber, Select, DatePicker, Checkbox, Radio, Switch, Button } from 'antd';

// P1重要组件
export { Upload, Cascader, Card, Tabs } from 'antd';

// P2增强组件
export { Slider, Tree, Transfer } from 'antd';

// 自定义组件
export * from './SubTableComponent';
export * from './RichTextComponent';

// 组件注册表
export const COMPONENT_REGISTRY = {
  // P0 - 基础组件
  input: 'Input',
  inputNumber: 'InputNumber',
  select: 'Select',
  datePicker: 'DatePicker',
  checkbox: 'Checkbox',
  radio: 'Radio',
  switch: 'Switch',
  button: 'Button',

  // P1 - 重要组件
  upload: 'Upload',
  textarea: 'TextArea',
  cascader: 'Cascader',
  card: 'Card',
  tabs: 'Tabs',
  subTable: 'SubTable',

  // P2 - 增强组件
  slider: 'Slider',
  tree: 'Tree',
  transfer: 'Transfer',
  richText: 'RichText',
};

export const COMPONENT_COUNT = Object.keys(COMPONENT_REGISTRY).length;
