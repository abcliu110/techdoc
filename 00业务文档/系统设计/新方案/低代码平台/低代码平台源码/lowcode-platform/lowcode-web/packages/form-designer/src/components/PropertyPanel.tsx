/**
 * 属性面板
 * 支持完整字段配置 + CSS 尺寸 + CSS 布局
 * 所有输入控件提供 AI 可控性抓手（data-testid）
 */

import React, { useMemo } from 'react';
import { Form, Input, Select, Switch, Collapse, Card, Tag, Space, Button, InputNumber } from 'antd';
import { DeleteOutlined } from '@ant-design/icons';
import type { DesignerFieldData, DesignerFieldData as Field } from '../types';
import { ELEMENT_LABELS, CONTAINER_TYPES } from '../types';

const { TextArea } = Input;
const { Panel } = Collapse;

/** 尺寸单位选项 */
const SIZE_UNITS = [
  { value: 'px', label: 'px' },
  { value: '%', label: '%' },
  { value: 'auto', label: 'auto' },
];

/** 解析尺寸值，返回 { value, unit } */
function parseSizeValue(raw: string | undefined): { value: number | undefined; unit: string } {
  if (!raw || raw === 'auto') return { value: undefined, unit: 'auto' };
  const match = raw.match(/^(-?\d+(?:\.\d+)?)(px|%|rem|em|vw|vh)?$/);
  if (match) {
    // 有单位时用对应单位；纯数字默认 px（避免 textarea 输入 "150" 后单位默认 auto 导致测试失败）
    return { value: parseFloat(match[1]), unit: match[2] || 'px' };
  }
  return { value: parseFloat(raw) || undefined, unit: 'px' };
}

/** 组合尺寸值 */
function buildSizeValue(value: number | undefined, unit: string): string | undefined {
  if (unit === 'auto') return 'auto';
  if (value === undefined || isNaN(value)) return undefined;
  return `${value}${unit}`;
}

export interface PropertyPanelProps {
  selectedField: DesignerFieldData | null;
  onFieldUpdate: (updates: Partial<DesignerFieldData>) => void;
  onFieldDelete?: () => void;
  onFieldDuplicate?: () => void;
  onFieldSelect?: (fieldId: string) => void;
}

export const PropertyPanel: React.FC<PropertyPanelProps> = ({
  selectedField,
  onFieldUpdate,
  onFieldDelete,
  onFieldDuplicate,
  onFieldSelect,
}) => {
  const isContainer = useMemo(
    () => selectedField ? CONTAINER_TYPES.has(selectedField.type as never) : false,
    [selectedField]
  );

  if (!selectedField) {
    return (
      <div
        data-testid="property-panel-empty"
        style={{ padding: '16px', height: '100vh', overflow: 'auto' }}
      >
        <h3 style={{ fontSize: '14px', marginBottom: '12px' }}>🛠️ 属性面板</h3>
        <div
          style={{
            padding: '40px 16px',
            textAlign: 'center',
            color: '#999',
            fontSize: '13px',
          }}
        >
          <div style={{ fontSize: '32px', marginBottom: '12px' }}>👈</div>
          <div>从画布选择一个字段</div>
          <div style={{ marginTop: '8px', color: '#ccc', fontSize: '11px' }}>
            选中后可编辑属性
          </div>
        </div>
      </div>
    );
  }

  return (
    <div
      data-testid="property-panel"
      style={{ padding: '12px', height: '100vh', overflow: 'auto' }}
    >
      {/* 头部 */}
      <div
        style={{
          marginBottom: '12px',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
        }}
      >
        <h3
          data-testid="property-panel-title"
          style={{ fontSize: '14px', margin: 0 }}
        >
          🛠️ 属性面板
        </h3>
        <Space size={4}>
          <Tag color="blue" style={{ fontSize: '10px' }}>
            {ELEMENT_LABELS[selectedField.type] || selectedField.type}
          </Tag>
          {isContainer && <Tag color="purple" style={{ fontSize: '10px' }}>容器</Tag>}
        </Space>
      </div>

      {/* 字段标识 */}
      <Card size="small" style={{ marginBottom: '8px' }}>
        <div style={{ fontSize: '11px', color: '#999', marginBottom: '4px' }}>
          字段ID: {selectedField.id || selectedField.fieldId}
        </div>
        <div style={{ fontSize: '11px', color: '#999', marginBottom: '8px' }}>
          类型: {selectedField.type}
        </div>
        <Button
          data-testid="clear-selection-button"
          size="small"
          block
          onClick={(e) => {
            e.stopPropagation();
            onFieldSelect?.('');
          }}
        >
          清空选中
        </Button>
      </Card>

      <Collapse
        defaultActiveKey={['basic', 'style', 'layout', 'validation', 'advanced']}
        size="small"
        style={{ background: 'transparent' }}
      >
        {/* === 基础属性 === */}
        <Panel
          header={<span style={{ fontSize: '12px' }}>📝 基础属性</span>}
          key="basic"
        >
          <Form layout="vertical" size="small">
            {/* 字段标签 */}
            <Form.Item label="字段标签" style={{ marginBottom: '8px' }}>
              <Input
                data-testid="prop-label"
                value={selectedField.label}
                onChange={e => onFieldUpdate({ label: e.target.value })}
                placeholder="如：用户名"
              />
            </Form.Item>

            {/* 字段编码 */}
            <Form.Item label="字段编码" style={{ marginBottom: '8px' }}>
              <Input
                data-testid="prop-field-id"
                value={selectedField.fieldId}
                onChange={e => onFieldUpdate({ fieldId: e.target.value })}
                placeholder="如：userName"
              />
            </Form.Item>

            {/* 占位符 */}
            <Form.Item label="占位提示" style={{ marginBottom: '8px' }}>
              <Input
                data-testid="prop-placeholder"
                value={selectedField.placeholder}
                onChange={e => onFieldUpdate({ placeholder: e.target.value })}
                placeholder="如：请输入用户名"
              />
            </Form.Item>

            {/* 默认值 */}
            <Form.Item label="默认值" style={{ marginBottom: '8px' }}>
              <Input
                data-testid="prop-default-value"
                value={selectedField.defaultValue as string ?? ''}
                onChange={e => onFieldUpdate({ defaultValue: e.target.value })}
                placeholder="默认值"
              />
            </Form.Item>

            {/* 帮助文本 */}
            <Form.Item label="帮助文本" style={{ marginBottom: '8px' }}>
              <TextArea
                data-testid="prop-help-text"
                value={selectedField.helpText}
                onChange={e => onFieldUpdate({ helpText: e.target.value })}
                placeholder="给用户的提示信息"
                rows={2}
              />
            </Form.Item>

            {/* BO 绑定 */}
            <Form.Item label="BO 绑定字段" style={{ marginBottom: '8px' }}>
              <Input
                data-testid="prop-bo-field"
                value={selectedField.boField}
                onChange={e => onFieldUpdate({ boField: e.target.value })}
                placeholder="绑定的业务对象字段"
              />
            </Form.Item>

            {/* 必填 / 禁用 / 只读 */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <span style={{ fontSize: '12px' }}>必填</span>
                <Switch
                  data-testid="prop-required"
                  size="small"
                  checked={selectedField.required}
                  onChange={val => onFieldUpdate({ required: val })}
                />
              </div>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <span style={{ fontSize: '12px' }}>禁用</span>
                <Switch
                  data-testid="prop-disabled"
                  size="small"
                  checked={selectedField.disabled}
                  onChange={val => onFieldUpdate({ disabled: val })}
                />
              </div>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <span style={{ fontSize: '12px' }}>只读</span>
                <Switch
                  data-testid="prop-readonly"
                  size="small"
                  checked={selectedField.readonly}
                  onChange={val => onFieldUpdate({ readonly: val })}
                />
              </div>
            </div>
          </Form>
        </Panel>

        {/* === 尺寸配置 === */}
        <Panel
          header={<span style={{ fontSize: '12px' }}>📐 尺寸配置</span>}
          key="style"
        >
          <Form layout="vertical" size="small">
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px' }}>
              {/* 宽度 */}
              {(() => {
                const w = parseSizeValue(selectedField.width);
                return (
                  <Form.Item label="宽度" style={{ marginBottom: '6px' }}>
                    <div style={{ display: 'flex', gap: '4px' }}>
                      <InputNumber
                        data-testid="prop-width"
                        style={{ flex: 1, minWidth: 0 }}
                        value={w.value}
                        min={0}
                        controls={false}
                        onChange={val => onFieldUpdate({ width: buildSizeValue(val ?? undefined, w.unit === 'auto' ? 'px' : w.unit) })}
                        placeholder="数值"
                      />
                      <Select
                        data-testid="prop-width-unit"
                        style={{ width: '60px' }}
                        value={w.unit}
                        onChange={unit => onFieldUpdate({ width: buildSizeValue(w.value, unit) })}
                        options={SIZE_UNITS}
                      />
                    </div>
                  </Form.Item>
                );
              })()}

              {/* 高度 */}
              {(() => {
                const h = parseSizeValue(selectedField.height);
                return (
                  <Form.Item label="高度" style={{ marginBottom: '6px' }}>
                    <div style={{ display: 'flex', gap: '4px' }}>
                      <InputNumber
                        data-testid="prop-height"
                        style={{ flex: 1, minWidth: 0 }}
                        value={h.value}
                        min={0}
                        controls={false}
                        onChange={val => onFieldUpdate({ height: buildSizeValue(val ?? undefined, h.unit === 'auto' ? 'px' : h.unit) })}
                        placeholder="数值"
                      />
                      <Select
                        data-testid="prop-height-unit"
                        style={{ width: '60px' }}
                        value={h.unit}
                        onChange={unit => onFieldUpdate({ height: buildSizeValue(h.value, unit) })}
                        options={SIZE_UNITS}
                      />
                    </div>
                  </Form.Item>
                );
              })()}

              {/* 最小宽度 */}
              {(() => {
                const v = parseSizeValue(selectedField.minWidth);
                return (
                  <Form.Item label="最小宽度" style={{ marginBottom: '6px' }}>
                    <div style={{ display: 'flex', gap: '4px' }}>
                      <InputNumber
                        data-testid="prop-min-width"
                        style={{ flex: 1, minWidth: 0 }}
                        value={v.value}
                        min={0}
                        controls={false}
                        onChange={val => onFieldUpdate({ minWidth: buildSizeValue(val ?? undefined, v.unit === 'auto' ? 'px' : v.unit) })}
                        placeholder="数值"
                      />
                      <Select
                        data-testid="prop-min-width-unit"
                        style={{ width: '60px' }}
                        value={v.unit}
                        onChange={unit => onFieldUpdate({ minWidth: buildSizeValue(v.value, unit) })}
                        options={SIZE_UNITS}
                      />
                    </div>
                  </Form.Item>
                );
              })()}

              {/* 最大宽度 */}
              {(() => {
                const v = parseSizeValue(selectedField.maxWidth);
                return (
                  <Form.Item label="最大宽度" style={{ marginBottom: '6px' }}>
                    <div style={{ display: 'flex', gap: '4px' }}>
                      <InputNumber
                        data-testid="prop-max-width"
                        style={{ flex: 1, minWidth: 0 }}
                        value={v.value}
                        min={0}
                        controls={false}
                        onChange={val => onFieldUpdate({ maxWidth: buildSizeValue(val ?? undefined, v.unit === 'auto' ? 'px' : v.unit) })}
                        placeholder="数值"
                      />
                      <Select
                        data-testid="prop-max-width-unit"
                        style={{ width: '60px' }}
                        value={v.unit}
                        onChange={unit => onFieldUpdate({ maxWidth: buildSizeValue(v.value, unit) })}
                        options={SIZE_UNITS}
                      />
                    </div>
                  </Form.Item>
                );
              })()}

              {/* 最小高度 */}
              {(() => {
                const v = parseSizeValue(selectedField.minHeight);
                return (
                  <Form.Item label="最小高度" style={{ marginBottom: '6px' }}>
                    <div style={{ display: 'flex', gap: '4px' }}>
                      <InputNumber
                        data-testid="prop-min-height"
                        style={{ flex: 1, minWidth: 0 }}
                        value={v.value}
                        min={0}
                        controls={false}
                        onChange={val => onFieldUpdate({ minHeight: buildSizeValue(val ?? undefined, v.unit === 'auto' ? 'px' : v.unit) })}
                        placeholder="数值"
                      />
                      <Select
                        data-testid="prop-min-height-unit"
                        style={{ width: '60px' }}
                        value={v.unit}
                        onChange={unit => onFieldUpdate({ minHeight: buildSizeValue(v.value, unit) })}
                        options={SIZE_UNITS}
                      />
                    </div>
                  </Form.Item>
                );
              })()}

              {/* 最大高度 */}
              {(() => {
                const v = parseSizeValue(selectedField.maxHeight);
                return (
                  <Form.Item label="最大高度" style={{ marginBottom: '6px' }}>
                    <div style={{ display: 'flex', gap: '4px' }}>
                      <InputNumber
                        data-testid="prop-max-height"
                        style={{ flex: 1, minWidth: 0 }}
                        value={v.value}
                        min={0}
                        controls={false}
                        onChange={val => onFieldUpdate({ maxHeight: buildSizeValue(val ?? undefined, v.unit === 'auto' ? 'px' : v.unit) })}
                        placeholder="数值"
                      />
                      <Select
                        data-testid="prop-max-height-unit"
                        style={{ width: '60px' }}
                        value={v.unit}
                        onChange={unit => onFieldUpdate({ maxHeight: buildSizeValue(v.value, unit) })}
                        options={SIZE_UNITS}
                      />
                    </div>
                  </Form.Item>
                );
              })()}
            </div>

            {/* 尺寸快捷设置 */}
            <div style={{ marginTop: '4px' }}>
              <div style={{ fontSize: '10px', color: '#999', marginBottom: '4px' }}>
                快捷尺寸
              </div>
              <div style={{ display: 'flex', gap: '4px', flexWrap: 'wrap' }}>
                {['100%', '50%', 'auto', '200px', '100px'].map(val => (
                  <Button
                    key={val}
                    size="small"
                    type={selectedField.width === val ? 'primary' : 'default'}
                    onClick={() => onFieldUpdate({ width: val })}
                    style={{ fontSize: '10px', padding: '0 6px', height: '22px' }}
                  >
                    {val}
                  </Button>
                ))}
              </div>
            </div>
          </Form>
        </Panel>

        {/* === CSS 布局配置（仅容器组件） === */}
        {isContainer && (
          <Panel
            header={<span style={{ fontSize: '12px' }}>🎨 CSS 布局</span>}
            key="layout"
          >
            <Form layout="vertical" size="small">
              {/* 布局模式 */}
              <Form.Item label="布局模式" style={{ marginBottom: '8px' }}>
                <Select
                  data-testid="prop-display"
                  value={selectedField.display || 'block'}
                  onChange={val => onFieldUpdate({ display: val as Field['display'] })}
                >
                  <Select.Option value="block">块级 (block)</Select.Option>
                  <Select.Option value="inline-block">行内块 (inline-block)</Select.Option>
                  <Select.Option value="flex">弹性盒子 (flex)</Select.Option>
                  <Select.Option value="grid">网格 (grid)</Select.Option>
                </Select>
              </Form.Item>

              {/* Flex 专属 */}
              {selectedField.display === 'flex' && (
                <>
                  <Form.Item label="主轴方向" style={{ marginBottom: '8px' }}>
                    <Select
                      data-testid="prop-flex-direction"
                      value={selectedField.flexDirection || 'row'}
                      onChange={val => onFieldUpdate({ flexDirection: val as Field['flexDirection'] })}
                    >
                      <Select.Option value="row">水平 (row)</Select.Option>
                      <Select.Option value="row-reverse">水平反转 (row-reverse)</Select.Option>
                      <Select.Option value="column">垂直 (column)</Select.Option>
                      <Select.Option value="column-reverse">垂直反转 (column-reverse)</Select.Option>
                    </Select>
                  </Form.Item>

                  <Form.Item label="主轴对齐" style={{ marginBottom: '8px' }}>
                    <Select
                      data-testid="prop-justify-content"
                      value={selectedField.justifyContent || 'flex-start'}
                      onChange={val => onFieldUpdate({ justifyContent: val as Field['justifyContent'] })}
                    >
                      <Select.Option value="flex-start">起点</Select.Option>
                      <Select.Option value="center">居中</Select.Option>
                      <Select.Option value="flex-end">终点</Select.Option>
                      <Select.Option value="space-between">两端对齐</Select.Option>
                      <Select.Option value="space-around">环绕</Select.Option>
                      <Select.Option value="space-evenly">等距</Select.Option>
                    </Select>
                  </Form.Item>

                  <Form.Item label="交叉轴对齐" style={{ marginBottom: '8px' }}>
                    <Select
                      data-testid="prop-align-items"
                      value={selectedField.alignItems || 'stretch'}
                      onChange={val => onFieldUpdate({ alignItems: val as Field['alignItems'] })}
                    >
                      <Select.Option value="stretch">拉伸</Select.Option>
                      <Select.Option value="flex-start">起点</Select.Option>
                      <Select.Option value="center">居中</Select.Option>
                      <Select.Option value="flex-end">终点</Select.Option>
                      <Select.Option value="baseline">基线</Select.Option>
                    </Select>
                  </Form.Item>

                  <Form.Item label="换行" style={{ marginBottom: '8px' }}>
                    <Select
                      data-testid="prop-flex-wrap"
                      value={selectedField.flexWrap || 'nowrap'}
                      onChange={val => onFieldUpdate({ flexWrap: val as Field['flexWrap'] })}
                    >
                      <Select.Option value="nowrap">不换行</Select.Option>
                      <Select.Option value="wrap">换行</Select.Option>
                      <Select.Option value="wrap-reverse">反向换行</Select.Option>
                    </Select>
                  </Form.Item>

                  <Form.Item label="间距 (gap)" style={{ marginBottom: '8px' }}>
                    <Input
                      data-testid="prop-gap"
                      value={selectedField.gap}
                      onChange={e => onFieldUpdate({ gap: e.target.value })}
                      placeholder="如: 8px, 1rem, 4px 8px"
                    />
                  </Form.Item>
                </>
              )}

              {/* Grid 专属 */}
              {selectedField.display === 'grid' && (
                <>
                  <Form.Item label="列定义" style={{ marginBottom: '8px' }}>
                    <Input
                      data-testid="prop-grid-template-columns"
                      value={selectedField.gridTemplateColumns}
                      onChange={e => onFieldUpdate({ gridTemplateColumns: e.target.value })}
                      placeholder="如: 1fr 1fr, repeat(3, 1fr)"
                    />
                  </Form.Item>

                  <Form.Item label="行定义" style={{ marginBottom: '8px' }}>
                    <Input
                      data-testid="prop-grid-template-rows"
                      value={selectedField.gridTemplateRows}
                      onChange={e => onFieldUpdate({ gridTemplateRows: e.target.value })}
                      placeholder="如: auto 1fr auto"
                    />
                  </Form.Item>

                  <Form.Item label="网格间距" style={{ marginBottom: '8px' }}>
                    <Input
                      data-testid="prop-grid-gap"
                      value={selectedField.gridGap}
                      onChange={e => onFieldUpdate({ gridGap: e.target.value })}
                      placeholder="如: 16px, 8px 12px"
                    />
                  </Form.Item>
                </>
              )}

              {/* 通用布局 */}
              <Form.Item label="内边距" style={{ marginBottom: '8px' }}>
                <Input
                  data-testid="prop-padding"
                  value={selectedField.padding}
                  onChange={e => onFieldUpdate({ padding: e.target.value })}
                  placeholder="如: 16px, 8px 16px"
                />
              </Form.Item>

              <Form.Item label="外边距" style={{ marginBottom: '8px' }}>
                <Input
                  data-testid="prop-margin"
                  value={selectedField.margin}
                  onChange={e => onFieldUpdate({ margin: e.target.value })}
                  placeholder="如: 0 auto, 16px 0"
                />
              </Form.Item>

              {/* 旧版子组件布局（兼容）- display 为空或 block 时显示 */}
              {(!selectedField.display || selectedField.display === 'block') && (
                <Form.Item label="子组件布局" style={{ marginBottom: '8px' }}>
                  <Select
                    data-testid="prop-child-layout"
                    value={selectedField.childLayout || 'vertical'}
                    onChange={val => onFieldUpdate({ childLayout: val as Field['childLayout'] })}
                  >
                    <Select.Option value="vertical">垂直排列</Select.Option>
                    <Select.Option value="horizontal">水平排列</Select.Option>
                    <Select.Option value="grid">网格布局</Select.Option>
                  </Select>
                </Form.Item>
              )}

              {selectedField.childLayout === 'grid' && (
                <>
                  <Form.Item label="列数" style={{ marginBottom: '8px' }}>
                    <Select
                      data-testid="prop-grid-columns"
                      value={selectedField.gridColumns || 2}
                      onChange={val => onFieldUpdate({ gridColumns: val })}
                    >
                      <Select.Option value={1}>1列</Select.Option>
                      <Select.Option value={2}>2列</Select.Option>
                      <Select.Option value={3}>3列</Select.Option>
                      <Select.Option value={4}>4列</Select.Option>
                    </Select>
                  </Form.Item>
                </>
              )}
            </Form>
          </Panel>
        )}

        {/* === 校验规则 === */}
        <Panel
          header={<span style={{ fontSize: '12px' }}>✅ 校验规则</span>}
          key="validation"
        >
          <Form layout="vertical" size="small">
            <Form.Item label="最小长度" style={{ marginBottom: '8px' }}>
              <Input
                data-testid="prop-min-length"
                type="number"
                value={selectedField.minLength}
                onChange={e => onFieldUpdate({ minLength: parseInt(e.target.value) || undefined })}
                placeholder="最小字符数"
              />
            </Form.Item>

            <Form.Item label="最大长度" style={{ marginBottom: '8px' }}>
              <Input
                data-testid="prop-max-length"
                type="number"
                value={selectedField.maxLength}
                onChange={e => onFieldUpdate({ maxLength: parseInt(e.target.value) || undefined })}
                placeholder="最大字符数"
              />
            </Form.Item>

            <Form.Item label="正则表达式" style={{ marginBottom: '8px' }}>
              <Input
                data-testid="prop-pattern"
                value={selectedField.pattern}
                onChange={e => onFieldUpdate({ pattern: e.target.value })}
                placeholder="如: ^[a-zA-Z]+$"
              />
            </Form.Item>

            <Form.Item label="错误提示" style={{ marginBottom: '8px' }}>
              <Input
                data-testid="prop-error-message"
                value={selectedField.errorMessage}
                onChange={e => onFieldUpdate({ errorMessage: e.target.value })}
                placeholder="校验失败时的提示"
              />
            </Form.Item>
          </Form>
        </Panel>

        {/* === 高级配置 === */}
        <Panel
          header={<span style={{ fontSize: '12px' }}>⚙️ 高级配置</span>}
          key="advanced"
        >
          <Form layout="vertical" size="small">
            <Form.Item label="计算表达式" style={{ marginBottom: '8px' }}>
              <Input
                data-testid="prop-formula"
                value={selectedField.formula}
                onChange={e => onFieldUpdate({ formula: e.target.value })}
                placeholder="如: ${price * quantity}"
              />
            </Form.Item>

            <Form.Item label="多选" style={{ marginBottom: '8px' }}>
              <Switch
                data-testid="prop-multiple"
                size="small"
                checked={selectedField.multiple}
                onChange={val => onFieldUpdate({ multiple: val })}
              />
            </Form.Item>
          </Form>
        </Panel>
      </Collapse>

      {/* 底部操作 */}
      <div style={{ marginTop: '12px', display: 'flex', gap: '8px' }}>
        {onFieldDuplicate && (
          <Button
            data-testid="prop-duplicate-button"
            size="small"
            onClick={onFieldDuplicate}
            style={{ flex: 1 }}
          >
            📋 复制
          </Button>
        )}
        {onFieldDelete && (
          <Button
            data-testid="prop-delete-button"
            danger
            size="small"
            icon={<DeleteOutlined />}
            onClick={onFieldDelete}
            style={{ flex: 1 }}
          >
            删除
          </Button>
        )}
      </div>
    </div>
  );
};
