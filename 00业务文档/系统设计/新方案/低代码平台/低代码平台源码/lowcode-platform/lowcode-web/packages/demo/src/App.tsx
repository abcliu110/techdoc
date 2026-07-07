import React from 'react';
import { Tabs } from 'antd';
import { FormRenderer } from './FormRenderer';
import { FormDesignerEnhanced } from './FormDesignerEnhanced';

// 主应用 - 包含渲染器和增强版设计器
export const App: React.FC = () => {
  return (
    <div style={{ height: '100vh' }}>
      <Tabs
        defaultActiveKey="designer"
        size="large"
        style={{ padding: '0 24px', background: 'white' }}
        items={[
          {
            key: 'renderer',
            label: '📝 表单渲染器',
            children: <FormRenderer />,
          },
          {
            key: 'designer',
            label: '🎨 表单设计器 (增强版)',
            children: <FormDesignerEnhanced />,
          },
        ]}
      />
    </div>
  );
};
