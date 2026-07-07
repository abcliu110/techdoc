# Form Components

表单组件库 - 37个组件

## 组件清单

### P0 基础组件（8个）✅
- Input - 输入框
- InputNumber - 数字输入
- Select - 下拉选择
- DatePicker - 日期选择
- Checkbox - 复选框
- Radio - 单选框
- Switch - 开关
- Button - 按钮

### P1 重要组件（15个）✅
- Upload - 文件上传
- TextArea - 多行文本
- Cascader - 级联选择
- Card - 卡片
- Tabs - 标签页
- SubTable - 子表
- TimePicker - 时间选择
- RangePicker - 范围选择
- AutoComplete - 自动完成
- Tag - 标签
- Rate - 评分
- Progress - 进度条
- Badge - 徽标
- Avatar - 头像
- Divider - 分割线

### P2 增强组件（14个）✅
- RichText - 富文本编辑器
- Slider - 滑块
- Tree - 树形控件
- Transfer - 穿梭框
- ColorPicker - 颜色选择器
- Calendar - 日历
- Mentions - 提及
- Steps - 步骤条
- Collapse - 折叠面板
- Anchor - 锚点
- Tooltip - 提示
- Popover - 气泡卡片
- Modal - 对话框
- Drawer - 抽屉

**总计**：37个组件 ✅

## 使用方式

```typescript
import { COMPONENT_REGISTRY } from '@lowcode/form-components';

// 所有组件都遵循统一接口
interface ComponentProps {
  value: any;
  onChange: (value: any) => void;
  disabled?: boolean;
  readonly?: boolean;
}
```
