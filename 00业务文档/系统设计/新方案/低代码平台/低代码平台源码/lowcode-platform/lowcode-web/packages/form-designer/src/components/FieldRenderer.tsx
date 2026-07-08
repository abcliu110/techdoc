/**
 * 表单设计器字段渲染器
 * 渲染 29 种组件的预览态，支持完整 CSS 布局配置
 */

import React, { useState } from 'react';
import { useDroppable } from '@dnd-kit/core';
import {
  Form,
  Input,
  InputNumber,
  Select,
  DatePicker,
  TimePicker,
  Checkbox,
  Radio,
  Switch,
  Upload,
  Button,
  Rate,
  Slider,
  Card,
  Tabs,
  Collapse,
  Divider,
  Tag as AntTag,
  Cascader,
  AutoComplete,
  TreeSelect,
  Transfer,
  Table,
  Calendar as AntCalendar,
} from 'antd';
import { PlusOutlined, UploadOutlined, DeleteOutlined } from '@ant-design/icons';
import { SketchPicker } from 'react-color';
import type { DesignerFieldData, ElementCategory } from '../types';

const { RangePicker } = DatePicker;
const { TextArea } = Input;
const { Panel } = Collapse;
const { Dragger } = Upload;

/** 容器组件的空 drop-zone，注册为可放置目标 */
function CardDropZone({ fieldId, type }: { fieldId: string; type: string }) {
  const droppableId = `drop-zone-${fieldId}`;
  const { setNodeRef, isOver } = useDroppable({ id: droppableId });
  return (
    <div
      ref={setNodeRef}
      data-testid={`drop-zone-${type}`}
      data-node-id={fieldId}
      style={{
        padding: '20px',
        textAlign: 'center',
        color: '#999',
        background: isOver ? '#e6f7ff' : 'white',
        border: isOver ? '2px dashed #1890ff' : '1px dashed #d9d9d9',
        borderRadius: '4px',
        transition: 'all 0.2s',
      }}
    >
      📦 拖拽组件到这里
    </div>
  );
}

interface FieldRendererProps {
  field: DesignerFieldData;
  children?: React.ReactNode;
  isDesignMode?: boolean;
}

/**
 * 判断组件是否需要Form.Item包裹
 * 布局组件和展示组件不需要
 */
const isLayoutOrDisplayComponent = (type: string): boolean => {
  return ['card', 'tabs', 'collapse', 'divider', 'tag', 'calendar', 'subTable', 'richText'].includes(type);
};

/**
 * 获取子组件布局样式
 * 遵循 W3C CSS 布局规范，支持 flex/grid/block
 */
export function getChildrenLayoutStyle(field: DesignerFieldData): React.CSSProperties {
  // 优先使用 display 属性（完整 CSS 布局）
  if (field.display) {
    const style: React.CSSProperties = {
      display: field.display,
      padding: field.padding || undefined,
      margin: field.margin || undefined,
    };

    if (field.display === 'flex') {
      style.flexDirection = field.flexDirection || 'column';
      style.justifyContent = field.justifyContent || 'flex-start';
      style.alignItems = field.alignItems || 'stretch';
      style.alignContent = field.alignContent || undefined;
      style.flexWrap = field.flexWrap || 'nowrap';
      style.gap = field.gap || '8px';
    }

    if (field.display === 'grid') {
      style.gridTemplateColumns = field.gridTemplateColumns || `repeat(${field.gridColumns || 2}, 1fr)`;
      style.gridTemplateRows = field.gridTemplateRows || undefined;
      style.gridGap = field.gridGap || field.gap || '8px';
    }

    return style;
  }

  // 兼容旧版 childLayout 配置
  if (field.childLayout === 'horizontal') {
    return {
      display: 'flex',
      flexDirection: 'row',
      gap: field.gap || '12px',
      flexWrap: 'wrap',
      padding: field.padding || undefined,
      margin: field.margin || undefined,
    };
  }

  if (field.childLayout === 'grid') {
    return {
      display: 'grid',
      gridTemplateColumns: `repeat(${field.gridColumns || 2}, 1fr)`,
      gap: field.gridGap || field.gap || '12px',
      padding: field.padding || undefined,
      margin: field.margin || undefined,
    };
  }

  // 默认垂直排列
  return {
    display: 'flex',
    flexDirection: 'column',
    gap: field.gap || '12px',
    padding: field.padding || undefined,
    margin: field.margin || undefined,
  };
}

/**
 * 获取字段的宽高样式
 * 支持完整 CSS 单位（px, %, rem, em, vw, vh, auto 等）
 */
export function getFieldSizeStyle(field: DesignerFieldData): React.CSSProperties {
  const style: React.CSSProperties = {};

  if (field.width !== undefined && field.width !== '') {
    style.width = field.width;
  }
  if (field.height !== undefined && field.height !== '') {
    style.height = field.height;
  }
  if (field.minWidth !== undefined && field.minWidth !== '') {
    style.minWidth = field.minWidth;
  }
  if (field.maxWidth !== undefined && field.maxWidth !== '') {
    style.maxWidth = field.maxWidth;
  }
  if (field.minHeight !== undefined && field.minHeight !== '') {
    style.minHeight = field.minHeight;
  }
  if (field.maxHeight !== undefined && field.maxHeight !== '') {
    style.maxHeight = field.maxHeight;
  }

  return style;
}

export const FieldRenderer: React.FC<FieldRendererProps> = ({
  field,
  children,
  isDesignMode = false,
}) => {
  const [activeTab, setActiveTab] = useState('1');
  const [colorPickerVisible, setColorPickerVisible] = useState(false);
  const [color, setColor] = useState<string>((field.defaultValue as string) || '#1890ff');
  const [subTableData, setSubTableData] = useState([
    { key: '1', product: '产品A', qty: 10, price: 100, amount: 1000 },
  ]);

  const subTableColumns = [
    { title: '产品', dataIndex: 'product', key: 'product' },
    { title: '数量', dataIndex: 'qty', key: 'qty' },
    { title: '单价', dataIndex: 'price', key: 'price' },
    { title: '金额', dataIndex: 'amount', key: 'amount' },
  ];

  const sizeStyle = getFieldSizeStyle(field);
  const containerStyle: React.CSSProperties = {
    padding: field.padding || undefined,
    margin: field.margin || undefined,
  };

  // 默认选项数据
  const defaultOptions = field.options?.length
    ? field.options
    : [
        { label: '选项1', value: '1' },
        { label: '选项2', value: '2' },
        { label: '选项3', value: '3' },
      ];

  // 默认树形数据
  const defaultTreeData = field.treeData?.length
    ? field.treeData
    : [
        { label: '节点1', value: '1', children: [
          { label: '子节点1-1', value: '1-1' },
          { label: '子节点1-2', value: '1-2' },
        ]},
        { label: '节点2', value: '2' },
      ];

  const commonProps = {
    disabled: field.disabled,
    readOnly: field.readonly,
  };

  const renderField = () => {
    switch (field.type) {
      // ========== 基础组件 ==========
      case 'input':
        return <Input {...commonProps} placeholder={field.placeholder} defaultValue={field.defaultValue as string} style={sizeStyle} />;

      case 'inputNumber':
        return (
          <InputNumber
            style={sizeStyle}
            {...commonProps}
            defaultValue={field.defaultValue as number}
          />
        );

      case 'select':
        return (
          <Select
            mode={field.multiple ? 'multiple' : undefined}
            {...commonProps}
            defaultValue={field.multiple ? (field.defaultValue as string[]) : (field.defaultValue as string)}
            style={sizeStyle}
          >
            {defaultOptions.map(opt => (
              <Select.Option key={opt.value} value={opt.value}>
                {opt.label}
              </Select.Option>
            ))}
          </Select>
        );

      case 'datePicker':
        return <DatePicker placeholder={field.placeholder || '请选择日期'} style={sizeStyle} {...commonProps} />;

      case 'checkbox':
        if (defaultOptions.length > 1) {
          return (
            <Checkbox.Group
              disabled={field.disabled}
              options={defaultOptions.map(opt => ({ label: opt.label, value: opt.value }))}
            />
          );
        }
        return <Checkbox disabled={field.disabled}>{field.label}</Checkbox>;

      case 'radio':
        return (
          <Radio.Group disabled={field.disabled} defaultValue={field.defaultValue}>
            {defaultOptions.map(opt => (
              <Radio key={opt.value} value={opt.value}>
                {opt.label}
              </Radio>
            ))}
          </Radio.Group>
        );

      case 'switch':
        return <Switch disabled={field.disabled} defaultChecked={field.defaultValue as boolean} />;

      case 'button':
        return (
          <Button
            type="primary"
            disabled={field.disabled}
            style={sizeStyle}
          >
            {field.label || '按钮'}
          </Button>
        );

      case 'textarea':
        return (
          <TextArea
            rows={3}
            {...commonProps}
            placeholder={field.placeholder}
            defaultValue={field.defaultValue as string}
            style={sizeStyle}
          />
        );

      // ========== 高级组件 ==========
      case 'upload':
        return (
          <Upload {...commonProps} action="/api/upload" listType="text">
            <Button icon={<UploadOutlined />} disabled={field.disabled} style={sizeStyle}>
              {field.label || '点击上传'}
            </Button>
          </Upload>
        );

      case 'cascader':
        return (
          <Cascader
            style={sizeStyle}
            options={defaultTreeData}
            {...commonProps}
          />
        );

      case 'timePicker':
        return <TimePicker placeholder={field.placeholder || '请选择时间'} style={sizeStyle} {...commonProps} />;

      case 'rangePicker':
        return <RangePicker placeholder={[field.placeholder || '开始日期', field.placeholder || '结束日期']} style={sizeStyle} disabled={field.disabled} />;

      case 'autoComplete':
        return (
          <AutoComplete
            style={sizeStyle}
            options={defaultOptions.map(opt => ({ value: opt.label }))}
            {...commonProps}
          />
        );

      case 'rate':
        return <Rate disabled={field.disabled} defaultValue={(field.defaultValue as number) || 0} />;

      case 'subTable':
        return (
          <div style={{ border: '1px solid #d9d9d9', borderRadius: '4px', padding: '12px', background: 'white', ...sizeStyle }}>
            <Table size="small" dataSource={subTableData} columns={subTableColumns} pagination={false} />
            <Button
              size="small"
              type="dashed"
              icon={<PlusOutlined />}
              disabled={field.disabled}
              onClick={() => {
                const newKey = `${subTableData.length + 1}`;
                setSubTableData([...subTableData, {
                  key: newKey,
                  product: '新产品',
                  qty: 1,
                  price: 0,
                  amount: 0,
                }]);
              }}
              style={{ marginTop: '8px', width: '100%' }}
            >
              添加行
            </Button>
          </div>
        );

      case 'richText':
        return (
          <div style={{ border: '1px solid #d9d9d9', borderRadius: '4px', minHeight: '120px', padding: '8px', background: 'white', ...sizeStyle }}>
            <div style={{ borderBottom: '1px solid #f0f0f0', paddingBottom: '8px', marginBottom: '8px' }}>
              <Button size="small" type="text">B</Button>
              <Button size="small" type="text"><i>I</i></Button>
              <Button size="small" type="text"><u>U</u></Button>
              <Button size="small" type="text">链接</Button>
              <Button size="small" type="text">图片</Button>
            </div>
            <TextArea
              bordered={false}
              placeholder="请输入内容..."
              rows={4}
              disabled={field.disabled}
              style={{ width: '100%' }}
            />
          </div>
        );

      case 'tree':
        return (
          <TreeSelect
            style={sizeStyle}
            treeData={defaultTreeData}
            {...commonProps}
          />
        );

      case 'transfer':
        return (
          <Transfer
            dataSource={defaultOptions.map(opt => ({ key: opt.value, title: opt.label }))}
            targetKeys={[]}
            render={item => (item as { title: string }).title}
            disabled={field.disabled}
            style={sizeStyle}
          />
        );

      case 'slider':
        return <Slider disabled={field.disabled} defaultValue={(field.defaultValue as number) || 30} style={sizeStyle} />;

      case 'colorPicker':
        return (
          <div style={{ position: 'relative' }}>
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '8px',
                cursor: field.disabled ? 'not-allowed' : 'pointer',
                ...sizeStyle,
              }}
              onClick={() => !field.disabled && setColorPickerVisible(!colorPickerVisible)}
            >
              <div
                data-testid={`color-preview-${field.id}`}
                style={{
                  width: '40px',
                  height: '40px',
                  background: color,
                  border: '1px solid #d9d9d9',
                  borderRadius: '4px',
                }}
              />
              <span style={{ color: '#666' }}>{color}</span>
            </div>
            {colorPickerVisible && (
              <div style={{ position: 'absolute', zIndex: 1000, top: '50px' }}>
                <SketchPicker
                  color={color}
                  onChange={(c) => setColor(c.hex)}
                  onChangeComplete={() => setColorPickerVisible(false)}
                />
              </div>
            )}
          </div>
        );

      // ========== 布局组件 ==========
      case 'card':
        return (
          <Card
            title={field.label || '卡片标题'}
            size="small"
            style={{ background: '#fafafa', ...containerStyle }}
          >
            {field.children && field.children.length > 0 ? (
              <div style={{ minHeight: '60px', ...getChildrenLayoutStyle(field) }}>
                {field.children.map(child => (
                  <FieldRenderer key={child.id} field={child} />
                ))}
              </div>
            ) : (
              <CardDropZone fieldId={field.id} type="card" />
            )}
          </Card>
        );

      case 'tabs': {
        const childCount = field.children?.length;
        return (
          <Tabs
            activeKey={activeTab}
            onChange={setActiveTab}
            items={[
              {
                key: '1',
                label: '选项卡1',
                children: childCount && childCount > 0 ? (
                  <div style={{ padding: '12px', minHeight: '60px', ...getChildrenLayoutStyle(field) }}>
                    {field.children!.map(child => (
                      <FieldRenderer key={child.id} field={child} />
                    ))}
                  </div>
                ) : (
                  <CardDropZone fieldId={field.id} type="tabs" />
                ),
              },
              {
                key: '2',
                label: '选项卡2',
                children: <div style={{ padding: '12px', color: '#666' }}>选项卡2内容</div>,
              },
              {
                key: '3',
                label: '选项卡3',
                children: <div style={{ padding: '12px', color: '#666' }}>选项卡3内容</div>,
              },
            ]}
          />
        );
      }

      case 'collapse': {
        const childCount = field.children?.length;
        return (
          <Collapse defaultActiveKey={['1']}>
            <Panel header={field.label || '折叠面板1'} key="1">
              {childCount && childCount > 0 ? (
                <div style={{ minHeight: '40px', ...getChildrenLayoutStyle(field) }}>
                  {field.children!.map(child => (
                    <FieldRenderer key={child.id} field={child} />
                  ))}
                </div>
              ) : (
                <CardDropZone fieldId={field.id} type="collapse" />
              )}
            </Panel>
            <Panel header="折叠面板2" key="2">
              <div style={{ color: '#666' }}>折叠面板2内容</div>
            </Panel>
          </Collapse>
        );
      }

      // ========== 展示组件 ==========
      case 'tag':
        return (
          <div>
            {defaultOptions.map((opt, idx) => (
              <AntTag key={opt.value} color={['blue', 'green', 'red', 'orange'][idx % 4] as 'blue' | 'green' | 'red' | 'orange'}>
                {opt.label}
              </AntTag>
            ))}
          </div>
        );

      case 'divider':
        return <Divider>{field.label || '分割线'}</Divider>;

      case 'calendar':
        return (
          <div style={{ border: '1px solid #d9d9d9', borderRadius: '4px', background: 'white' }}>
            <AntCalendar fullscreen={false} />
          </div>
        );

      default:
        return <Input {...commonProps} />;
    }
  };

  // 布局/展示组件不需要 Form.Item 包裹
  if (isLayoutOrDisplayComponent(field.type)) {
    return <div style={{ margin: '16px 0' }}>{renderField()}</div>;
  }

  return (
    <Form.Item
      label={field.label}
      required={field.required}
      help={field.helpText}
    >
      {renderField()}
    </Form.Item>
  );
};
