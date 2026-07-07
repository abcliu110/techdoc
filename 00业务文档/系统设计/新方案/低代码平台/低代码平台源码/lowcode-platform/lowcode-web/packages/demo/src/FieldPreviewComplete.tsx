import React from 'react';
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
} from 'antd';
import { PlusOutlined, InboxOutlined } from '@ant-design/icons';

const { RangePicker } = DatePicker;
const { TextArea } = Input;
const { Panel } = Collapse;

export const FieldPreviewComplete: React.FC<{ field: any }> = ({ field }) => {
  const renderField = () => {
    const commonProps = {
      placeholder: field.placeholder || `请输入${field.label}`,
      disabled: field.disabled,
      readOnly: field.readonly,
    };

    switch (field.type) {
      // 基础组件 P0
      case 'input':
        return <Input {...commonProps} />;

      case 'inputNumber':
        return <InputNumber style={{ width: '100%' }} {...commonProps} />;

      case 'select':
        return (
          <Select {...commonProps}>
            <Select.Option value="1">选项1</Select.Option>
            <Select.Option value="2">选项2</Select.Option>
            <Select.Option value="3">选项3</Select.Option>
          </Select>
        );

      case 'datePicker':
        return <DatePicker style={{ width: '100%' }} {...commonProps} />;

      case 'checkbox':
        return <Checkbox disabled={field.disabled}>{field.label}</Checkbox>;

      case 'radio':
        return (
          <Radio.Group disabled={field.disabled}>
            <Radio value="1">选项1</Radio>
            <Radio value="2">选项2</Radio>
            <Radio value="3">选项3</Radio>
          </Radio.Group>
        );

      case 'switch':
        return <Switch disabled={field.disabled} />;

      case 'button':
        return <Button type="primary" disabled={field.disabled}>{field.label || '按钮'}</Button>;

      // 重要组件 P1
      case 'textarea':
        return <TextArea rows={3} {...commonProps} />;

      case 'upload':
        return (
          <Upload {...commonProps}>
            <Button icon={<PlusOutlined />} disabled={field.disabled}>
              {field.label || '点击上传'}
            </Button>
          </Upload>
        );

      case 'cascader':
        return (
          <Cascader
            style={{ width: '100%' }}
            options={[
              {
                value: '1',
                label: '选项1',
                children: [
                  { value: '1-1', label: '选项1-1' },
                  { value: '1-2', label: '选项1-2' },
                ],
              },
              { value: '2', label: '选项2' },
            ]}
            {...commonProps}
          />
        );

      case 'timePicker':
        return <TimePicker style={{ width: '100%' }} {...commonProps} />;

      case 'rangePicker':
        return <RangePicker style={{ width: '100%' }} disabled={field.disabled} />;

      case 'autoComplete':
        return (
          <AutoComplete
            style={{ width: '100%' }}
            options={[
              { value: '选项1' },
              { value: '选项2' },
              { value: '选项3' },
            ]}
            {...commonProps}
          />
        );

      case 'rate':
        return <Rate disabled={field.disabled} />;

      case 'tag':
        return (
          <div>
            <AntTag color="blue">标签1</AntTag>
            <AntTag color="green">标签2</AntTag>
            <AntTag color="red">标签3</AntTag>
          </div>
        );

      // 布局组件
      case 'card':
        return (
          <Card
            title={field.label || '卡片标题'}
            size="small"
            style={{ background: '#fafafa' }}
          >
            <div style={{ padding: '12px', color: '#666' }}>
              卡片内容区域 - 可嵌套其他组件
            </div>
          </Card>
        );

      case 'tabs':
        return (
          <Tabs
            items={[
              {
                key: '1',
                label: '选项卡1',
                children: <div style={{ padding: '12px', color: '#666' }}>选项卡1内容</div>,
              },
              {
                key: '2',
                label: '选项卡2',
                children: <div style={{ padding: '12px', color: '#666' }}>选项卡2内容</div>,
              },
            ]}
          />
        );

      case 'collapse':
        return (
          <Collapse>
            <Panel header="折叠面板1" key="1">
              <div style={{ color: '#666' }}>折叠面板内容</div>
            </Panel>
            <Panel header="折叠面板2" key="2">
              <div style={{ color: '#666' }}>折叠面板内容</div>
            </Panel>
          </Collapse>
        );

      case 'divider':
        return <Divider>{field.label || '分割线'}</Divider>;

      // 高级组件 P2
      case 'subTable':
        return (
          <div style={{ border: '1px dashed #d9d9d9', padding: '12px', borderRadius: '4px', background: '#fafafa' }}>
            <div style={{ marginBottom: '8px', color: '#666', fontWeight: 'bold' }}>
              📋 子表组件（主子表关系）
            </div>
            <div style={{ fontSize: '12px', color: '#999', marginBottom: '8px' }}>
              支持一对多关系，自动计算、行内校验
            </div>
            <Button size="small" type="dashed" icon={<PlusOutlined />} disabled={field.disabled}>
              添加行
            </Button>
          </div>
        );

      case 'richText':
        return (
          <div style={{ border: '1px solid #d9d9d9', borderRadius: '4px', minHeight: '120px', padding: '8px', background: 'white' }}>
            <div style={{ color: '#999', fontSize: '12px' }}>
              📝 富文本编辑器 - 支持格式化文本、图片、链接等
            </div>
          </div>
        );

      case 'tree':
        return (
          <TreeSelect
            style={{ width: '100%' }}
            treeData={[
              {
                title: '节点1',
                value: '1',
                children: [
                  { title: '子节点1-1', value: '1-1' },
                  { title: '子节点1-2', value: '1-2' },
                ],
              },
              { title: '节点2', value: '2' },
            ]}
            {...commonProps}
          />
        );

      case 'transfer':
        return (
          <Transfer
            dataSource={[
              { key: '1', title: '选项1' },
              { key: '2', title: '选项2' },
              { key: '3', title: '选项3' },
            ]}
            targetKeys={[]}
            render={item => item.title}
            disabled={field.disabled}
          />
        );

      case 'slider':
        return <Slider disabled={field.disabled} />;

      case 'colorPicker':
        return (
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <div style={{
              width: '40px',
              height: '40px',
              background: '#1890ff',
              border: '1px solid #d9d9d9',
              borderRadius: '4px',
              cursor: field.disabled ? 'not-allowed' : 'pointer',
            }} />
            <span style={{ color: '#666' }}>#1890ff</span>
          </div>
        );

      case 'calendar':
        return (
          <div style={{ border: '1px solid #d9d9d9', borderRadius: '4px', padding: '8px', background: '#fafafa' }}>
            <div style={{ color: '#666', textAlign: 'center' }}>
              📆 日历组件 - 日期选择和展示
            </div>
          </div>
        );

      default:
        return <Input {...commonProps} />;
    }
  };

  // 布局组件不需要Form.Item包裹
  if (['card', 'tabs', 'collapse', 'divider'].includes(field.type)) {
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
