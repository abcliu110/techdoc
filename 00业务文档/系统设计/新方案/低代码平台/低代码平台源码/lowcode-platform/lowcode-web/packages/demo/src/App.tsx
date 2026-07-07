import React from 'react';
import { Tabs } from 'antd';
import { FormRenderer } from './FormRenderer';
import { FormDesignerNested } from './FormDesignerNested';
import { DragTest } from './DragTest';

// 主应用
export const App: React.FC = () => {
  return (
    <div style={{ height: '100vh' }}>
      <Tabs
        defaultActiveKey="designer"
        size="large"
        style={{ padding: '0 24px', background: 'white' }}
        items={[
          {
            key: 'designer',
            label: '🎨 表单设计器 (嵌套版)',
            children: <FormDesignerNested />,
          },
          {
            key: 'renderer',
            label: '📝 表单渲染器',
            children: <FormRenderer />,
          },
          {
            key: 'dragtest',
            label: '🧪 拖拽测试',
            children: <DragTest />,
          },
        ]}
      />
    </div>
  );
};
