import React from 'react';
import { Card, Form, Input, Select, Switch, Collapse, Button, Space } from 'antd';
import { PlusOutlined, MinusCircleOutlined } from '@ant-design/icons';

const { Option } = Select;
const { Panel } = Collapse;
const { TextArea } = Input;

export interface PropertyPanelProps {
  selectedField: any | null;
  onFieldUpdate: (updates: any) => void;
}

export const PropertyPanel: React.FC<PropertyPanelProps> = ({ selectedField, onFieldUpdate }) => {
  if (!selectedField) {
    return (
      <div style={{ padding: '16px', height: '100vh', overflow: 'auto' }}>
        <h3>⚙️ 属性面板</h3>
        <div style={{ marginTop: '40px', textAlign: 'center', color: '#999' }}>
          请在画布中选择一个字段
        </div>
      </div>
    );
  }

  // 添加选项
  const handleAddOption = () => {
    const options = selectedField.options || [];
    onFieldUpdate({
      options: [...options, { label: `选项${options.length + 1}`, value: `${options.length + 1}` }],
    });
  };

  // 删除选项
  const handleRemoveOption = (index: number) => {
    const options = selectedField.options || [];
    onFieldUpdate({
      options: options.filter((_: any, i: number) => i !== index),
    });
  };

  // 更新选项
  const handleUpdateOption = (index: number, field: 'label' | 'value', value: string) => {
    const options = [...(selectedField.options || [])];
    options[index] = { ...options[index], [field]: value };
    onFieldUpdate({ options });
  };

  // 是否需要选项配置
  const needsOptions = ['select', 'radio', 'checkbox', 'autoComplete'].includes(selectedField.type);

  // 是否需要树形数据配置
  const needsTreeData = ['tree', 'cascader'].includes(selectedField.type);

  return (
    <div style={{ padding: '16px', height: '100vh', overflow: 'auto' }}>
      <h3 style={{ marginBottom: '16px' }}>⚙️ 属性面板</h3>

      <Collapse defaultActiveKey={['basic', 'data', 'validation', 'style']} ghost>
        {/* 基础属性 */}
        <Panel header="📝 基础属性" key="basic">
          <Card size="small">
            <Form layout="vertical" size="small">
              <Form.Item label="字段标签">
                <Input
                  value={selectedField.label}
                  onChange={e => onFieldUpdate({ label: e.target.value })}
                  placeholder="请输入字段标签"
                />
              </Form.Item>

              <Form.Item label="字段ID">
                <Input
                  value={selectedField.fieldId}
                  onChange={e => onFieldUpdate({ fieldId: e.target.value })}
                  placeholder="field_id"
                />
              </Form.Item>

              <Form.Item label="组件类型">
                <Select
                  value={selectedField.type}
                  onChange={val => onFieldUpdate({ type: val })}
                >
                  <Option value="input">输入框</Option>
                  <Option value="inputNumber">数字输入</Option>
                  <Option value="select">下拉选择</Option>
                  <Option value="radio">单选框</Option>
                  <Option value="checkbox">复选框</Option>
                  <Option value="datePicker">日期选择</Option>
                  <Option value="textarea">多行文本</Option>
                  <Option value="upload">文件上传</Option>
                  <Option value="subTable">子表</Option>
                </Select>
              </Form.Item>

              <Form.Item label="占位符">
                <Input
                  value={selectedField.placeholder}
                  onChange={e => onFieldUpdate({ placeholder: e.target.value })}
                  placeholder="请输入占位符"
                />
              </Form.Item>
            </Form>
          </Card>
        </Panel>

        {/* 数据配置 */}
        {(needsOptions || needsTreeData) && (
          <Panel header="📋 数据配置" key="data">
            <Card size="small">
              {needsOptions && (
                <div>
                  <div style={{ marginBottom: '8px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <strong>选项列表</strong>
                    <Button size="small" type="dashed" icon={<PlusOutlined />} onClick={handleAddOption}>
                      添加选项
                    </Button>
                  </div>
                  {(selectedField.options || []).map((option: any, index: number) => (
                    <div key={index} style={{ marginBottom: '8px', padding: '8px', background: '#f5f5f5', borderRadius: '4px' }}>
                      <Space direction="vertical" style={{ width: '100%' }} size="small">
                        <Input
                          size="small"
                          placeholder="标签"
                          value={option.label}
                          onChange={e => handleUpdateOption(index, 'label', e.target.value)}
                          addonBefore="标签"
                        />
                        <Input
                          size="small"
                          placeholder="值"
                          value={option.value}
                          onChange={e => handleUpdateOption(index, 'value', e.target.value)}
                          addonBefore="值"
                          addonAfter={
                            <MinusCircleOutlined
                              style={{ color: 'red', cursor: 'pointer' }}
                              onClick={() => handleRemoveOption(index)}
                            />
                          }
                        />
                      </Space>
                    </div>
                  ))}
                  {(!selectedField.options || selectedField.options.length === 0) && (
                    <div style={{ padding: '12px', textAlign: 'center', color: '#999', background: '#fafafa', borderRadius: '4px' }}>
                      暂无选项，点击添加
                    </div>
                  )}
                </div>
              )}

              {needsTreeData && (
                <div>
                  <div style={{ marginBottom: '8px' }}>
                    <strong>树形数据（JSON）</strong>
                  </div>
                  <TextArea
                    rows={6}
                    placeholder='[{"label":"节点1","value":"1","children":[]}]'
                    value={selectedField.treeData ? JSON.stringify(selectedField.treeData, null, 2) : ''}
                    onChange={e => {
                      try {
                        const data = JSON.parse(e.target.value);
                        onFieldUpdate({ treeData: data });
                      } catch (err) {
                        // 忽略JSON解析错误
                      }
                    }}
                  />
                </div>
              )}
            </Card>
          </Panel>
        )}

        {/* 校验规则 */}
        <Panel header="✅ 校验规则" key="validation">
          <Card size="small">
            <Form layout="vertical" size="small">
              <Form.Item label="是否必填">
                <Switch
                  checked={selectedField.required}
                  onChange={val => onFieldUpdate({ required: val })}
                  checkedChildren="必填"
                  unCheckedChildren="非必填"
                />
              </Form.Item>

              <Form.Item label="最小长度">
                <Input
                  type="number"
                  value={selectedField.minLength}
                  onChange={e => onFieldUpdate({ minLength: e.target.value })}
                  placeholder="不限制"
                />
              </Form.Item>

              <Form.Item label="最大长度">
                <Input
                  type="number"
                  value={selectedField.maxLength}
                  onChange={e => onFieldUpdate({ maxLength: e.target.value })}
                  placeholder="不限制"
                />
              </Form.Item>

              <Form.Item label="正则表达式">
                <Input
                  value={selectedField.pattern}
                  onChange={e => onFieldUpdate({ pattern: e.target.value })}
                  placeholder="如: ^[0-9]+$"
                />
              </Form.Item>

              <Form.Item label="错误提示">
                <Input
                  value={selectedField.errorMessage}
                  onChange={e => onFieldUpdate({ errorMessage: e.target.value })}
                  placeholder="校验失败时的提示"
                />
              </Form.Item>
            </Form>
          </Card>
        </Panel>

        {/* 样式配置 */}
        <Panel header="🎨 样式配置" key="style">
          <Card size="small">
            <Form layout="vertical" size="small">
              <Form.Item label="是否禁用">
                <Switch
                  checked={selectedField.disabled}
                  onChange={val => onFieldUpdate({ disabled: val })}
                  checkedChildren="禁用"
                  unCheckedChildren="启用"
                />
              </Form.Item>

              <Form.Item label="是否只读">
                <Switch
                  checked={selectedField.readonly}
                  onChange={val => onFieldUpdate({ readonly: val })}
                  checkedChildren="只读"
                  unCheckedChildren="可编辑"
                />
              </Form.Item>

              <Form.Item label="是否隐藏">
                <Switch
                  checked={selectedField.hidden}
                  onChange={val => onFieldUpdate({ hidden: val })}
                  checkedChildren="隐藏"
                  unCheckedChildren="显示"
                />
              </Form.Item>

              <Form.Item label="帮助文本">
                <TextArea
                  value={selectedField.helpText}
                  onChange={e => onFieldUpdate({ helpText: e.target.value })}
                  placeholder="字段下方的提示文本"
                  rows={2}
                />
              </Form.Item>
            </Form>
          </Card>
        </Panel>

        {/* 高级配置 */}
        <Panel header="🔧 高级配置" key="advanced">
          <Card size="small">
            <Form layout="vertical" size="small">
              <Form.Item label="默认值">
                <Input
                  value={selectedField.defaultValue}
                  onChange={e => onFieldUpdate({ defaultValue: e.target.value })}
                  placeholder="字段默认值"
                />
              </Form.Item>

              <Form.Item label="BO字段绑定">
                <Select
                  value={selectedField.boField}
                  onChange={val => onFieldUpdate({ boField: val })}
                  placeholder="选择绑定的BO字段"
                >
                  <Option value="customer_name">客户名称</Option>
                  <Option value="customer_phone">客户电话</Option>
                  <Option value="order_date">订单日期</Option>
                  <Option value="total_amount">订单金额</Option>
                </Select>
              </Form.Item>

              <Form.Item label="计算表达式">
                <TextArea
                  value={selectedField.formula}
                  onChange={e => onFieldUpdate({ formula: e.target.value })}
                  placeholder="如: ${qty * price}"
                  rows={2}
                />
              </Form.Item>
            </Form>
          </Card>
        </Panel>
      </Collapse>

      {/* 字段预览 */}
      <Card size="small" style={{ marginTop: '16px' }} title="👁️ 字段预览">
        <div style={{ padding: '8px', background: '#f5f5f5', borderRadius: '4px' }}>
          <div style={{ marginBottom: '8px' }}>
            <strong>{selectedField.label || '字段标签'}</strong>
            {selectedField.required && <span style={{ color: 'red', marginLeft: '4px' }}>*</span>}
          </div>
          <div style={{ fontSize: '12px', color: '#666' }}>
            <div>类型: {selectedField.type}</div>
            <div>ID: {selectedField.fieldId}</div>
            {selectedField.placeholder && <div>占位符: {selectedField.placeholder}</div>}
            {selectedField.options && <div>选项数: {selectedField.options.length}</div>}
            {selectedField.helpText && <div>提示: {selectedField.helpText}</div>}
          </div>
        </div>
      </Card>
    </div>
  );
};
