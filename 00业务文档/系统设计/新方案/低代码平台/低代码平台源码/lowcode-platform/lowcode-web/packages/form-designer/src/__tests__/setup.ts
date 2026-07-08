import '@testing-library/jest-dom';
import { vi } from 'vitest';
import React from 'react';

// Mock @ant-design/fast-color (ESM only, not compatible with jsdom)
vi.mock('@ant-design/fast-color', () => ({
  FastColor: { toHexString: (c: string) => c },
  default: { toHexString: (c: string) => c },
}));

// Mock antd icons
vi.mock('@ant-design/icons', () => ({
  DeleteOutlined: () => React.createElement('span', { 'data-testid': 'delete-icon' }, 'DeleteOutlined'),
  EditOutlined: () => React.createElement('span', null, 'EditOutlined'),
  PlusOutlined: () => React.createElement('span', null, 'PlusOutlined'),
  SaveOutlined: () => React.createElement('span', null, 'SaveOutlined'),
  DragOutlined: () => React.createElement('span', null, 'DragOutlined'),
  SettingOutlined: () => React.createElement('span', null, 'SettingOutlined'),
  default: {},
}));

// Mock antd components as function components
const MockInput = (props: any) => React.createElement('input', { 'data-testid': 'mock-input', ...props });
const MockInputNumber = (props: any) => React.createElement('input', { type: 'number', ...props });
const MockDatePicker = (props: any) => React.createElement('input', { type: 'date', ...props });
const MockTimePicker = (props: any) => React.createElement('input', { type: 'time', ...props });
const MockSwitch = (props: any) => React.createElement('button', { role: 'switch', ...props });
const MockUpload = (props: any) => React.createElement('div', props, 'Upload');
const MockButton = (props: any) => React.createElement('button', props);
const MockRate = (props: any) => React.createElement('div', props, 'Rate');
const MockSlider = (props: any) => React.createElement('input', { type: 'range', ...props });
const MockCard = (props: any) => React.createElement('div', props);
const MockDivider = (props: any) => React.createElement('hr', props);
const MockTag = (props: any) => React.createElement('span', props);
const MockCascader = (props: any) => React.createElement('div', props, 'Cascader');
const MockAutoComplete = (props: any) => React.createElement('input', props);
const MockTreeSelect = (props: any) => React.createElement('div', props, 'TreeSelect');
const MockTransfer = (props: any) => React.createElement('div', props, 'Transfer');
const MockTable = (props: any) => React.createElement('table', props);
const MockCalendar = (props: any) => React.createElement('div', props, 'Calendar');
const MockList = (props: any) => React.createElement('div', props);
const MockSpace = (props: any) => React.createElement('div', props);
const MockTabs = ({ children, ...props }: any) => React.createElement('div', props, children);
const MockCollapse = ({ children, ...props }: any) => React.createElement('div', props, children);
const MockOption = ({ children }: any) => React.createElement('option', null, children);
const MockTabsPane = ({ children, ...props }: any) => React.createElement('div', props, children);
const MockCollapsePanel = ({ children, ...props }: any) => React.createElement('div', props, children);

const MockSelect = ({ children, ...props }: any) =>
  React.createElement('select', props, children);

const MockCheckboxGroup = ({ children, ...props }: any) =>
  React.createElement('div', props, children);

const MockRadioGroup = ({ children, ...props }: any) =>
  React.createElement('div', props, children);

const MockFormItem = ({ children, ...props }: any) =>
  React.createElement('div', { 'data-testid': 'form-item', ...props }, children);

vi.mock('antd', () => ({
  Form: {
    Item: MockFormItem,
  },
  Input: MockInput,
  InputNumber: MockInputNumber,
  Select: Object.assign(MockSelect, { Option: MockOption }),
  DatePicker: MockDatePicker,
  TimePicker: MockTimePicker,
  Checkbox: {
    Group: MockCheckboxGroup,
  },
  Radio: {
    Group: MockRadioGroup,
  },
  Switch: MockSwitch,
  Upload: MockUpload,
  Button: MockButton,
  Rate: MockRate,
  Slider: MockSlider,
  Card: MockCard,
  Tabs: Object.assign(MockTabs, { TabPane: MockTabsPane }),
  Collapse: Object.assign(MockCollapse, { Panel: MockCollapsePanel }),
  Divider: MockDivider,
  Tag: MockTag,
  Cascader: MockCascader,
  AutoComplete: MockAutoComplete,
  TreeSelect: MockTreeSelect,
  Transfer: MockTransfer,
  Table: MockTable,
  Calendar: MockCalendar,
  Layout: {
    Sider: MockCard,
    Content: MockCard,
  },
  List: MockList,
  Space: MockSpace,
}));
