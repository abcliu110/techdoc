import React, { useState } from 'react';
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

const { RangePicker } = DatePicker;
const { TextArea } = Input;
const { Panel } = Collapse;
const { Dragger } = Upload;

interface FieldPreviewProps {
  field: any;
  children?: React.ReactNode;
  isDesignMode?: boolean;
}

export const FieldPreviewComplete: React.FC<FieldPreviewProps> = ({
  field,
  children,
  isDesignMode = false
}) => {
  const [activeTab, setActiveTab] = useState('1');
  const [colorPickerVisible, setColorPickerVisible] = useState(false);
  const [color, setColor] = useState(field.defaultValue || '#1890ff');
  const [subTableData, setSubTableData] = useState([
    { key: '1', product: '产品A', qty: 10, price: 100, amount: 1000 },
  ]);

  const renderField = () => {
    const commonProps = {
      placeholder: field.placeholder || `请输入${field.label}`,
      disabled: field.disabled,
      readOnly: field.readonly,
    };

    // 获取选项（从配置或默认）
    const options = field.options || [
      { label: '选项1', value: '1' },
      { label: '选项2', value: '2' },
      { label: '选项3', value: '3' },
    ];

    // 获取树形数据
    const treeData = field.treeData || [
      {
        title: '节点1',
        value: '1',
        children: [
          { title: '子节点1-1', value: '1-1' },
          { title: '子节点1-2', value: '1-2' },
        ],
      },
      { title: '节点2', value: '2' },
    ];

    switch (field.type) {
      // 基础组件 P0
      case 'input':
        return <Input {...commonProps} defaultValue={field.defaultValue} />;

      case 'inputNumber':
        return <InputNumber style={{ width: '100%' }} {...commonProps} defaultValue={field.defaultValue} />;

      case 'select':
        return (
          <Select {...commonProps} defaultValue={field.defaultValue}>
            {options.map((opt: any) => (
              <Select.Option key={opt.value} value={opt.value}>
                {opt.label}
              </Select.Option>
            ))}
          </Select>
        );

      case 'datePicker':
        return <DatePicker style={{ width: '100%' }} {...commonProps} />;

      case 'checkbox':
        if (options.length > 1) {
          // 多个选项显示为CheckboxGroup
          return (
            <Checkbox.Group disabled={field.disabled} options={options.map((opt: any) => ({
              label: opt.label,
              value: opt.value,
            }))} />
          );
        }
        return <Checkbox disabled={field.disabled}>{field.label}</Checkbox>;

      case 'radio':
        return (
          <Radio.Group disabled={field.disabled} defaultValue={field.defaultValue}>
            {options.map((opt: any) => (
              <Radio key={opt.value} value={opt.value}>
                {opt.label}
              </Radio>
            ))}
          </Radio.Group>
        );

      case 'switch':
        return <Switch disabled={field.disabled} defaultChecked={field.defaultValue} />;

      case 'button':
        return <Button type="primary" disabled={field.disabled}>{field.label || '按钮'}</Button>;

      // 重要组件 P1
      case 'textarea':
        return <TextArea rows={3} {...commonProps} defaultValue={field.defaultValue} />;

      case 'upload':
        return (
          <Upload {...commonProps} action="/api/upload" listType="text">
            <Button icon={<UploadOutlined />} disabled={field.disabled}>
              {field.label || '点击上传'}
            </Button>
          </Upload>
        );

      case 'cascader':
        return (
          <Cascader
            style={{ width: '100%' }}
            options={treeData}
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
            options={options.map((opt: any) => ({ value: opt.label }))}
            {...commonProps}
          />
        );

      case 'rate':
        return <Rate disabled={field.disabled} defaultValue={field.defaultValue || 0} />;

      case 'tag':
        return (
          <div>
            {options.map((opt: any, idx: number) => (
              <AntTag key={opt.value} color={['blue', 'green', 'red', 'orange'][idx % 4]}>
                {opt.label}
              </AntTag>
            ))}
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
            {children && React.Children.count(children) > 0 ? (
              <div style={{ minHeight: '60px' }}>{children}</div>
            ) : (
              <div style={{
                padding: '20px',
                textAlign: 'center',
                color: '#999',
                background: 'white',
                border: '1px dashed #d9d9d9',
                borderRadius: '4px'
              }}>
                📦 拖拽组件到这里（容器组件）
              </div>
            )}
          </Card>
        );

      case 'tabs':
        return (
          <Tabs
            activeKey={activeTab}
            onChange={setActiveTab}
            items={[
              {
                key: '1',
                label: '选项卡1',
                children: children && React.Children.count(children) > 0 ? (
                  <div style={{ padding: '12px', minHeight: '60px' }}>{children}</div>
                ) : (
                  <div style={{
                    padding: '20px',
                    textAlign: 'center',
                    color: '#999',
                    border: '1px dashed #d9d9d9',
                    borderRadius: '4px'
                  }}>
                    📦 拖拽组件到这里
                  </div>
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

      case 'collapse':
        return (
          <Collapse defaultActiveKey={['1']}>
            <Panel header="折叠面板1" key="1">
              {children && React.Children.count(children) > 0 ? (
                <div style={{ minHeight: '40px' }}>{children}</div>
              ) : (
                <div style={{
                  padding: '12px',
                  textAlign: 'center',
                  color: '#999',
                  border: '1px dashed #d9d9d9',
                  borderRadius: '4px'
                }}>
                  📦 拖拽组件到这里
                </div>
              )}
            </Panel>
            <Panel header="折叠面板2" key="2">
              <div style={{ color: '#666' }}>折叠面板2内容</div>
            </Panel>
          </Collapse>
        );

      case 'divider':
        return <Divider>{field.label || '分割线'}</Divider>;

      // 高级组件 P2
      case 'subTable':
        const columns = [
          {
            title: '产品名称',
            dataIndex: 'product',
            key: 'product',
            render: (text: string, record: any) => (
              <Input size="small" defaultValue={text} disabled={field.disabled} />
            ),
          },
          {
            title: '数量',
            dataIndex: 'qty',
            key: 'qty',
            width: 100,
            render: (text: number, record: any) => (
              <InputNumber size="small" defaultValue={text} disabled={field.disabled} style={{ width: '100%' }} />
            ),
          },
          {
            title: '单价',
            dataIndex: 'price',
            key: 'price',
            width: 100,
            render: (text: number, record: any) => (
              <InputNumber size="small" defaultValue={text} disabled={field.disabled} style={{ width: '100%' }} />
            ),
          },
          {
            title: '金额',
            dataIndex: 'amount',
            key: 'amount',
            width: 100,
          },
          {
            title: '操作',
            key: 'action',
            width: 80,
            render: (_: any, record: any) => (
              <Button
                type="link"
                danger
                size="small"
                icon={<DeleteOutlined />}
                disabled={field.disabled}
                onClick={() => {
                  setSubTableData(subTableData.filter(item => item.key !== record.key));
                }}
              >
                删除
              </Button>
            ),
          },
        ];

        return (
          <div style={{ border: '1px solid #d9d9d9', borderRadius: '4px', padding: '12px', background: 'white' }}>
            <Table
              size="small"
              dataSource={subTableData}
              columns={columns}
              pagination={false}
            />
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
          <div style={{ border: '1px solid #d9d9d9', borderRadius: '4px', minHeight: '120px', padding: '8px', background: 'white' }}>
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
            />
          </div>
        );

      case 'tree':
        return (
          <TreeSelect
            style={{ width: '100%' }}
            treeData={treeData}
            {...commonProps}
          />
        );

      case 'transfer':
        return (
          <Transfer
            dataSource={options.map((opt: any) => ({ key: opt.value, title: opt.label }))}
            targetKeys={[]}
            render={item => item.title}
            disabled={field.disabled}
          />
        );

      case 'slider':
        return <Slider disabled={field.disabled} defaultValue={field.defaultValue || 30} />;

      case 'colorPicker':
        return (
          <div style={{ position: 'relative' }}>
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '8px',
                cursor: field.disabled ? 'not-allowed' : 'pointer',
              }}
              onClick={() => !field.disabled && setColorPickerVisible(!colorPickerVisible)}
            >
              <div style={{
                width: '40px',
                height: '40px',
                background: color,
                border: '1px solid #d9d9d9',
                borderRadius: '4px',
              }} />
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
